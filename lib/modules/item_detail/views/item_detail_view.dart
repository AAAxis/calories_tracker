import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/core/services/image_cache_service.dart';
import 'package:calories_tracker/core/services/translation_service.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';

class ItemDetailView extends StatefulWidget {
  const ItemDetailView({super.key, required this.meal});
  final Meal meal;

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  late List<Ingredient> _ingredients;
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  String? _editedMealName;

  @override
  void initState() {
    super.initState();
    // Use meal.detailedIngredients if available, fallback to empty list
    _ingredients = widget.meal.detailedIngredients ?? <Ingredient>[];
    
    // Initialize macros with meal's values first
    _calories = widget.meal.calories;
    _protein = widget.meal.protein;
    _carbs = widget.meal.carbs;
    _fat = widget.meal.fat;
    
    // Only recalculate if we have detailed ingredients
    if (_ingredients.isNotEmpty) {
      _recalculateMacros();
    }
  }

  void _recalculateMacros() {
    if (_ingredients.isNotEmpty) {
      // Recalculate from ingredients
      _calories = _ingredients.fold(0, (sum, ing) => sum + ing.calories);
      _protein = _ingredients.fold(0, (sum, ing) => sum + ing.protein);
      _carbs = _ingredients.fold(0, (sum, ing) => sum + ing.carbs);
      _fat = _ingredients.fold(0, (sum, ing) => sum + ing.fat);
    } else {
      // Use meal's original values if no detailed ingredients
      _calories = widget.meal.calories;
      _protein = widget.meal.protein;
      _carbs = widget.meal.carbs;
      _fat = widget.meal.fat;
    }
    
    // Update the meal in the dashboard
    _updateMealInDashboard();
  }

  void _updateMealInDashboard() {
    try {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      
      // Create updated meal with new nutrition values and ingredients
      final updatedMeal = Meal(
        id: widget.meal.id,
        name: _editedMealName ?? widget.meal.name, // Required name parameter
        imageUrl: widget.meal.imageUrl,
        localImagePath: widget.meal.localImagePath,
        timestamp: widget.meal.timestamp,
        userId: widget.meal.userId,
        calories: _calories,
        protein: _protein,
        fat: _fat,
        carbs: _carbs,
        detailedIngredients: _ingredients,
        mealName: _editedMealName, // Use edited name if available
        isAnalyzing: false,
        analysisFailed: false,
      );
      
      // Update the meal in dashboard provider
      final updatedMeals = dashboardProvider.meals.map((meal) {
        if (meal.id == widget.meal.id) {
          return updatedMeal;
        }
        return meal;
      }).toList();
      
      // Save updated meal to local storage
      Meal.updateInLocalStorage(updatedMeal);
      
      // Update dashboard provider
      dashboardProvider.updateMeals(updatedMeals);
      
      print('✅ Updated meal in dashboard: ${updatedMeal.calories} calories, ${_ingredients.length} ingredients');
    } catch (e) {
      print('❌ Error updating meal in dashboard: $e');
    }
  }

  Widget _buildMealImage(Meal meal, double w, double h) {
    // Try to find a valid image source
    String? imageSource;
    if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty) {
      imageSource = meal.imageUrl!;
    } else if (meal.localImagePath != null && meal.localImagePath!.isNotEmpty) {
      imageSource = meal.localImagePath!;
    }

    if (imageSource == null || imageSource.isEmpty) {
      return Container(
        width: w,
        height: h * .65,
        color: Colors.grey[200],
        child: Icon(
          Icons.restaurant,
          color: Colors.grey[400],
          size: 64,
        ),
      );
    }

    return ImageCacheService.getCachedImage(
      imageSource,
      width: w,
      height: h * .75,
      fit: BoxFit.cover,
      placeholder: Container(
        width: w,
        height: h * .65,
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
      ),
      errorWidget: Container(
        width: w,
        height: h * .65,
        color: Colors.grey[200],
        child: Icon(
          Icons.broken_image,
          color: Colors.grey[400],
          size: 64,
        ),
      ),
    );
  }

  void _addIngredient(Ingredient ingredient) {
    setState(() {
      _ingredients.add(ingredient);
      _recalculateMacros();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('item_detail.meal_updated'.tr())),
    );
  }

  void _deleteIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _recalculateMacros();
    });
  }

  void _deleteIngredientWithDialog(int index) async {
    // Get translated ingredient name for the dialog
    final translatedIngredientNames = await _getTranslatedIngredients();
    final ingredientName = index < translatedIngredientNames.length 
        ? translatedIngredientNames[index] 
        : _ingredients[index].name;
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('item_detail.remove_ingredient'.tr()),
        content: Text('${'item_detail.remove_ingredient_question'.tr()} "$ingredientName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('item_detail.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('item_detail.remove'.tr()),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      setState(() {
        _ingredients.removeAt(index);
        _recalculateMacros();
      });
    }
  }

  Future<void> _showRenameMealDialog() async {
    final controller = TextEditingController(text: _editedMealName ?? widget.meal.getDisplayName());
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('item_detail.rename_meal'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'item_detail.enter_new_meal_name'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _editedMealName = result;
      });
      
      // Update the meal in dashboard with new name
      _updateMealInDashboard();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'item_detail.meal_renamed_to'.tr()} "$result"')),
      );
    }
  }

  /// Get translated meal name based on current locale
  Future<String> _getTranslatedMealName() async {
    try {
      final locale = context.locale.languageCode;
      
      // If already in English, use existing method
      if (locale == 'en') {
        return _editedMealName ?? widget.meal.getDisplayName();
      }
      
      // Get the original English meal name
      final englishMealName = _editedMealName ?? widget.meal.getDisplayName('en');
      
      // Translate using TranslationService
      final translatedName = await TranslationService.translateIngredient(
        englishMealName,
        locale,
      );
      
      return translatedName;
    } catch (e) {
      print('❌ Error translating meal name: $e');
      return _editedMealName ?? widget.meal.getDisplayName();
    }
  }

  /// Get translated ingredients based on current locale
  Future<List<String>> _getTranslatedIngredients() async {
    try {
      final locale = context.locale.languageCode;
      
      // If already in English, use existing method
      if (locale == 'en') {
        return _ingredients.map((ing) => ing.name).toList();
      }
      
      // Get English ingredient names
      final englishIngredients = _ingredients.map((ing) => ing.name).toList();
      
      // Translate using TranslationService
      final translatedIngredients = await TranslationService.translateIngredients(
        englishIngredients,
        locale,
      );
      
      return translatedIngredients;
    } catch (e) {
      print('❌ Error translating ingredients: $e');
      return _ingredients.map((ing) => ing.name).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          _buildMealImage(meal, w, h),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: .85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 80,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xff343434),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          FutureBuilder<String>(
                            future: _getTranslatedMealName(),
                            builder: (context, snapshot) {
                              final mealName = snapshot.data ?? (_editedMealName ?? widget.meal.getDisplayName());
                              return Text(
                                mealName,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xff999999).withOpacity(.25),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: CustomPaint(
                                          size: const Size(300, 150),
                                          painter: CalorieGaugePainter(
                                            fillPercent: (_calories / 2000).clamp(0.0, 1.0),
                                            segments: 22,
                                            filledColor: Colors.black.withOpacity(0.7),
                                            unfilledColor: Color(0xff525151).withOpacity(.28),
                                            segmentHeight: 60.0,
                                            topWidth: 14.0,
                                            bottomWidth: 10.0,
                                            cornerRadius: 7.0,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        child: Column(
                                          children: [
                                            AppText(
                                              _calories.toInt().toString(),
                                              fontSize: 28,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            AppText(
                                              'item_detail.meal_calories'.tr(),
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CalorieTrackerProgressBar(
                                          title: 'common.protein'.tr(),
                                          value: (_protein / 90).clamp(0.0, 1.0),
                                          overallValue: '${_protein.toInt()}/90g',
                                          color: AppColors.greenColor,
                                        ),
                                        CalorieTrackerProgressBar(
                                          title: 'common.fats'.tr(),
                                          value: (_fat / 70).clamp(0.0, 1.0),
                                          overallValue: '${_fat.toInt()}/70g',
                                          color: AppColors.redColor,
                                        ),
                                        CalorieTrackerProgressBar(
                                          title: 'common.carbs'.tr(),
                                          value: (_carbs / 110).clamp(0.0, 1.0),
                                          overallValue: '${_carbs.toInt()}/110g',
                                          color: AppColors.yellowColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'item_detail.ingredients'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20),
                          FutureBuilder<List<String>>(
                            future: _getTranslatedIngredients(),
                            builder: (context, snapshot) {
                              final translatedIngredients = snapshot.data ?? _ingredients.map((ing) => ing.name).toList();
                              
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  ...List.generate(translatedIngredients.length, (index) {
                                    return GestureDetector(
                                      onLongPress: () => _deleteIngredientWithDialog(index),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(.25),
                                              blurRadius: 4,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          translatedIngredients[index],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  // Add More Chip
                                  GestureDetector(
                                    onTap: () async {
                                      // Navigate to ingredients screen
                                      final result = await context.push('/ingredients', extra: _ingredients);
                                      // If we get an Ingredient back (from edit screen via rootNavigator), add it
                                      if (result is Ingredient) {
                                        _addIngredient(result);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(.15),
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, size: 16, color: Colors.black),
                                          SizedBox(width: 4),
                                          Text(
                                            'item_detail.add_more'.tr(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // Ensure final update before leaving
                    _updateMealInDashboard();
                    Navigator.pop(context);
                  },
                  icon: Image.asset('assets/icons/back.png', height: 40),
                ),
                Text(
                  'item_detail.nutrition'.tr(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Image.asset('assets/icons/more.png', height: 40),
                  onSelected: (value) {
                    if (value == 'favorite') {
                      // TODO: Implement add to favorites logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('item_detail.added_to_favorites'.tr())),
                      );
                    } else if (value == 'edit') {
                      _showRenameMealDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'favorite',
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, color: Colors.red),
                          SizedBox(width: 8),
                          Text('item_detail.add_to_favorites'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black),
                          SizedBox(width: 8),
                          Text('item_detail.edit_meal'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
