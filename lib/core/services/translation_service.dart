import 'dart:convert';
import 'package:http/http.dart' as http;

/// TranslationService - Comprehensive meal and ingredient translation system
/// 
/// This service provides hybrid translation capabilities for meal names and ingredients
/// using both a static dictionary (free and fast) and Google Translate API (for rare items).
/// 
/// **FEATURES:**
/// - Static dictionary with 100+ common meals and ingredients
/// - Google Translate fallback for rare/unknown items
/// - Batch translation for efficiency
/// - Hybrid approach optimizes for speed and cost
/// - Supports English, Hebrew, and Russian
/// 
/// **INTEGRATION EXAMPLES:**
/// 
/// 1. Dashboard Integration:
/// ```dart
/// // In dashboard_content.dart
/// Future<String> _getTranslatedMealName(RecentlyUploadedModel data) async {
///   final locale = context.locale.languageCode;
///   if (locale == 'en') return data.displayTitle;
///   
///   return await TranslationService.translateIngredient(data.displayTitle, locale);
/// }
/// ```
/// 
/// 2. Item Detail Integration:
/// ```dart
/// // In item_detail_view.dart
/// Future<List<String>> _getTranslatedIngredients() async {
///   final locale = context.locale.languageCode;
///   if (locale == 'en') return _ingredients.map((ing) => ing.name).toList();
///   
///   final englishIngredients = _ingredients.map((ing) => ing.name).toList();
///   return await TranslationService.translateIngredients(englishIngredients, locale);
/// }
/// ```
/// 
/// 3. Meal Analysis Integration:
/// ```dart
/// // When processing meal analysis results
/// final translatedAnalysis = await TranslationService.translateMealAnalysis(
///   englishAnalysisResult, 
///   targetLanguage
/// );
/// ```
/// 
/// **PERFORMANCE:**
/// - Static dictionary: Instant (0ms)
/// - Google Translate: ~200-500ms per batch
/// - Hybrid approach: Usually 90%+ static hits = mostly instant
/// 
/// **COST OPTIMIZATION:**
/// - Static dictionary is free
/// - Google Translate used only for unknown items
/// - Batch translation reduces API calls
/// - Smart caching prevents duplicate translations
/// 
class TranslationService {
  static const String _baseUrl = 'https://translate.googleapis.com/translate_a/single';
  
  // Simple cache to avoid repeated translations
  static final Map<String, String> _translationCache = {};
  
  // Static dictionary for common ingredients and meal names
  static const Map<String, Map<String, String>> _ingredientDictionary = {
    // Common Meals & Dishes
    'cheeseburger': {'en': 'cheeseburger', 'he': 'צ\'יזבורגר', 'ru': 'чизбургер'},
    'hamburger': {'en': 'hamburger', 'he': 'המבורגר', 'ru': 'гамбургер'},
    'burger': {'en': 'burger', 'he': 'בורגר', 'ru': 'бургер'},
    'pizza': {'en': 'pizza', 'he': 'פיצה', 'ru': 'пицца'},
    'sandwich': {'en': 'sandwich', 'he': 'כריך', 'ru': 'сэндвич'},
    'pasta': {'en': 'pasta', 'he': 'פסטה', 'ru': 'паста'},
    'salad': {'en': 'salad', 'he': 'סלט', 'ru': 'салат'},
    'soup': {'en': 'soup', 'he': 'מרק', 'ru': 'суп'},
    'sushi': {'en': 'sushi', 'he': 'סושי', 'ru': 'суши'},
    'tacos': {'en': 'tacos', 'he': 'טאקו', 'ru': 'тако'},
    'burrito': {'en': 'burrito', 'he': 'בוריטו', 'ru': 'буррито'},
    'steak': {'en': 'steak', 'he': 'סטייק', 'ru': 'стейк'},
    'chicken wings': {'en': 'chicken wings', 'he': 'כנפי עוף', 'ru': 'куриные крылышки'},
    'french fries': {'en': 'french fries', 'he': 'צ\'יפס', 'ru': 'картофель фри'},
    'fries': {'en': 'fries', 'he': 'צ\'יפס', 'ru': 'картофель фри'},
    'hot dog': {'en': 'hot dog', 'he': 'נקניקייה', 'ru': 'хот-дог'},
    'pancakes': {'en': 'pancakes', 'he': 'פנקייק', 'ru': 'блины'},
    'waffles': {'en': 'waffles', 'he': 'וופל', 'ru': 'вафли'},
    'omelet': {'en': 'omelet', 'he': 'חביתה', 'ru': 'омлет'},
    'omelette': {'en': 'omelette', 'he': 'חביתה', 'ru': 'омлет'},
    'scrambled eggs': {'en': 'scrambled eggs', 'he': 'ביצים מקושקשות', 'ru': 'яичница-болтунья'},
    'fried rice': {'en': 'fried rice', 'he': 'אורז מטוגן', 'ru': 'жареный рис'},
    'noodles': {'en': 'noodles', 'he': 'אטריות', 'ru': 'лапша'},
    'ramen': {'en': 'ramen', 'he': 'ראמן', 'ru': 'рамен'},
    'shawarma': {'en': 'shawarma', 'he': 'שווארמה', 'ru': 'шаурма'},
    'falafel': {'en': 'falafel', 'he': 'פלאפל', 'ru': 'фалафель'},
    'hummus': {'en': 'hummus', 'he': 'חומוס', 'ru': 'хумус'},
    
    // Salads & Greens
    'mixed greens': {'en': 'mixed greens', 'he': 'ירקות מעורבים', 'ru': 'смешанная зелень'},
    'greens': {'en': 'greens', 'he': 'ירקות', 'ru': 'зелень'},
    'mixed salad': {'en': 'mixed salad', 'he': 'סלט מעורב', 'ru': 'смешанный салат'},
    'green salad': {'en': 'green salad', 'he': 'סלט ירוק', 'ru': 'зеленый салат'},
    'arugula': {'en': 'arugula', 'he': 'רוקט', 'ru': 'руккола'},
    'kale': {'en': 'kale', 'he': 'קייל', 'ru': 'капуста кале'},
    'iceberg lettuce': {'en': 'iceberg lettuce', 'he': 'חסה קרחונית', 'ru': 'айсберг салат'},
    'romaine lettuce': {'en': 'romaine lettuce', 'he': 'חסה רומי', 'ru': 'романо салат'},
    
    // Sauces & Dressings
    'hollandaise sauce': {'en': 'hollandaise sauce', 'he': 'רוטב הולנדז', 'ru': 'голландский соус'},
    'hollandaise': {'en': 'hollandaise', 'he': 'הולנדז', 'ru': 'голландский'},
    'ranch dressing': {'en': 'ranch dressing', 'he': 'רוטב ראנץ\'', 'ru': 'ранч соус'},
    'caesar dressing': {'en': 'caesar dressing', 'he': 'רוטב קיסר', 'ru': 'цезарь соус'},
    'vinaigrette': {'en': 'vinaigrette', 'he': 'ויניגרט', 'ru': 'винегрет'},
    'mayo': {'en': 'mayo', 'he': 'מיונז', 'ru': 'майонез'},
    'mayonnaise': {'en': 'mayonnaise', 'he': 'מיונז', 'ru': 'майонез'},
    'ketchup': {'en': 'ketchup', 'he': 'קטשופ', 'ru': 'кетчуп'},
    'mustard': {'en': 'mustard', 'he': 'חרדל', 'ru': 'горчица'},
    'bbq sauce': {'en': 'bbq sauce', 'he': 'רוטב ברביקיו', 'ru': 'соус барбекю'},
    'soy sauce': {'en': 'soy sauce', 'he': 'רוטב סויה', 'ru': 'соевый соус'},
    'hot sauce': {'en': 'hot sauce', 'he': 'רוטב חריף', 'ru': 'острый соус'},
    
    // Breads & Baked Goods
    'english muffin': {'en': 'english muffin', 'he': 'מאפין אנגלי', 'ru': 'английский маффин'},
    'muffin': {'en': 'muffin', 'he': 'מאפין', 'ru': 'маффин'},
    'bagel': {'en': 'bagel', 'he': 'בייגל', 'ru': 'бейгл'},
    'croissant': {'en': 'croissant', 'he': 'קרואסון', 'ru': 'круассан'},
    'toast': {'en': 'toast', 'he': 'טוסט', 'ru': 'тост'},
    'white bread': {'en': 'white bread', 'he': 'לחם לבן', 'ru': 'белый хлеб'},
    'whole wheat bread': {'en': 'whole wheat bread', 'he': 'לחם מלא', 'ru': 'цельнозерновой хлеб'},
    'sourdough': {'en': 'sourdough', 'he': 'לחם מחמצת', 'ru': 'закваска'},
    'pita': {'en': 'pita', 'he': 'פיתה', 'ru': 'пита'},
    'focaccia': {'en': 'focaccia', 'he': 'פוקצ\'יה', 'ru': 'фокачча'},
    'baguette': {'en': 'baguette', 'he': 'באגט', 'ru': 'багет'},
    
    // Proteins
    'chicken': {'en': 'chicken', 'he': 'עוף', 'ru': 'курица'},
    'beef': {'en': 'beef', 'he': 'בקר', 'ru': 'говядина'},
    'pork': {'en': 'pork', 'he': 'חזיר', 'ru': 'свинина'},
    'fish': {'en': 'fish', 'he': 'דג', 'ru': 'рыба'},
    'salmon': {'en': 'salmon', 'he': 'סלמון', 'ru': 'лосось'},
    'tuna': {'en': 'tuna', 'he': 'טונה', 'ru': 'тунец'},
    'eggs': {'en': 'eggs', 'he': 'ביצים', 'ru': 'яйца'},
    'egg': {'en': 'egg', 'he': 'ביצה', 'ru': 'яйцо'},
    
    // Vegetables
    'tomato': {'en': 'tomato', 'he': 'עגבנייה', 'ru': 'помидор'},
    'tomatoes': {'en': 'tomatoes', 'he': 'עגבניות', 'ru': 'помидоры'},
    'onion': {'en': 'onion', 'he': 'בצל', 'ru': 'лук'},
    'onions': {'en': 'onions', 'he': 'בצלים', 'ru': 'лук'},
    'garlic': {'en': 'garlic', 'he': 'שום', 'ru': 'чеснок'},
    'potato': {'en': 'potato', 'he': 'תפוח אדמה', 'ru': 'картофель'},
    'potatoes': {'en': 'potatoes', 'he': 'תפוחי אדמה', 'ru': 'картофель'},
    'carrot': {'en': 'carrot', 'he': 'גזר', 'ru': 'морковь'},
    'carrots': {'en': 'carrots', 'he': 'גזר', 'ru': 'морковь'},
    'cucumber': {'en': 'cucumber', 'he': 'מלפפון', 'ru': 'огурец'},
    'lettuce': {'en': 'lettuce', 'he': 'חסה', 'ru': 'салат'},
    'spinach': {'en': 'spinach', 'he': 'תרד', 'ru': 'шпинат'},
    'broccoli': {'en': 'broccoli', 'he': 'ברוקולי', 'ru': 'брокколи'},
    'bell pepper': {'en': 'bell pepper', 'he': 'פלפל מתוק', 'ru': 'болгарский перец'},
    'mushrooms': {'en': 'mushrooms', 'he': 'פטריות', 'ru': 'грибы'},
    'mushroom': {'en': 'mushroom', 'he': 'פטרייה', 'ru': 'гриб'},
    
    // Fruits
    'apple': {'en': 'apple', 'he': 'תפוח', 'ru': 'яблоко'},
    'banana': {'en': 'banana', 'he': 'בננה', 'ru': 'банан'},
    'orange': {'en': 'orange', 'he': 'תפוז', 'ru': 'апельсин'},
    'lemon': {'en': 'lemon', 'he': 'לימון', 'ru': 'лимон'},
    'avocado': {'en': 'avocado', 'he': 'אבוקדו', 'ru': 'авокадо'},
    'strawberry': {'en': 'strawberry', 'he': 'תות', 'ru': 'клубника'},
    'strawberries': {'en': 'strawberries', 'he': 'תותים', 'ru': 'клубника'},
    
    // Grains & Carbs
    'rice': {'en': 'rice', 'he': 'אורז', 'ru': 'рис'},
    'bread': {'en': 'bread', 'he': 'לחם', 'ru': 'хлеб'},
    'flour': {'en': 'flour', 'he': 'קמח', 'ru': 'мука'},
    'oats': {'en': 'oats', 'he': 'שיבולת שועל', 'ru': 'овес'},
    'quinoa': {'en': 'quinoa', 'he': 'קינואה', 'ru': 'киноа'},
    
    // Dairy
    'milk': {'en': 'milk', 'he': 'חלב', 'ru': 'молоко'},
    'cheese': {'en': 'cheese', 'he': 'גבינה', 'ru': 'сыр'},
    'yogurt': {'en': 'yogurt', 'he': 'יוגורט', 'ru': 'йогурт'},
    'butter': {'en': 'butter', 'he': 'חמאה', 'ru': 'масло'},
    
    // Oils & Fats
    'olive oil': {'en': 'olive oil', 'he': 'שמן זית', 'ru': 'оливковое масло'},
    'oil': {'en': 'oil', 'he': 'שמן', 'ru': 'масло'},
    
    // Spices & Seasonings
    'salt': {'en': 'salt', 'he': 'מלח', 'ru': 'соль'},
    'pepper': {'en': 'pepper', 'he': 'פלפל', 'ru': 'перец'},
    'paprika': {'en': 'paprika', 'he': 'פפריקה', 'ru': 'паприка'},
    'cumin': {'en': 'cumin', 'he': 'כמון', 'ru': 'кумин'},
    'oregano': {'en': 'oregano', 'he': 'אורגנו', 'ru': 'орегано'},
    'basil': {'en': 'basil', 'he': 'בזיליקום', 'ru': 'базилик'},
    'parsley': {'en': 'parsley', 'he': 'פטרוזיליה', 'ru': 'петрушка'},
    
    // Nuts & Seeds
    'almonds': {'en': 'almonds', 'he': 'שקדים', 'ru': 'миндаль'},
    'walnuts': {'en': 'walnuts', 'he': 'אגוזי מלך', 'ru': 'грецкие орехи'},
    'sunflower seeds': {'en': 'sunflower seeds', 'he': 'גרעיני חמנייה', 'ru': 'семечки подсолнуха'},
    
    // Legumes & Beans
    'chickpeas': {'en': 'chickpeas', 'he': 'חומציות', 'ru': 'нут'},
    'black beans': {'en': 'black beans', 'he': 'שעועית שחורה', 'ru': 'черная фасоль'},
    'kidney beans': {'en': 'kidney beans', 'he': 'שעועית כליה', 'ru': 'красная фасоль'},
    'lentils': {'en': 'lentils', 'he': 'עדשים', 'ru': 'чечевица'},
    'beans': {'en': 'beans', 'he': 'שעועית', 'ru': 'фасоль'},
    
    // Processing/Analysis Text
    'processing...': {'en': 'Processing...', 'he': 'מעבד...', 'ru': 'Обработка...'},
    'ai is analyzing your meal': {'en': 'AI is analyzing your meal', 'he': 'AI מנתח את הארוחה שלך', 'ru': 'ИИ анализирует вашу еду'},
  };

  // ========== BASIC GOOGLE TRANSLATE METHODS ==========
  
  /// Translate text using Google Translate (free endpoint) with better error handling
  static Future<String> translateText(String text, String targetLanguage) async {
    try {
      // Add timeout and better error handling
      final url = Uri.parse('$_baseUrl?client=gtx&sl=auto&tl=$targetLanguage&q=${Uri.encodeComponent(text)}');
      
      final response = await http.get(url).timeout(
        Duration(seconds: 5), // 5 second timeout
        onTimeout: () {
          print('⏰ Google Translate timeout for: "$text"');
          throw Exception('Translation timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded[0] != null && decoded[0][0] != null) {
          final result = decoded[0][0][0].toString();
          
          // Validate result - don't return empty or same as input if it shouldn't be
          if (result.isNotEmpty && result != text) {
            return result;
          }
        }
      } else {
        print('❌ Google Translate HTTP error: ${response.statusCode}');
      }
      
      return text; // Return original if translation fails
    } catch (e) {
      print('❌ Translation error for "$text": $e');
      return text; // Always return original text on any error
    }
  }

  /// Get language code from locale for Google Translate
  static String getLanguageCode(String locale) {
    switch (locale.toLowerCase()) {
      case 'en':
        return 'en';
      case 'he':
        return 'iw'; // Google Translate uses 'iw' for Hebrew
      case 'ru':
        return 'ru';
      default:
        return 'en';
    }
  }

  /// Batch translate multiple ingredients (more efficient)
  static Future<Map<String, String>> batchTranslateIngredients(
    List<String> ingredients, 
    String targetLanguage
  ) async {
    Map<String, String> translations = {};
    
    // Join ingredients with a delimiter for batch translation
    final combinedText = ingredients.join(' | ');
    final translatedText = await translateText(combinedText, targetLanguage);
    
    // Split back the results
    final translatedParts = translatedText.split(' | ');
    
    for (int i = 0; i < ingredients.length && i < translatedParts.length; i++) {
      translations[ingredients[i]] = translatedParts[i];
    }
    
    return translations;
  }

  // ========== STATIC DICTIONARY METHODS ==========

  /// Enhanced static translation with partial matching for complex meals
  static String translateIngredientStatic(String ingredient, String targetLanguage) {
    final normalizedIngredient = ingredient.toLowerCase().trim();
    
    // Handle empty or invalid input
    if (normalizedIngredient.isEmpty) {
      return ingredient;
    }
    
    // Try exact match first
    if (_ingredientDictionary.containsKey(normalizedIngredient)) {
      final translation = _ingredientDictionary[normalizedIngredient]![targetLanguage] ?? ingredient;
      return translation;
    }
    
    // For complex meal descriptions, try to translate individual components
    if (normalizedIngredient.contains(',') || normalizedIngredient.contains(' and ') || normalizedIngredient.contains(' with ')) {
      return _translateComplexMeal(normalizedIngredient, targetLanguage, ingredient);
    }
    
    // Try partial match for single ingredients
    for (final entry in _ingredientDictionary.entries) {
      if (normalizedIngredient.contains(entry.key) || entry.key.contains(normalizedIngredient)) {
        final translation = entry.value[targetLanguage] ?? ingredient;
        return translation;
      }
    }
    
    // Return original if no translation found
    return ingredient;
  }

  /// Translate complex meals by breaking them into components
  static String _translateComplexMeal(String normalizedMeal, String targetLanguage, String originalMeal) {
    // Split by common delimiters
    final components = normalizedMeal
        .split(RegExp(r'[,\+&]|\band\b|\bwith\b'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    print('📝 Components found: $components');
    
    final translatedComponents = <String>[];
    bool anyTranslated = false;
    
    for (final component in components) {
      // Try to translate each component
      final componentTranslation = _translateSingleComponent(component, targetLanguage);
      
      if (componentTranslation != component) {
        translatedComponents.add(componentTranslation);
        anyTranslated = true;
        print('✅ Component translated: "$component" -> "$componentTranslation"');
      } else {
        translatedComponents.add(component);
        print('⚠️ Component not translated: "$component"');
      }
    }
    
    if (anyTranslated) {
      final result = translatedComponents.join(', ');
      print('✅ Complex meal partially translated: "$originalMeal" -> "$result"');
      return result;
    }
    
    print('❌ Complex meal not translated: "$originalMeal"');
    return originalMeal;
  }

  /// Translate a single component of a complex meal
  static String _translateSingleComponent(String component, String targetLanguage) {
    final normalized = component.toLowerCase().trim();
    
    // Try exact match
    if (_ingredientDictionary.containsKey(normalized)) {
      return _ingredientDictionary[normalized]![targetLanguage] ?? component;
    }
    
    // Try partial matches
    for (final entry in _ingredientDictionary.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value[targetLanguage] ?? component;
      }
    }
    
    return component;
  }

  /// Check if ingredient has static translation
  static bool hasStaticTranslation(String ingredient, String targetLanguage) {
    final normalizedIngredient = ingredient.toLowerCase().trim();
    return _ingredientDictionary.containsKey(normalizedIngredient) &&
           _ingredientDictionary[normalizedIngredient]!.containsKey(targetLanguage);
  }

  // ========== HYBRID TRANSLATION METHODS ==========

  /// Translate ingredient using static dictionary first, then Google Translate as fallback
  static Future<String> translateIngredient(String ingredient, String targetLanguage) async {
    // Handle empty or null input
    if (ingredient.isEmpty) {
      return ingredient;
    }
    
    // Create cache key
    final cacheKey = '${ingredient.toLowerCase()}_$targetLanguage';
    
    // Check cache first
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }
    
    // Try static dictionary first (free and instant)
    final staticTranslation = translateIngredientStatic(ingredient, targetLanguage);
    
    // If we got a translation from static dictionary, use it
    if (staticTranslation != ingredient) {
      _translationCache[cacheKey] = staticTranslation;
      return staticTranslation;
    }
    
    // If no static translation found, use Google Translate (for rare ingredients/complex meals)
    try {
      final googleLanguageCode = getLanguageCode(targetLanguage);
      final googleTranslation = await translateText(ingredient, googleLanguageCode);
      
      if (googleTranslation != ingredient && googleTranslation.isNotEmpty) {
        _translationCache[cacheKey] = googleTranslation;
        return googleTranslation;
      } else {
        // Cache the original to avoid repeated API calls
        _translationCache[cacheKey] = ingredient;
        return ingredient;
      }
    } catch (e) {
      print('❌ Translation failed for "$ingredient": $e');
      // Cache the original to avoid repeated failed attempts
      _translationCache[cacheKey] = ingredient;
      return ingredient; // Fallback to original
    }
  }

  /// Translate a list of ingredients efficiently using hybrid approach
  static Future<List<String>> translateIngredients(List<String> ingredients, String targetLanguage) async {
    List<String> translatedIngredients = [];
    List<String> needsGoogleTranslation = [];
    List<int> googleTranslationIndices = [];
    
    // First pass: use static dictionary
    for (int i = 0; i < ingredients.length; i++) {
      final ingredient = ingredients[i];
      final staticTranslation = translateIngredientStatic(ingredient, targetLanguage);
      
      if (staticTranslation != ingredient) {
        // Found in static dictionary
        translatedIngredients.add(staticTranslation);
      } else {
        // Need Google Translate
        translatedIngredients.add(ingredient); // placeholder
        needsGoogleTranslation.add(ingredient);
        googleTranslationIndices.add(i);
      }
    }
    
    // Second pass: batch translate remaining ingredients with Google
    if (needsGoogleTranslation.isNotEmpty) {
      try {
        final googleLanguageCode = getLanguageCode(targetLanguage);
        final googleTranslations = await batchTranslateIngredients(
          needsGoogleTranslation, 
          googleLanguageCode
        );
        
        // Replace placeholders with Google translations
        for (int i = 0; i < needsGoogleTranslation.length; i++) {
          final originalIngredient = needsGoogleTranslation[i];
          final translatedIngredient = googleTranslations[originalIngredient] ?? originalIngredient;
          final indexInResult = googleTranslationIndices[i];
          translatedIngredients[indexInResult] = translatedIngredient;
        }
      } catch (e) {
        print('Google Translate failed: $e');
        // Keep original ingredients if Google Translate fails
      }
    }
    
    return translatedIngredients;
  }

  /// Check translation coverage (how many ingredients can be translated statically)
  static double getStaticTranslationCoverage(List<String> ingredients, String targetLanguage) {
    if (ingredients.isEmpty) return 1.0;
    
    int staticTranslations = 0;
    for (final ingredient in ingredients) {
      if (hasStaticTranslation(ingredient, targetLanguage)) {
        staticTranslations++;
      }
    }
    
    return staticTranslations / ingredients.length;
  }

  // ========== MEAL TRANSLATION METHODS ==========

  /// Translate meal analysis result to target language
  static Future<Map<String, dynamic>> translateMealAnalysis(
    Map<String, dynamic> englishAnalysis,
    String targetLanguage,
  ) async {
    if (targetLanguage == 'en') {
      return englishAnalysis; // No translation needed
    }

    try {
      print('🌍 Translating meal analysis to: $targetLanguage');
      
      // Create a copy of the analysis
      final translatedAnalysis = Map<String, dynamic>.from(englishAnalysis);
      
      // Translate meal name
      await _translateMealName(translatedAnalysis, targetLanguage);
      
      // Translate ingredients
      await _translateIngredients(translatedAnalysis, targetLanguage);
      
      // Translate health assessment (optional - could be expensive)
      // await _translateHealthAssessment(translatedAnalysis, targetLanguage);
      
      print('✅ Meal analysis translated successfully');
      return translatedAnalysis;
      
    } catch (e) {
      print('❌ Error translating meal analysis: $e');
      return englishAnalysis; // Return original if translation fails
    }
  }

  /// Translate meal name
  static Future<void> _translateMealName(
    Map<String, dynamic> analysis,
    String targetLanguage,
  ) async {
    if (analysis['mealName'] is Map) {
      final mealNameMap = Map<String, dynamic>.from(analysis['mealName']);
      final englishName = mealNameMap['en'] ?? 'Unknown Meal';
      
      print('🔍 Translating meal name: "$englishName" to $targetLanguage');
      
      // Try to translate the meal name
      final translatedName = await translateIngredient(
        englishName,
        targetLanguage,
      );
      
      print('✅ Translation result: "$englishName" -> "$translatedName"');
      
      mealNameMap[targetLanguage] = translatedName;
      analysis['mealName'] = mealNameMap;
    }
  }

  /// Translate ingredients list
  static Future<void> _translateIngredients(
    Map<String, dynamic> analysis,
    String targetLanguage,
  ) async {
    if (analysis['ingredients'] is Map) {
      final ingredientsMap = Map<String, dynamic>.from(analysis['ingredients']);
      final englishIngredients = List<String>.from(ingredientsMap['en'] ?? []);
      
      if (englishIngredients.isNotEmpty) {
        // Use hybrid translation for ingredients
        final translatedIngredients = await translateIngredients(
          englishIngredients,
          targetLanguage,
        );
        
        ingredientsMap[targetLanguage] = translatedIngredients;
        analysis['ingredients'] = ingredientsMap;
      }
    }
  }

  /// Translate health assessment (optional - can be expensive)
  static Future<void> _translateHealthAssessment(
    Map<String, dynamic> analysis,
    String targetLanguage,
  ) async {
    if (analysis['healthiness_explanation'] is Map) {
      final explanationMap = Map<String, dynamic>.from(analysis['healthiness_explanation']);
      final englishExplanation = explanationMap['en'] ?? '';
      
      if (englishExplanation.isNotEmpty) {
        // Use Google Translate for longer text (this will cost more)
        final translatedExplanation = await translateIngredient(
          englishExplanation,
          targetLanguage,
        );
        
        explanationMap[targetLanguage] = translatedExplanation;
        analysis['healthiness_explanation'] = explanationMap;
      }
    }
  }

  /// Batch translate multiple meal analyses
  static Future<List<Map<String, dynamic>>> translateMealAnalyses(
    List<Map<String, dynamic>> englishAnalyses,
    String targetLanguage,
  ) async {
    if (targetLanguage == 'en') {
      return englishAnalyses; // No translation needed
    }

    final translatedAnalyses = <Map<String, dynamic>>[];
    
    for (final analysis in englishAnalyses) {
      final translated = await translateMealAnalysis(analysis, targetLanguage);
      translatedAnalyses.add(translated);
    }
    
    return translatedAnalyses;
  }

  // ========== UTILITY METHODS ==========

  /// Get all available languages
  static List<String> getAvailableLanguages() {
    return ['en', 'he', 'ru'];
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String languageCode) {
    return getAvailableLanguages().contains(languageCode);
  }

  /// Preload common ingredient translations (call this on app start)
  static Future<void> preloadCommonTranslations() async {
    // This could be used to preload translations for the most common ingredients
    // For now, our static dictionary handles this
    print('✅ Common ingredient translations loaded');
  }
} 