import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/dashboard/components/step_progress_circle.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/core/services/image_cache_service.dart';
import 'package:intl/intl.dart';
import 'package:calories_tracker/core/services/translation_service.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _calorieAnimation;
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _calorieAnimation = IntTween(begin: 1, end: 200).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCaloriePage(DashboardProvider dashboardProvider, bool hasAnalyzingMeals) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xff999999).withOpacity(.25),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: CustomPaint(
                    size: const Size(300, 160),
                    painter: CalorieGaugePainter(
                      fillPercent: (dashboardProvider.caloriesConsumed / 2000).clamp(0.0, 1.0),
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
                  bottom: 10.h(context),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _calorieAnimation,
                        builder: (context, child) {
                          return AppText(
                            hasAnalyzingMeals 
                              ? _calorieAnimation.value.toString()
                              : dashboardProvider.caloriesConsumed.toInt().toString(),
                            fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          );
                        },
                      ),
                      AppText(
                        hasAnalyzingMeals 
                          ? 'dashboard.analyzing'.tr()
                          : 'dashboard.daily_calories_left'.tr(),
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.h(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CalorieTrackerProgressBar(
                    title: 'common.protein'.tr(),
                    value: dashboardProvider.proteinValue,
                    overallValue: '${(dashboardProvider.proteinValue * 90).toInt()}/90g',
                    color: AppColors.greenColor,
                  ),
                  CalorieTrackerProgressBar(
                    title: 'common.fats'.tr(),
                    value: dashboardProvider.fatsValue,
                    overallValue: '${(dashboardProvider.fatsValue * 70).toInt()}/70g',
                    color: AppColors.redColor,
                  ),
                  CalorieTrackerProgressBar(
                    title: 'common.carbs'.tr(),
                    value: dashboardProvider.carbsValue,
                    overallValue: '${(dashboardProvider.carbsValue * 110).toInt()}/110g',
                    color: AppColors.yellowColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsPage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xff999999).withOpacity(.25),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: StepProgressCircle(
          steps: 3845,
          calories: 245,
          distance: 1.5,
          percent: 0.22,
          showBackground: false, // Don't show background since we have our own
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == 0 ? Colors.black : Colors.grey[400],
          ),
        ),
        SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == 1 ? Colors.black : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        // Check if there are analyzing meals and start animation
        final hasAnalyzingMeals = dashboardProvider.meals.any((meal) => meal.isAnalyzing);
        if (hasAnalyzingMeals && !_animationController.isAnimating) {
          _animationController.repeat();
        } else if (!hasAnalyzingMeals && _animationController.isAnimating) {
          _animationController.stop();
          _animationController.reset();
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 0.h(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Slideable calorie and steps counter
                  Container(
                    height: 250.h(context),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      children: [
                        _buildCaloriePage(dashboardProvider, hasAnalyzingMeals),
                        _buildStepsPage(),
                      ],
                    ),
                  ),
                  // Page indicator
                  SizedBox(height: 10.h(context)),
                  _buildPageIndicator(),
                  SizedBox(height: hasAnalyzingMeals ? 0.h(context) : 0.h(context)),
                  // MOTIVATIONAL MESSAGE
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: hasAnalyzingMeals ? 2 : 8),
                    padding: EdgeInsets.all(hasAnalyzingMeals ? 4 : 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.black, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dashboardProvider.hasScansToday() 
                                ? 'dashboard.meals_logged_motivation'.tr()
                                : 'dashboard.no_meals_today_motivation'.tr(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reduce spacing when analyzing  
                  SizedBox(height: hasAnalyzingMeals ? 4 : 8),
                  // Date filter indicator and title
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            dashboardProvider.selectedDate != null
                                ? _getLocalizedDateTitle(dashboardProvider.selectedDate!)
                                : 'dashboard.recently_uploaded'.tr(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  dashboardProvider.recentlyUploadedList.isEmpty
                      ? Container(
                          height: 200.h(context),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  dashboardProvider.selectedDate != null
                                      ? _getNoMealsForDateText(dashboardProvider.selectedDate!)
                                      : 'dashboard.no_recently_uploaded'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  dashboardProvider.selectedDate != null
                                      ? 'dashboard.try_different_date'.tr()
                                      : 'dashboard.start_tracking_meals'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final data = dashboardProvider.recentlyUploadedList[index];
                            return _buildMealListItem(data, dashboardProvider, index);
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemCount: dashboardProvider.recentlyUploadedList.length,
                        ),
                  // Add hint for delete functionality
                  if (dashboardProvider.recentlyUploadedList.isNotEmpty) ...[
                    SizedBox(height: 16.h(context)),
                    Center(
                      child: Text(
                        'dashboard.swipe_to_delete_hint'.tr(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 100.h(context)), // Bottom padding for FAB
                ],
              ),
            ),
          );
        },
    );
  }

  Widget _buildImageWidget(RecentlyUploadedModel data) {
    return ImageCacheService.getCachedImage(
      data.image,
      fit: BoxFit.cover,
      placeholder: Container(
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
      ),
      errorWidget: Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.restaurant,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }

  /// Get localized date title for filtered meals
  String _getLocalizedDateTitle(DateTime date) {
    final locale = context.locale.languageCode;
    
    // Use appropriate date format based on locale
    late String formattedDate;
    switch (locale) {
      case 'he':
        // Hebrew date format: day month
        formattedDate = DateFormat('d MMMM', 'he').format(date);
        break;
      case 'ru':
        // Russian date format: day month 
        formattedDate = DateFormat('d MMMM', 'ru').format(date);
        break;
      default:
        // English date format: Month day
        formattedDate = DateFormat('MMM dd').format(date);
        break;
    }
    
    return '${'dashboard.meals_for_date'.tr()} $formattedDate';
  }

  /// Get localized "no meals" text for selected date
  String _getNoMealsForDateText(DateTime date) {
    final locale = context.locale.languageCode;
    
    // Use appropriate date format based on locale
    late String formattedDate;
    switch (locale) {
      case 'he':
        // Hebrew date format: day month
        formattedDate = DateFormat('d MMMM', 'he').format(date);
        break;
      case 'ru':
        // Russian date format: day month 
        formattedDate = DateFormat('d MMMM', 'ru').format(date);
        break;
      default:
        // English date format: Month day
        formattedDate = DateFormat('MMM dd').format(date);
        break;
    }
    
    return '${'dashboard.no_meals_on_date'.tr()} $formattedDate';
  }

  /// Get translated meal name for dashboard display with robust fallback
  Future<String> _getTranslatedMealName(RecentlyUploadedModel data) async {
    try {
      // Check if it's a translation key (for analyzing meals)
      if (data.displayTitle.startsWith('dashboard.')) {
        return data.displayTitle.tr(); // Use easy_localization for keys
      }
      
      // Handle "Unknown Meal" case - provide localized fallback
      if (data.displayTitle.toLowerCase() == 'unknown meal') {
        return _getLocalizedUnknownMeal();
      }
      
      // Get current locale
      final locale = context.locale.languageCode;
      
      // If already in English, no need to translate
      if (locale == 'en') {
        return data.displayTitle;
      }
      
      // Try to translate using TranslationService with timeout
      final translatedName = await TranslationService.translateIngredient(
        data.displayTitle,
        locale,
      ).timeout(
        Duration(seconds: 3), // Add timeout to prevent hanging
        onTimeout: () {
          print('⏰ Translation timeout for: "${data.displayTitle}"');
          return data.displayTitle; // Return original on timeout
        },
      );
      
      // Validate translation result
      if (translatedName.isEmpty || translatedName.toLowerCase() == 'unknown meal') {
        print('⚠️ Invalid translation result, using original: "${data.displayTitle}"');
        return data.displayTitle;
      }
      
      return translatedName;
    } catch (e) {
      print('❌ Error translating meal name: $e');
      // Better fallback - if original is "Unknown Meal", provide localized version
      if (data.displayTitle.toLowerCase() == 'unknown meal') {
        return _getLocalizedUnknownMeal();
      }
      return data.displayTitle; // Fallback to original
    }
  }

  /// Get localized "Unknown Meal" text
  String _getLocalizedUnknownMeal() {
    try {
      final locale = context.locale.languageCode;
      switch (locale) {
        case 'he':
          return 'ארוחה לא מזוהה';
        case 'ru':
          return 'Неизвестное блюдо';
        default:
          return 'Unknown Meal';
      }
    } catch (e) {
      return 'Unknown Meal';
    }
  }

  /// Build macro progress bars with real data, showing "No data" for missing values
  Widget _buildMacroProgressBars(RecentlyUploadedModel data, Meal? meal) {
    // Use real meal data if available, otherwise fall back to display data
    final protein = meal?.protein ?? 0.0;
    final fat = meal?.fat ?? 0.0; 
    final carbs = meal?.carbs ?? 0.0;
    
    // Define daily targets for calculation
    const double proteinTarget = 90.0;
    const double fatTarget = 70.0;
    const double carbTarget = 110.0;
    
    // Calculate progress values (0-1) only if we have real data
    final proteinProgress = protein > 0 ? (protein / proteinTarget).clamp(0.0, 1.0) : 0.0;
    final fatProgress = fat > 0 ? (fat / fatTarget).clamp(0.0, 1.0) : 0.0;
    final carbProgress = carbs > 0 ? (carbs / carbTarget).clamp(0.0, 1.0) : 0.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CalorieTrackerProgressBar(
            title: 'common.protein'.tr(),
            value: proteinProgress,
            overallValue: protein > 0 ? '${protein.toInt()}g/${proteinTarget.toInt()}g' : '--/90g',
            color: protein > 0 ? AppColors.greenColor : Colors.grey[300]!,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: CalorieTrackerProgressBar(
            title: 'common.fats'.tr(),
            value: fatProgress,
            overallValue: fat > 0 ? '${fat.toInt()}g/${fatTarget.toInt()}g' : '--/70g',
            color: fat > 0 ? AppColors.redColor : Colors.grey[300]!,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: CalorieTrackerProgressBar(
            title: 'common.carbs'.tr(),
            value: carbProgress,
            overallValue: carbs > 0 ? '${carbs.toInt()}g/${carbTarget.toInt()}g' : '--/110g',
            color: carbs > 0 ? AppColors.yellowColor : Colors.grey[300]!,
          ),
        ),
      ],
    );
  }

  /// Build meal list item with translation support
  Widget _buildMealListItem(RecentlyUploadedModel data, DashboardProvider dashboardProvider, int index) {
    // Get the actual meal data for macro calculations
    Meal? meal;
    try {
      meal = dashboardProvider.meals.firstWhere((m) => m.id == data.mealId);
    } catch (_) {
      meal = null;
    }
    
    return FutureBuilder<String>(
      future: _getTranslatedMealName(data),
      builder: (context, snapshot) {
        final translatedMealName = snapshot.data ?? data.displayTitle;
        
        return Dismissible(
          key: Key(data.mealId ?? 'meal_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                                 Text(
                   'dashboard.delete'.tr(),
                   style: TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.w600,
                     fontSize: 16,
                   ),
                 ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (data.mealId != null) {
              return await _showDeleteConfirmationDialog(context, dashboardProvider, data);
            }
            return false;
          },
          onDismissed: (direction) async {
            // Handle the actual deletion
            try {
              // Delete the meal (no loading snackbar)
              await dashboardProvider.deleteMeal(data.mealId!);
              
              // Show success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('dashboard.meal_deleted_success'.tr()),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              // Show error message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('dashboard.meal_delete_failed'.tr()),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          child: GestureDetector(
            onTap: () {
              Meal? meal;
              try {
                meal = dashboardProvider.meals.firstWhere((m) => m.id == data.mealId);
              } catch (_) {
                meal = null;
              }
              if (meal != null) {
                context.push('/item-detail', extra: meal);
              } else {
                print('Meal not found for id: ${data.mealId}');
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 118.h(context),
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.7),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff999999).withOpacity(.25),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100.h(context),
                        height: 100.h(context),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: _buildImageWidget(data),
                            ),
                            // Show analyzing overlay if this is an analyzing meal
                            if (data.overalAllCalorie == '--')
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.6),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30.h(context),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AppText(
                                    translatedMealName,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    maxLines: 1,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppText(
                                  data.overalAllCalorie,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h(context)),
                          _buildMacroProgressBars(data, meal),
                          SizedBox(height: 4.h(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context, 
    DashboardProvider dashboardProvider, 
    RecentlyUploadedModel data
  ) async {
    // Get translated meal name for dialog
    final translatedMealName = await _getTranslatedMealName(data);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'dashboard.delete_meal'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard.delete_meal_question'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: _buildImageWidget(data),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translatedMealName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            data.overalAllCalorie,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'dashboard.delete_cannot_be_undone'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Close dialog and return false
              },
              child: Text(
                'dashboard.cancel'.tr(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close dialog and return true
              },
              child: Text(
                'dashboard.delete'.tr(),
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    return result ?? false; // Return false if dialog was dismissed
  }
}
