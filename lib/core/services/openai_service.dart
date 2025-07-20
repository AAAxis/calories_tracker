import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'compression_service.dart';

class OpenAIService {
  /// Analyze meal image using Firebase Functions with URL
  static Future<Map<String, dynamic>> analyzeMealImage({
    required String imageUrl,
    required String imageName,
    String? apiKey,
  }) async {
    try {
      print('🔥 Starting Firebase Functions analysis for image: $imageName');
      
      // Get the function URL - you'll need to replace with your actual project URL
      final functionUrl = 'https://us-central1-kaliai-6dff9.cloudfunctions.net/analyze_meal_image_v2';
      
      // Prepare the request payload to match your function's expected format
      final requestData = {
        "image_url": imageUrl,
        "image_name": imageName,
        "function_info": {
          "source": "flutter_app",
          "timestamp": DateTime.now().toIso8601String(),
        }
      };
      
      print('🔥 Calling Firebase Function at: $functionUrl');
      
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      
      print('🔥 Firebase Function response status: ${response.statusCode}');
      print('🔥 Firebase Function response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('✅ Firebase Functions analysis completed successfully');
        print('🔍 Response data keys: ${responseData.keys}');
        
        // Check if the response contains an error
        if (responseData.containsKey('error')) {
          print('❌ Firebase Function returned an error: ${responseData['error']}');
          
          // Check if there's a fallback analysis we can use
          if (responseData.containsKey('fallback_analysis')) {
            print('🔄 Using fallback analysis from Firebase Function');
            final fallbackData = responseData['fallback_analysis'];
            
            // Transform fallback data to match expected format
            return _transformFallbackResponse(fallbackData);
          }
          
          throw Exception('Firebase Function error: ${responseData['error']}');
        }
        
        return _transformFirebaseResponse(responseData);
      } else {
        throw Exception('Firebase Function returned status ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Error in Firebase Functions analysis: $e');
      rethrow;
    }
  }

  /// Analyze meal image using base64 encoding with Firebase Functions
  static Future<Map<String, dynamic>> analyzeMealImageBase64({
    required File imageFile,
    required String imageName,
    String? apiKey,
  }) async {
    try {
      print('🔥 Starting Firebase Functions analysis with base64 for image: $imageName');
      
      // Compress the image before base64 encoding
      print('🗜️ Compressing image for Firebase Functions...');
      final compressedFile = await CompressionService.aggressiveCompress(imageFile);
      
      // Check if compressed file is suitable for base64
      final isSuitable = await CompressionService.isSuitableForBase64(compressedFile, maxSizeKB: 400);
      if (!isSuitable) {
        print('⚠️ Image still too large after compression, may cause issues');
      }
      
      // Read and encode compressed image file as base64
      final imageBytes = await compressedFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      print('🔥 Image compressed and encoded as base64, size: ${base64Image.length} characters');
      print('📏 Compressed file size: ${await compressedFile.length()} bytes');
      
      final functionUrl = 'https://us-central1-kaliai-6dff9.cloudfunctions.net/analyze_meal_image_v2';
      
      // Prepare the request payload to match your function's expected format
      final requestData = {
        "image_base64": base64Image,
        "image_name": imageName,
        "function_info": {
          "source": "flutter_app_base64",
          "timestamp": DateTime.now().toIso8601String(),
        }
      };
      
      print('🔥 Calling Firebase Function with base64 data...');
      
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      
      print('🔥 Firebase Function response status: ${response.statusCode}');
      print('🔥 Firebase Function response body: ${response.body}');
      
      // Clean up temporary compressed file
      try {
        if (compressedFile.path != imageFile.path) {
          await compressedFile.delete();
        }
      } catch (e) {
        print('⚠️ Could not delete temporary compressed file: $e');
      }
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        print('✅ Firebase Functions base64 analysis completed successfully');
        print('🔍 Response data keys: ${responseData.keys}');
        
        // Check if the response contains an error
        if (responseData.containsKey('error')) {
          print('❌ Firebase Function returned an error: ${responseData['error']}');
          
          // Check if there's a fallback analysis we can use
          if (responseData.containsKey('fallback_analysis')) {
            print('🔄 Using fallback analysis from Firebase Function');
            final fallbackData = responseData['fallback_analysis'];
            
            // Transform fallback data to match expected format
            return _transformFallbackResponse(fallbackData);
          }
          
          throw Exception('Firebase Function error: ${responseData['error']}');
        }
        
        return _transformFirebaseResponse(responseData);
      } else {
        throw Exception('Firebase Function returned status ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Error in Firebase Functions base64 analysis: $e');
      rethrow;
    }
  }
  
  /// Transform fallback Firebase Function response to match the expected format
  static Map<String, dynamic> _transformFallbackResponse(Map<String, dynamic> fallbackResponse) {
    try {
      print('🔄 Transforming fallback response from Firebase Function');
      
      // The fallback response has different field names than the main response
      final mealName = fallbackResponse['meal_name'] ?? 'Analysis Failed';
      final calories = fallbackResponse['estimated_calories'] ?? 0;
      final macros = fallbackResponse['macronutrients'] ?? {};
      final ingredients = List<String>.from(fallbackResponse['ingredients'] ?? ['Analysis failed']);
      final healthAssessment = fallbackResponse['health_assessment'] ?? 'Analysis failed';
      final source = fallbackResponse['source'] ?? 'https://fdc.nal.usda.gov/';
      
      final transformed = <String, dynamic>{
        'mealName': mealName,
        'calories': _parseCalories(calories),
        'macros': _parseMacros(macros),
        'ingredients': ingredients,
        'healthiness': 'N/A',
        'healthiness_explanation': healthAssessment,
        'source': source,
        
        // Add default fields
        'nutrients': {
          'fiber': 0.0,
          'sugar': 0.0,
          'sodium': 0.0,
          'potassium': 0.0,
          'vitamin_c': 0.0,
          'calcium': 0.0,
          'iron': 0.0
        },
        'portion_size': 'medium',
        'meal_type': 'unknown',
        'cooking_method': 'unknown',
        'allergens': <String>[],
        'dietary_tags': <String>[],
        'detailedIngredients': <Map<String, dynamic>>[],
      };
      
      print('✅ Transformed fallback response successfully');
      return transformed;
      
    } catch (e) {
      print('❌ Error transforming fallback response: $e');
      // Return a very basic fallback
      return {
        'mealName': 'Analysis Error',
        'calories': 200.0,
        'macros': {'proteins': 10.0, 'carbs': 25.0, 'fats': 8.0},
        'ingredients': ['Analysis failed'],
        'healthiness': 'N/A',
        'healthiness_explanation': 'Analysis failed. Please try again later.',
        'source': 'https://fdc.nal.usda.gov/',
        'nutrients': {
          'fiber': 0.0,
          'sugar': 0.0,
          'sodium': 0.0,
          'potassium': 0.0,
          'vitamin_c': 0.0,
          'calcium': 0.0,
          'iron': 0.0
        },
        'portion_size': 'medium',
        'meal_type': 'unknown',
        'cooking_method': 'unknown',
        'allergens': <String>[],
        'dietary_tags': <String>[],
        'detailedIngredients': <Map<String, dynamic>>[],
      };
    }
  }

  /// Transform Firebase Function response to match the expected format in your app
  static Map<String, dynamic> _transformFirebaseResponse(Map<String, dynamic> firebaseResponse) {
    try {
  
      final englishMealName = firebaseResponse['mealName'] ?? 'Unknown Meal';
      final englishIngredients = firebaseResponse['ingredients'] ?? ['Unknown ingredients'];
      final englishHealthAssessment = firebaseResponse['health_assessment'] ?? 'No assessment available';
      
      final transformed = <String, dynamic>{
        'mealName': englishMealName,
        'calories': _parseCalories(firebaseResponse['estimatedCalories']),
        'macros': _parseMacros(firebaseResponse['macros']),
        'ingredients': List<String>.from(englishIngredients),
        'healthiness': firebaseResponse['healthiness'] ?? 'N/A',
        'healthiness_explanation': englishHealthAssessment,
        'source': firebaseResponse['source'] ?? 'https://fdc.nal.usda.gov/',
        
        // Add additional fields that your app expects
        'nutrients': {
          'fiber': 0.0,
          'sugar': 0.0,
          'sodium': 0.0,
          'potassium': 0.0,
          'vitamin_c': 0.0,
          'calcium': 0.0,
          'iron': 0.0
        },
        'portion_size': 'medium',
        'meal_type': 'unknown',
        'cooking_method': 'unknown',
        'allergens': <String>[],
        'dietary_tags': <String>[],
        
        // Parse detailed ingredients if available
        'detailedIngredients': _parseDetailedIngredients(firebaseResponse['detailedIngredients']),
      };
      
      print('🔄 Transformed Firebase response successfully');
      return transformed;
      
    } catch (e) {
      print('❌ Error transforming Firebase response: $e');
      // Return a safe fallback
      return {
        'mealName': 'Analysis Error',
        'calories': 200.0,
        'macros': {'proteins': 10.0, 'carbs': 25.0, 'fats': 8.0},
        'ingredients': ['Analysis failed'],
        'healthiness': 'N/A',
        'healthiness_explanation': 'Analysis failed',
        'source': 'https://fdc.nal.usda.gov/',
        'nutrients': {
          'fiber': 0.0,
          'sugar': 0.0,
          'sodium': 0.0,
          'potassium': 0.0,
          'vitamin_c': 0.0,
          'calcium': 0.0,
          'iron': 0.0
        },
        'portion_size': 'medium',
        'meal_type': 'unknown',
        'cooking_method': 'unknown',
        'allergens': <String>[],
        'dietary_tags': <String>[],
      };
    }
  }
  
  /// Parse calories from Firebase response with better validation
  static double _parseCalories(dynamic calories) {
    if (calories is num) {
      final caloriesValue = calories.toDouble();
      if (caloriesValue <= 0 || caloriesValue > 10000) {
        print('⚠️ Invalid calories value: $caloriesValue, using default 250');
        return 250.0;
      }
      return caloriesValue;
    }
    if (calories is String) {
      final parsed = double.tryParse(calories) ?? 0.0;
      if (parsed <= 0 || parsed > 10000) {
        print('⚠️ Invalid parsed calories: $parsed, using default 250');
        return 250.0;
      }
      return parsed;
    }
    print('⚠️ Invalid calories format, using default 250');
    return 250.0;
  }
  
  /// Parse macros from Firebase response (handles "Xg" format) with fallback estimation
  static Map<String, double> _parseMacros(dynamic macros) {
    final result = <String, double>{
      'proteins': 0.0,
      'carbs': 0.0,
      'fats': 0.0,
    };
    
    if (macros is Map) {
      final macrosMap = Map<String, dynamic>.from(macros);
      
      // Handle "Xg" format from Firebase Functions
      result['proteins'] = _parseGramValue(macrosMap['proteins']);
      result['carbs'] = _parseGramValue(macrosMap['carbohydrates'] ?? macrosMap['carbs']);
      result['fats'] = _parseGramValue(macrosMap['fats']);
      
      print('🔍 Parsed macros: ${result}');
    }
    
    // Check for incomplete macro data - keep zeros instead of estimating fake values
    final totalMacros = result['proteins']! + result['carbs']! + result['fats']!;
    
    if (totalMacros == 0) {
      print('⚠️ No macro data available from analysis - keeping zeros');
      // Don't estimate fake values, let UI handle displaying "No data"
    } else if (result['proteins'] == 0 && result['fats'] == 0 && result['carbs']! > 0) {
      print('⚠️ Partial macro data - only carbs available from analysis');
      // Keep real carbs, zero protein/fat to show incomplete data
    }
    
    print('🔍 Final macros: proteins: ${result['proteins']}g, carbs: ${result['carbs']}g, fats: ${result['fats']}g');
    
    return result;
  }
  
  /// Parse gram values that come as "Xg" strings
  static double _parseGramValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      // Remove 'g' suffix and parse
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Estimate missing macro values based on typical meal ratios
  static Map<String, double> _estimateMissingMacros(Map<String, double> existingMacros, [dynamic originalMacros]) {
    final protein = existingMacros['proteins'] ?? 0.0;
    final carbs = existingMacros['carbs'] ?? 0.0;
    final fats = existingMacros['fats'] ?? 0.0;
    
    // If we have carbs but missing protein/fat, estimate typical meal ratios
    if (carbs > 0 && protein == 0 && fats == 0) {
      // Typical meal: 25% protein, 45% carbs, 30% fat (by calories)
      // 1g protein = 4 cal, 1g carbs = 4 cal, 1g fat = 9 cal
      final carbCalories = carbs * 4;
      final totalCalories = carbCalories / 0.45; // If carbs are 45% of calories
      
      final proteinCalories = totalCalories * 0.25;
      final fatCalories = totalCalories * 0.30;
      
      final estimatedProtein = proteinCalories / 4;
      final estimatedFat = fatCalories / 9;
      
      print('🔧 Estimated macros: protein: ${estimatedProtein.toStringAsFixed(1)}g, fat: ${estimatedFat.toStringAsFixed(1)}g');
      
      return {
        'proteins': estimatedProtein,
        'carbs': carbs, // Keep existing carbs
        'fats': estimatedFat,
      };
    }
    
    // If all macros are missing, provide basic estimates
    if (protein == 0 && carbs == 0 && fats == 0) {
      return {
        'proteins': 15.0, // Basic protein estimate
        'carbs': 30.0,    // Basic carbs estimate  
        'fats': 10.0,     // Basic fat estimate
      };
    }
    
    // Return original if no estimation needed
    return existingMacros;
  }
  
  /// Parse detailed ingredients from Firebase response
  static List<Map<String, dynamic>>? _parseDetailedIngredients(dynamic detailedIngredients) {
    if (detailedIngredients is List) {
      return detailedIngredients.map((ingredient) {
        if (ingredient is Map) {
          final ingredientMap = Map<String, dynamic>.from(ingredient);
          return {
            'name': ingredientMap['name'] ?? 'Unknown',
            'grams': (ingredientMap['grams'] ?? 100).toDouble(),
            'calories': (ingredientMap['calories'] ?? 0).toDouble(),
            'proteins': (ingredientMap['proteins'] ?? 0).toDouble(),
            'carbs': (ingredientMap['carbs'] ?? 0).toDouble(),
            'fats': (ingredientMap['fats'] ?? 0).toDouble(),
          };
        }
        return <String, dynamic>{
          'name': 'Unknown',
          'grams': 100.0,
          'calories': 0.0,
          'proteins': 0.0,
          'carbs': 0.0,
          'fats': 0.0,
        };
      }).toList();
    }
    return null;
  }
  
  /// Analyze meal image with retry logic and fallback to base64
  static Future<Map<String, dynamic>> analyzeMealImageWithRetry({
    required String imageUrl,
    required String imageName,
    File? imageFile,
    String? apiKey,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        // First try with URL
        return await analyzeMealImage(
          imageUrl: imageUrl,
          imageName: imageName,
          apiKey: apiKey,
        );
      } catch (e) {
        attempts++;
        print('❌ Firebase Functions URL analysis attempt $attempts failed: $e');
        
        // If we have a local file and this is our last attempt with URL, try base64
        if (imageFile != null && imageFile.existsSync() && attempts == maxRetries) {
          print('🔄 Falling back to base64 analysis...');
          try {
            return await analyzeMealImageBase64(
              imageFile: imageFile,
              imageName: imageName,
              apiKey: apiKey,
            );
          } catch (base64Error) {
            print('❌ Base64 analysis also failed: $base64Error');
            throw Exception('Both URL and base64 analysis failed. URL error: $e, Base64 error: $base64Error');
          }
        }
        
        if (attempts >= maxRetries) {
          print('❌ Max Firebase Functions analysis retries exceeded');
          rethrow;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Firebase Functions analysis failed after $maxRetries attempts');
  }

  /// Analyze meal image using only base64 (for when we want to bypass URL issues)
  static Future<Map<String, dynamic>> analyzeMealImageBase64WithRetry({
    required File imageFile,
    required String imageName,
    String? apiKey,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await analyzeMealImageBase64(
          imageFile: imageFile,
          imageName: imageName,
          apiKey: apiKey,
        );
      } catch (e) {
        attempts++;
        print('❌ Firebase Functions base64 analysis attempt $attempts failed: $e');
        
        if (attempts >= maxRetries) {
          print('❌ Max Firebase Functions base64 analysis retries exceeded');
          rethrow;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Firebase Functions base64 analysis failed after $maxRetries attempts');
  }
} 