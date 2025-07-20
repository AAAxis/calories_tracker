import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/core/services/nutrition_database_service.dart';
import 'package:calories_tracker/core/services/translation_service.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key, this.initialIngredients});
  final List<Ingredient>? initialIngredients;

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  late List<Ingredient> _ingredients;
  List<String> _allIngredientNames = [];
  List<String> _filteredIngredientNames = [];
  String? _selectedIngredientName;
  double _selectedGrams = 100;
  final TextEditingController _searchController = TextEditingController();
  
  // Translation cache for improved search performance
  Map<String, String> _translationCache = {};
  String _currentLocale = 'en';

  @override
  void initState() {
    super.initState();
    _ingredients = widget.initialIngredients ?? <Ingredient>[];
    // Don't access context.locale in initState - will be set in build method
    NutritionDatabaseService.initialize().then((_) {
      setState(() {
        _allIngredientNames = NutritionDatabaseService.getAllIngredients();
        _filteredIngredientNames = _allIngredientNames;
      });
      // Preload translations will be called from build method when locale is available
    });
    _searchController.addListener(_filterIngredients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get localized search hint
  String _getSearchHint() {
    try {
      final locale = context.locale.languageCode;
      switch (locale) {
        case 'he':
          return 'חפש מרכיב...';
        case 'ru':
          return 'Поиск ингредиента...';
        default:
          return 'ingredients.search_hint'.tr();
      }
    } catch (e) {
      // Fallback if context is not ready
      return 'Search any ingredient...';
    }
  }

  /// Preload translations for all ingredient names to improve search performance
  Future<void> _preloadTranslations() async {
    if (_currentLocale == 'en') return; // No need to preload for English
    
    print('🔄 Preloading translations for locale: $_currentLocale');
    
    try {
      // Batch translate for efficiency - translate in chunks of 50
      const int batchSize = 50;
      final batches = <List<String>>[];
      
      for (int i = 0; i < _allIngredientNames.length; i += batchSize) {
        final end = (i + batchSize < _allIngredientNames.length) 
            ? i + batchSize 
            : _allIngredientNames.length;
        batches.add(_allIngredientNames.sublist(i, end));
      }
      
      for (final batch in batches) {
        final translatedBatch = await TranslationService.translateIngredients(batch, _currentLocale);
        
        for (int i = 0; i < batch.length; i++) {
          final englishName = batch[i];
          final translatedName = translatedBatch[i];
          
          _translationCache[englishName] = translatedName;
          _translationCache[translatedName.toLowerCase()] = englishName; // Reverse mapping for search
        }
      }
      
      print('✅ Preloaded ${_translationCache.length ~/ 2} translations in ${batches.length} batches');
    } catch (e) {
      print('❌ Error preloading translations: $e');
    }
  }

  /// Enhanced multilingual ingredient filtering
  void _filterIngredients() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      if (query.isEmpty) {
        _filteredIngredientNames = _allIngredientNames;
        return;
      }

      // Search both English and translated names
      _filteredIngredientNames = _allIngredientNames.where((englishName) {
        final englishNameLower = englishName.toLowerCase();
        
        // 1. Direct English match
        if (englishNameLower.contains(query)) {
          return true;
        }
        
        // 2. Translated name match (if not English and locale is set)
        if (_currentLocale != 'en' && _currentLocale.isNotEmpty) {
          final translatedName = _translationCache[englishName];
          if (translatedName != null && translatedName.toLowerCase().contains(query)) {
            return true;
          }
        }
        
        // 3. Reverse translation match (user searches in native language)
        if (_currentLocale != 'en' && _currentLocale.isNotEmpty) {
          // Check if the query might be a translated term that maps back to this English ingredient
          final potentialEnglishName = _translationCache[query];
          if (potentialEnglishName == englishName) {
            return true;
          }
          
          // Partial reverse translation match
          for (final translatedTerm in _translationCache.keys) {
            if (translatedTerm.contains(query) && _translationCache[translatedTerm] == englishName) {
              return true;
            }
          }
        }
        
        return false;
      }).toList();
      
      print('🔍 Search "$query" found ${_filteredIngredientNames.length} results');
    });
  }

  void _addIngredientFromSuggestion(String name) {
    final nutrition = NutritionDatabaseService.calculateNutrition(name, 100);
    final ingredient = Ingredient(
      name: name,
      grams: 100,
      calories: nutrition['calories'] ?? 0,
      protein: nutrition['proteins'] ?? 0,
      carbs: nutrition['carbs'] ?? 0,
      fat: nutrition['fats'] ?? 0,
    );
    setState(() {
      _ingredients.add(ingredient);
    });
  }

  void _onSuggestionTap(String name) async {
    final nutrition = NutritionDatabaseService.calculateNutrition(name, 100);
    final ingredient = Ingredient(
      name: name,
      grams: 100,
      calories: nutrition['calories'] ?? 0,
      protein: nutrition['proteins'] ?? 0,
      carbs: nutrition['carbs'] ?? 0,
      fat: nutrition['fats'] ?? 0,
    );
    final editedIngredient = await context.push('/edit-ingredients', extra: ingredient);
    
    if (editedIngredient is Ingredient) {
      Navigator.pop(context, editedIngredient);
    }
  }

  /// Get translated ingredient name for search results display
  Future<String> _getTranslatedIngredientName(String ingredientName) async {
    try {
      // Safe locale access
      final locale = _currentLocale.isNotEmpty ? _currentLocale : 'en';
      
      // If already in English, no need to translate
      if (locale == 'en') {
        return ingredientName;
      }
      
      // Check cache first
      if (_translationCache.containsKey(ingredientName)) {
        return _translationCache[ingredientName]!;
      }
      
      // Translate using TranslationService
      final translatedName = await TranslationService.translateIngredient(
        ingredientName,
        locale,
      );
      
      // Cache the result
      _translationCache[ingredientName] = translatedName;
      
      return translatedName;
    } catch (e) {
      print('❌ Error translating ingredient name: $e');
      return ingredientName; // Fallback to original
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize or update locale and translations
    final currentLocale = context.locale.languageCode;
    if (currentLocale != _currentLocale) {
      _currentLocale = currentLocale;
      _translationCache.clear();
      
      // Only preload if ingredient names are available
      if (_allIngredientNames.isNotEmpty) {
        // Use Future.microtask to avoid calling setState during build
        Future.microtask(() => _preloadTranslations());
      }
    }
    
    // Trigger preload if locale is set but translations haven't been loaded yet
    if (_currentLocale.isNotEmpty && 
        _allIngredientNames.isNotEmpty && 
        _translationCache.isEmpty && 
        _currentLocale != 'en') {
      Future.microtask(() => _preloadTranslations());
    }
    
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Wrapper(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackActions(),
              SizedBox(height: 20.h(context)),
              // Search bar
              Container(
                width: w,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 10),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.search, color: Color(0xff999999)),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Color(0xff999999)),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    hintText: _getSearchHint(),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff999999),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h(context)),
              Text(
                _searchController.text.isNotEmpty 
                    ? '${_filteredIngredientNames.length} ${'ingredients.search_results'.tr()}'
                    : 'ingredients.suggestions'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
                              // Ingredients list
                Expanded(
                  child: _filteredIngredientNames.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'ingredients.no_results'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'ingredients.try_different_search'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(top: 10),
                          itemBuilder: (context, index) {
                            final name = _filteredIngredientNames[index];
                            final nutrition = NutritionDatabaseService.calculateNutrition(name, 100);
                            return FutureBuilder<String>(
                              future: _getTranslatedIngredientName(name),
                              builder: (context, snapshot) {
                                final translatedName = snapshot.data ?? name;
                                
                                return GestureDetector(
                                  onTap: () => _onSuggestionTap(name),
                                  child: Container(
                                    width: w,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/icons/suggestion-glass.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.local_fire_department,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        translatedName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${nutrition['calories']?.toStringAsFixed(0) ?? '--'} kcal, 100g',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      trailing: Icon(Icons.add, color: Colors.black),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, __) => SizedBox(height: 8),
                          itemCount: _filteredIngredientNames.length,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



class BackActions extends StatelessWidget {
  const BackActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Image.asset('assets/icons/ingredients-back.png', height: 50),
          ),
          Text(
            'ingredients.add_ingredients'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}
