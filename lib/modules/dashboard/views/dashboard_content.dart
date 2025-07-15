import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:calories_tracker/features/models/meal_model.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (dashboardProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Don't refresh if there are analyzing meals to avoid losing them
            final analyzingCount = dashboardProvider.meals.where((meal) => meal.isAnalyzing).length;
            if (analyzingCount > 0) {
              print('🔄 Skipping refresh - ${analyzingCount} meals are still analyzing');
              return;
            }
            await dashboardProvider.refreshDashboard();
          },
          color: Colors.black,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 0.h(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                                    AppText(
                                      dashboardProvider.caloriesConsumed.toInt().toString(),
                                      fontSize: 28,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    AppText(
                                      'dashboard.daily_calories_left'.tr(),
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
                  ),
                  SizedBox(height: 0.h(context)),
                  // MOTIVATIONAL MESSAGE
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(8),
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
                  SizedBox(height: 0.h(context)),
                  AppText(
                    'dashboard.recently_uploaded'.tr(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8.h(context)),
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
                                  'dashboard.no_recently_uploaded'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'dashboard.start_tracking_meals'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final data = dashboardProvider.recentlyUploadedList[index];
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
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
                                    print('Meal not found for id:  [31m${data.mealId} [0m');
                                  }
                                },
                                onLongPress: () {
                                  if (data.mealId != null) {
                                    _showDeleteConfirmationDialog(context, dashboardProvider, data);
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.12),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 100.h(context),
                                        width: 100.w(context),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
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
                                                      data.displayTitle,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                      maxLines: 1,
                                                      textOverflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffececec),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: AppText(
                                                        data.time,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 4.h(context)),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xffececec),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                child: AppText(
                                                  data.overalAllCalorie,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4.h(context)),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: CalorieTrackerProgressBar(
                                                    title: 'common.protein'.tr(),
                                                    value: 0.30,
                                                    overallValue: '${data.proteinCalorie}/90g',
                                                    color: AppColors.greenColor,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: CalorieTrackerProgressBar(
                                                    title: 'common.fats'.tr(),
                                                    value: 0.5,
                                                    overallValue: '${data.fatsCalorie}/70g',
                                                    color: AppColors.redColor,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: CalorieTrackerProgressBar(
                                                    title: 'common.carbs'.tr(),
                                                    value: 0.4,
                                                    overallValue: '${data.carbsCalorie}/110g',
                                                    color: AppColors.yellowColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6.h(context)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemCount: dashboardProvider.recentlyUploadedList.length,
                        ),
                  // Add hint for delete functionality
                  if (dashboardProvider.recentlyUploadedList.isNotEmpty) ...[
                    SizedBox(height: 16.h(context)),
                    Center(
                      child: Text(
                        '💡 Long press on any meal to delete',
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
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(RecentlyUploadedModel data) {
    if (data.isNetworkImage) {
      return Image.network(
        data.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.restaurant,
              color: Colors.grey[400],
              size: 32,
            ),
          );
        },
      );
    } else if (data.isLocalFile) {
      return Image.file(
        File(data.image),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.restaurant,
              color: Colors.grey[400],
              size: 32,
            ),
          );
        },
      );
    } else {
      // Asset image
      return Image.asset(
        data.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.restaurant,
              color: Colors.grey[400],
              size: 32,
            ),
          );
        },
      );
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(
    BuildContext context, 
    DashboardProvider dashboardProvider, 
    RecentlyUploadedModel data
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Meal',
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
                'Are you sure you want to delete this meal?',
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
                            data.displayTitle,
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
                'This action cannot be undone.',
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
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                
                try {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Deleting meal...'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Delete the meal
                  await dashboardProvider.deleteMeal(data.mealId!);
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Meal deleted successfully'),
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
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Failed to delete meal'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Delete',
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
  }
}
