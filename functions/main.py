# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn
from firebase_admin import initialize_app
import json
import time
import os
import random
import string
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import smtplib
from config import EMAIL_CONFIG, EMAIL_TEMPLATES

# Initialize Firebase app
app = initialize_app()

# Import our custom helper module
try:
    from openai_helper import analyze_image_with_vision
except ImportError:
    # Fallback implementation if import fails
    def analyze_image_with_vision(image_url=None, prompt=None, image_base64=None):
        return {
            "mealName": "Analysis temporarily unavailable",
            "estimatedCalories": 400,
            "macros": {
                "proteins": "20g",
                "carbohydrates": "45g", 
                "fats": "15g"
            },
            "ingredients": ["Temporary analysis unavailable"],
            "healthiness": "N/A",
            "health_assessment": "Analysis service is being updated. Please try again later.",
            "source": "https://fdc.nal.usda.gov/"
        }

def send_verification_email(to_email: str, verification_code: str) -> bool:
    """Send verification email with the provided code"""
    try:
        print(f"📧 Starting email send process to: {to_email}")
        print(f"📧 Using SMTP server: {EMAIL_CONFIG['SMTP_SERVER']}:{EMAIL_CONFIG['SMTP_PORT']}")
        print(f"📧 From address: {EMAIL_CONFIG['SENDER']}")
        print(f"📧 Password configured: {'Yes' if EMAIL_CONFIG['PASSWORD'] else 'No'}")

        msg = MIMEMultipart('alternative')
        msg['Subject'] = EMAIL_TEMPLATES['verification']['subject']
        msg['From'] = EMAIL_CONFIG['SENDER']
        msg['To'] = to_email

        # Get the current year for the template
        current_year = time.strftime('%Y')

        # Format the templates with the verification code and year
        print(f"📧 Template variables: code={verification_code}, year={current_year}")
        
        try:
            html = EMAIL_TEMPLATES['verification']['html_template'].format(
                verification_code=verification_code,
                year=current_year
            )
            print("✅ HTML template formatted successfully")
        except Exception as template_error:
            print(f"❌ Error formatting HTML template: {str(template_error)}")
            print(f"❌ Error type: {type(template_error).__name__}")
            return False

        try:
            text = EMAIL_TEMPLATES['verification']['text_template'].format(
                verification_code=verification_code,
                year=current_year
            )
            print("✅ Text template formatted successfully")
        except Exception as template_error:
            print(f"❌ Error formatting text template: {str(template_error)}")
            print(f"❌ Error type: {type(template_error).__name__}")
            return False

        part1 = MIMEText(text, 'plain')
        part2 = MIMEText(html, 'html')

        msg.attach(part1)
        msg.attach(part2)

        print("📧 Email content prepared successfully")

        # Connect to SMTP server and send email
        print(f"📧 Attempting to connect to SMTP server...")
        
        # Create SMTP object with timeout
        server = smtplib.SMTP(EMAIL_CONFIG['SMTP_SERVER'], EMAIL_CONFIG['SMTP_PORT'], timeout=30)
        
        try:
            # Enable debug output
            server.set_debuglevel(1)
            print("📧 SMTP connection established")
            
            # Identify ourselves to SMTP server
            server.ehlo()
            print("📧 EHLO completed")
            
            # Start TLS if supported
            if server.has_extn('STARTTLS'):
                print("📧 Starting TLS...")
                server.starttls()
                # Identify ourselves again after TLS
                server.ehlo()
                print("📧 TLS started and second EHLO completed")
            else:
                print("⚠️ STARTTLS not supported by server")
            
            if EMAIL_CONFIG['PASSWORD']:
                print("📧 Attempting SMTP login...")
                server.login(EMAIL_CONFIG['SENDER'], EMAIL_CONFIG['PASSWORD'])
                print("📧 SMTP login successful")
            else:
                print("⚠️ No SMTP password configured, attempting without authentication")

            print("📧 Sending email...")
            server.send_message(msg)
            print("✅ Email sent successfully")
            
            return True
            
        finally:
            try:
                print("📧 Closing SMTP connection...")
                server.quit()
                print("📧 SMTP connection closed properly")
            except Exception as close_error:
                print(f"⚠️ Error while closing SMTP connection: {str(close_error)}")

    except smtplib.SMTPAuthenticationError as auth_error:
        print(f"❌ SMTP Authentication failed: {str(auth_error)}")
        print("❌ Please check your email credentials (username and password)")
        print(f"❌ Server response: {getattr(auth_error, 'smtp_error', 'No detailed error')}")
        print(f"❌ Error code: {getattr(auth_error, 'smtp_code', 'No code')}")
        return False
    except smtplib.SMTPConnectError as conn_error:
        print(f"❌ Failed to connect to SMTP server: {str(conn_error)}")
        print(f"❌ Check if {EMAIL_CONFIG['SMTP_SERVER']}:{EMAIL_CONFIG['SMTP_PORT']} is correct and accessible")
        print(f"❌ Server response: {getattr(conn_error, 'smtp_error', 'No detailed error')}")
        return False
    except smtplib.SMTPServerDisconnected as disc_error:
        print(f"❌ Server disconnected: {str(disc_error)}")
        print("❌ This might indicate a timeout or server connection issue")
        return False
    except smtplib.SMTPException as smtp_error:
        print(f"❌ SMTP error occurred: {str(smtp_error)}")
        print(f"❌ Error type: {type(smtp_error).__name__}")
        print(f"❌ Server response: {getattr(smtp_error, 'smtp_error', 'No detailed error')}")
        return False
    except Exception as e:
        print(f"❌ Error sending verification email: {str(e)}")
        print(f"❌ Error type: {type(e).__name__}")
        print(f"❌ Full error details: {repr(e)}")
        return False

# OpenAI function for analyzing meal images
@https_fn.on_request()
def analyze_meal_image_v2(req: https_fn.Request) -> https_fn.Response:
    """Analyze meal image using OpenAI Vision API"""
    try:
        # Get data from request
        data = req.get_json()
        image_url = data.get('image_url')
        image_base64 = data.get('image_base64')
        image_name = data.get('image_name', 'unknown.jpg')
        function_info = data.get('function_info', {})
        
        print(f"Received analysis request for image: {image_name}")
        
        if image_url:
            print(f"Image URL length: {len(image_url)}")
        if image_base64:
            print(f"Image base64 length: {len(image_base64)}")
        
        # Validate that we have either URL or base64
        if not image_url and not image_base64:
            return https_fn.Response(
                json.dumps({'error': 'Either image_url or image_base64 must be provided'}),
                status=400,
                headers={'Content-Type': 'application/json'}
            )
            
        # Validate URL format if provided
        if image_url and not image_url.startswith(('http://', 'https://')):
            return https_fn.Response(
                json.dumps({'error': 'Invalid image URL format. Must start with http:// or https://'}),
                status=400,
                headers={'Content-Type': 'application/json'}
            )

        if image_url:
            print(f"Processing image URL: {image_url[:50]}...")
        else:
            print(f"Processing base64 image data ({len(image_base64)} characters)")
        
        prompt = """
Analyze this meal image and provide detailed nutritional information in JSON format. Include:
1. Meal identification (in English only)
2. Accurate calorie estimation
3. Detailed macro breakdown (in grams)
4. List of ingredients with estimated weights (in English only)
5. Detailed ingredients with individual nutrition per ingredient
6. A categorical healthiness value (e.g., 'healthy', 'medium', 'unhealthy')
7. Detailed health assessment text
8. Source URL for more information

Format the response as:
{
  'mealName': 'Meal name in English',
  'estimatedCalories': number (e.g., 670),
  'macros': {
    'proteins': 'Xg (e.g., 30g)',
    'carbohydrates': 'Xg (e.g., 50g)',
    'fats': 'Xg (e.g., 40g)'
  },
  'ingredients': ['ingredient1', 'ingredient2', 'ingredient3'],
  'detailedIngredients': [
    {
      'name': 'Ingredient name in English',
      'grams': estimated_weight_in_grams,
      'calories': calories_for_this_ingredient,
      'proteins': proteins_in_grams,
      'carbs': carbs_in_grams,
      'fats': fats_in_grams
    }
  ],
  'healthiness': 'healthy' | 'medium' | 'unhealthy' | 'N/A',
  'health_assessment': 'Detailed health assessment of the meal',
  'source': 'A valid URL (starting with http or https) for more information about this meal'
}

Important:
- Provide realistic calorie and macro values based on visible portions.
- Ensure 'estimatedCalories' is a number.
- Ensure macros (proteins, carbohydrates, fats) are strings ending with 'g'.
- For detailedIngredients, estimate the weight of each visible ingredient in grams.
- Calculate individual nutrition values for each ingredient based on typical nutrition data.
- The sum of all ingredient calories should approximately match estimatedCalories.
- The sum of all ingredient macros should approximately match the main macros.
- The 'healthiness' field should be one of 'healthy', 'medium', 'unhealthy', or 'N/A'.
- Provide a comprehensive 'health_assessment' string.
- The source field MUST be a valid URL, defaulting to https://fdc.nal.usda.gov/ if needed.
- All responses should be in English only - translation will be handled client-side.
- Be as accurate as possible with ingredient weights and nutrition values.
"""

        try:
            # Using the custom analyze_image_with_vision function from openai_helper
            raw_analysis_output = analyze_image_with_vision(
                image_url=image_url, 
                prompt=prompt, 
                image_base64=image_base64
            )
            
            # Debug: Log what OpenAI actually returned
            print(f"🔍 Raw OpenAI output type: {type(raw_analysis_output)}")
            if isinstance(raw_analysis_output, str):
                print(f"🔍 Raw OpenAI output (first 500 chars): {raw_analysis_output[:500]}")
            else:
                print(f"🔍 Raw OpenAI output: {raw_analysis_output}")
            
            final_json_payload_str: str

            if isinstance(raw_analysis_output, str):
                text_to_parse = raw_analysis_output.strip()

                # Try to remove markdown fences
                if text_to_parse.startswith("```json") and text_to_parse.endswith("```"):
                    # Slice from after "```json" (length 7) to before "```" (length 3 from end)
                    text_to_parse = text_to_parse[len("```json"):-len("```")].strip()
                elif text_to_parse.startswith("```") and text_to_parse.endswith("```"):
                    # Slice from after "```" (length 3) to before "```" (length 3 from end)
                    text_to_parse = text_to_parse[len("```"):-len("```")].strip()

                # After attempting to strip markdown, find the JSON object
                json_start_index = text_to_parse.find('{')
                json_end_index = text_to_parse.rfind('}')

                if json_start_index != -1 and json_end_index != -1 and json_end_index > json_start_index:
                    json_str_candidate = text_to_parse[json_start_index : json_end_index + 1]
                    
                    # Fix common JSON issues: replace single quotes with double quotes
                    # This is a common issue with AI-generated JSON
                    print(f"🔧 Original JSON candidate (first 200 chars): {json_str_candidate[:200]}")
                    
                    # Replace single quotes with double quotes for property names and string values
                    # But be careful not to replace quotes inside strings
                    fixed_json_str = json_str_candidate
                    
                    # More robust approach: handle mixed quotes and escape sequences
                    if "'" in fixed_json_str:
                        # If there are no double quotes at all, simple replacement is safe
                        if '"' not in fixed_json_str:
                            fixed_json_str = fixed_json_str.replace("'", '"')
                            print(f"🔧 Fixed JSON by replacing all single quotes with double quotes")
                        else:
                            # If there are mixed quotes, use regex for more careful replacement
                            import re
                            # Replace single quotes around property names: 'propertyName':
                            fixed_json_str = re.sub(r"'([^']*)'(\s*:)", r'"\1"\2', fixed_json_str)
                            # Replace single quotes around string values: : 'value'
                            fixed_json_str = re.sub(r":\s*'([^']*)'", r': "\1"', fixed_json_str)
                            print(f"🔧 Fixed JSON using regex for mixed quote replacement")
                    
                    print(f"🔧 Fixed JSON candidate (first 200 chars): {fixed_json_str[:200]}")
                    
                    try:
                        parsed_json = json.loads(fixed_json_str)
                        
                        # Debug: Check if healthiness is in the parsed JSON
                        print(f"🔍 Parsed JSON keys: {list(parsed_json.keys())}")
                        if 'healthiness' in parsed_json:
                            print(f"✅ Found healthiness in parsed JSON: {parsed_json['healthiness']}")
                        else:
                            print("❌ No healthiness field found in parsed JSON")
                            print(f"🔍 Full parsed JSON: {parsed_json}")
                            # Add default healthiness if missing
                            parsed_json['healthiness'] = 'N/A'
                            print("🔧 Added default healthiness: N/A")
                        
                        final_json_payload_str = json.dumps(parsed_json) # Re-serialize for clean output
                    except json.JSONDecodeError as e:
                        error_message = f"Could not parse extracted JSON (from braces) from vision API output. Error: {str(e)}. Original snippet: {json_str_candidate[:200]}. Fixed snippet: {fixed_json_str[:200]}"
                        print(error_message)
                        raise Exception(error_message) from e
                else:
                    # If no '{...}' found, try to parse the text_to_parse directly
                    print(f"🔧 No braces found, trying direct parse of: {text_to_parse[:200]}")
                    
                    # Apply the same quote fixing logic
                    fixed_text = text_to_parse
                    if "'" in fixed_text:
                        # If there are no double quotes at all, simple replacement is safe
                        if '"' not in fixed_text:
                            fixed_text = fixed_text.replace("'", '"')
                            print(f"🔧 Fixed direct parse text by replacing all single quotes")
                        else:
                            # If there are mixed quotes, use regex for more careful replacement
                            import re
                            # Replace single quotes around property names: 'propertyName':
                            fixed_text = re.sub(r"'([^']*)'(\s*:)", r'"\1"\2', fixed_text)
                            # Replace single quotes around string values: : 'value'
                            fixed_text = re.sub(r":\s*'([^']*)'", r': "\1"', fixed_text)
                            print(f"🔧 Fixed direct parse text using regex")
                    
                    try:
                        parsed_json = json.loads(fixed_text)
                        
                        # Debug: Check if healthiness is in the parsed JSON
                        print(f"🔍 Direct parse JSON keys: {list(parsed_json.keys())}")
                        if 'healthiness' in parsed_json:
                            print(f"✅ Found healthiness in direct parsed JSON: {parsed_json['healthiness']}")
                        else:
                            print("❌ No healthiness field found in direct parsed JSON")
                            print(f"🔍 Full direct parsed JSON: {parsed_json}")
                            # Add default healthiness if missing
                            parsed_json['healthiness'] = 'N/A'
                            print("🔧 Added default healthiness: N/A")
                        
                        final_json_payload_str = json.dumps(parsed_json) 
                    except json.JSONDecodeError as e:
                        error_message = f"Vision API output is not a recognized JSON object (no braces found) and not a simple JSON string after stripping. Error: {str(e)}. Original snippet: {text_to_parse[:200]}. Fixed snippet: {fixed_text[:200]}"
                        print(error_message)
                        raise Exception(error_message) from e
            elif isinstance(raw_analysis_output, (dict, list)):
                final_json_payload_str = json.dumps(raw_analysis_output)
            else:
                error_message = f"Unexpected data type from image analysis service: {type(raw_analysis_output)}. Output snippet: {str(raw_analysis_output)[:200]}"
                print(error_message)
                raise Exception(error_message)

            # Return the cleaned and validated analysis result
            return https_fn.Response(
                final_json_payload_str,
                status=200,
                headers={'Content-Type': 'application/json'}
            )
        except Exception as vision_error:
            print(f"OpenAI Vision API error: {str(vision_error)}")
            # Return a more helpful error message
            error_response = {
                "error": "Failed to analyze image with OpenAI Vision API",
                "message": str(vision_error),
                "fallback_analysis": {
                    "meal_name": "Unknown meal (analysis failed)",
                    "estimated_calories": 0,
                    "macronutrients": {
                        "proteins": "0g",
                        "carbohydrates": "0g",
                        "fats": "0g"
                    },
                    "ingredients": ["could not analyze image"],
                    "health_assessment": "Analysis failed. Please try again later.",
                    "source": "https://fdc.nal.usda.gov/"
                }
            }
            return https_fn.Response(
                json.dumps(error_response),
                status=200,  # Return 200 with error info instead of 500
                headers={'Content-Type': 'application/json'}
            )
        
    except Exception as e:
        print(f"Error in analyze_meal_image: {str(e)}")
        return https_fn.Response(
            json.dumps({
                "error": "General error occurred",
                "message": str(e),
                "fallback_analysis": {
                    "meal_name": "Error occurred",
                    "estimated_calories": 0,
                    "macronutrients": {
                        "proteins": "0g",
                        "carbohydrates": "0g",
                        "fats": "0g"
                    },
                    "ingredients": ["analysis failed"],
                    "health_assessment": "Error occurred during analysis.",
                    "source": "https://fdc.nal.usda.gov/"
                }
            }),
            status=200,
            headers={'Content-Type': 'application/json'}
        )

@https_fn.on_request()
def global_auth(req: https_fn.Request) -> https_fn.Response:
    """Handle email verification code generation and sending"""
    try:
        # Get email from query parameters
        email = req.args.get('email')
        
        if not email:
            return https_fn.Response(
                json.dumps({'error': 'Email parameter is required'}),
                status=400,
                headers={'Content-Type': 'application/json'}
            )

        print(f"📨 Processing verification request for email: {email}")
        
        # Generate a 6-digit verification code
        verification_code = ''.join(random.choices(string.digits, k=6))
        print(f"🔢 Generated verification code: {verification_code}")
        
        # Send verification email
        email_sent = send_verification_email(email, verification_code)
        
        if not email_sent:
            print(f"⚠️ Failed to send verification email to {email}")
            print("⚠️ Check the logs above for detailed error information")
            # Still return the code as auth_service.dart expects it
            # but log the failure for monitoring
        
        response_data = {
            'verification_code': verification_code,
            'message': 'Verification code generated successfully',
            'email_sent': email_sent
        }
        
        return https_fn.Response(
            json.dumps(response_data),
            status=200,
            headers={'Content-Type': 'application/json'}
        )
        
    except Exception as e:
        print(f"Error in global_auth: {str(e)}")
        return https_fn.Response(
            json.dumps({
                "error": "Failed to generate verification code",
                "message": str(e)
            }),
            status=500,
            headers={'Content-Type': 'application/json'}
        )

