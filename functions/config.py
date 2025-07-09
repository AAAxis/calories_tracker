import os
from dotenv import load_dotenv

# Load environment variables from .env file if present
load_dotenv()

# API Keys Configuration
API_KEYS = {
    'OPEN_ROUTER': os.environ.get('OPEN_ROUTER_API_KEY', '')  # Must be set in environment variables
}

# Email Configuration
EMAIL_CONFIG = {
    'SENDER': os.environ.get('EMAIL_SENDER', 'noreply@theholylabs.com'),
    'PASSWORD': os.environ.get('EMAIL_PASSWORD', 'pass2222'),
    'SMTP_SERVER': os.environ.get('SMTP_SERVER', 'mail.theholylabs.com'),
    'SMTP_PORT': int(os.environ.get('SMTP_PORT', '587'))
}

# Email Templates
EMAIL_TEMPLATES = {
    'verification': {
        'subject': 'Your Verification Code for Calzo',
        'html_template': """<html><head><style>body{{font-family:Arial,sans-serif;line-height:1.6;color:#333333}}.container{{max-width:600px;margin:0 auto;padding:20px}}.code{{font-size:32px;font-weight:bold;color:#4A90E2;letter-spacing:5px;text-align:center;padding:20px;margin:20px 0;background-color:#F5F5F5;border-radius:5px}}.footer{{font-size:12px;color:#666666;text-align:center;margin-top:30px}}</style></head><body><div class="container"><h2>Welcome to Calzo!</h2><p>Thank you for signing up. To complete your registration, please use the following verification code:</p><div class="code">{verification_code}</div><p>This code will expire in 10 minutes for security purposes.</p><p>If you didn't request this code, please ignore this email.</p><div class="footer"><p>This is an automated message, please do not reply.</p><p>&copy; {year} Calzo. All rights reserved.</p></div></div></body></html>""",
        'text_template': """Welcome to Calzo!

Thank you for signing up. To complete your registration, please use the following verification code:

{verification_code}

This code will expire in 10 minutes for security purposes.

If you didn't request this code, please ignore this email.

This is an automated message, please do not reply.
© {year} Calzo. All rights reserved."""
    }
} 