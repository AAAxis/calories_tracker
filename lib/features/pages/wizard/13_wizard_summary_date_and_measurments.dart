import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/services/calculation_service.dart';
import '14_wizard_referal.dart';  // Add import for Wizard18
import '../../../core/custom_widgets/calorie_gauage_wizard.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/custom_widgets/wizard_icon.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardSummaryDateAndMeasurments extends StatefulWidget {
  const WizardSummaryDateAndMeasurments({super.key});

  @override
  State<WizardSummaryDateAndMeasurments> createState() => _WizardSummaryDateAndMeasurmentsState();
}

class _WizardSummaryDateAndMeasurmentsState extends State<WizardSummaryDateAndMeasurments> {
  double calories = 2000;
  double proteins = 150;
  double carbs = 300;
  double fats = 65;

  @override
  void initState() {
    super.initState();
    _calculateAndLoadNutritionGoals();
  }

  Future<void> _calculateAndLoadNutritionGoals() async {
    try {
      // Calculate nutrition goals based on wizard data
      final calculatedGoals = await CalculationService.calculateNutritionGoals();
      
      setState(() {
        calories = calculatedGoals['calories']!;
        proteins = calculatedGoals['protein']!;
        carbs = calculatedGoals['carbs']!;
        fats = calculatedGoals['fats']!;
      });
    } catch (e) {
      print('Error calculating nutrition goals: $e');
      // Fallback to default values
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        calories = prefs.getDouble('nutrition_goal_calories') ?? 2000;
        proteins = prefs.getDouble('nutrition_goal_protein') ?? 150;
        carbs = prefs.getDouble('nutrition_goal_carbs') ?? 300;
        fats = prefs.getDouble('nutrition_goal_fats') ?? 65;
      });
    }
  }

  Future<void> _saveNutritionGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('nutrition_goal_calories', calories);
    await prefs.setDouble('nutrition_goal_protein', proteins);
    await prefs.setDouble('nutrition_goal_carbs', carbs);
    await prefs.setDouble('nutrition_goal_fats', fats);
  }

  Future<Map<String, dynamic>> _calculateTimeline() async {
    final prefs = await SharedPreferences.getInstance();
    final currentWeight = prefs.getDouble('wizard_weight') ?? 70.0;
    final targetWeight = prefs.getDouble('wizard_target_weight') ?? 65.0;
    final goal = prefs.getInt('wizard_goal') ?? 0;
    final goalSpeed = prefs.getDouble('wizard_goal_speed') ?? 0.8;
    final isMetric = prefs.getBool('wizard_is_metric') ?? true;
    
    // Debug print
    print('🔍 Timeline Calculation Debug:');
    print('  - Current Weight: $currentWeight kg');
    print('  - Target Weight: $targetWeight kg');
    print('  - Weight Difference: ${(targetWeight - currentWeight).abs()} kg');
    print('  - Goal Speed: $goalSpeed kg/week');
    print('  - Goal: $goal (0=lose, 1=maintain, 2=gain)');
    
    try {
      // For maintain weight, no timeline needed
      if (goal == 1) {
        return {
          'goal': goal,
          'weightDifference': 0.0,
          'targetDate': DateTime.now(),
          'weeksToGoal': 0.0,
          'daysToGoal': 0.0,
          'goalSpeed': 0.0,
        };
      }
      
      // For lose/gain weight, use the actual target weight from wizard
      final timeline = CalculationService.calculateTimeline(
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        goalSpeed: goalSpeed,
        isMetric: isMetric,
      );
      
      // Debug print timeline results
      print('  - Weeks to Goal: ${timeline['weeksToGoal']}');
      print('  - Days to Goal: ${timeline['daysToGoal']}');
      print('  - Target Date: ${timeline['targetDate']}');
      
      return {
        ...timeline,
        'goal': goal,
      };
    } catch (e) {
      print('❌ Error calculating timeline: $e');
      // Return safe default values
      return {
        'goal': goal,
        'weightDifference': 0.0,
        'targetDate': DateTime.now(),
        'weeksToGoal': 0.0,
        'daysToGoal': 0.0,
        'goalSpeed': 0.0,
      };
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _showEditDialog(String title, double currentValue, Function(double) onSave) async {
    final controller = TextEditingController(text: currentValue.toStringAsFixed(0));
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          '${'wizard_summary.edit'.tr()} $title',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                suffixText: title == 'wizard_summary.calories'.tr() ? 'wizard_summary.kcal'.tr() : 'wizard_summary.g'.tr(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'wizard_summary.cancel'.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null && newValue > 0) {
                onSave(newValue);
                Navigator.pop(context);
              }
            },
            child: Text('wizard_summary.save'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 120.h), // Add padding to prevent content from being hidden behind fixed button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 38.h),
                  // App Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'wizard_hear_about_us.app_title'.tr(),
                      style: TextStyle(
                        fontFamily: 'RusticRoadway',
                        color: colorScheme.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Center(
                    child: Image.asset(
                      AppAnimations.cloud,
                      height: 210.h,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low,
                      cacheWidth: (ScreenUtil().screenWidth * 0.6).toInt(),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Center(
                    child: Text(
                      'wizard_summary.congratulations'.tr(),
                      style: AppTextStyles.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 24,
                        // fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      'wizard_summary.custom_plan_ready'.tr(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 24,
                        // fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 12.h),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _calculateTimeline(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final timeline = snapshot.data!;
                        final goal = timeline['goal'] as int;
                        final weightDifference = timeline['weightDifference'] as double;
                        final targetDate = timeline['targetDate'] as DateTime;
                        final goalText = goal == 0 ? 'wizard_summary.goal_lose'.tr() : goal == 1 ? 'wizard_summary.goal_maintain'.tr() : 'wizard_summary.goal_gain'.tr();
                        
                        return Column(
                          children: [
                            Text(
                              "${'wizard_summary.you_should'.tr()} $goalText:",
                              style: AppTextStyles.bodyLarge.copyWith(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(height: 5.h),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 70.sp),
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.r)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${weightDifference.toStringAsFixed(1)} ${'wizard_summary.kg_by'.tr()} ${_formatDate(targetDate)}",
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                          fontSize: 15.sp,
                                          // fontFamily: 'Inter',
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "(${(timeline['weeksToGoal'] as double).toStringAsFixed(1)} ${'wizard_summary.weeks'.tr()})",
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.7),
                                          fontSize: 15.sp,
                                          // fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Text(
                              'wizard_summary.calculating_goal'.tr(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                  color: colorScheme.onSurface, 
                                  fontSize: 20,
                                  fontFamily: 'Inter'),
                            ),
                            SizedBox(height: 5.h),
                            const CircularProgressIndicator(),
                          ],
                        );
                      }
                    },
                  ),

                  SizedBox(height: 10.h),

                  // Recommendations Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'wizard_summary.daily_recommendations'.tr(),
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                // Text(
                                //   'wizard_summary.edit_anytime'.tr(),
                                //   style: AppTextStyles.bodyMedium.copyWith(
                                //     color: colorScheme.onSurface.withOpacity(0.6),
                                //     fontSize: 18,
                                //   ),
                                //   textAlign: TextAlign.center,
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // 2x2 Nutrition Cards Grid
                          Column(
                            children: [
                              // Row 1: Calories and Proteins
                              Row(
                                children: [
                                  Expanded(
                                    child: CalorieGaugeWizard(
                                      title: 'wizard_summary.calories'.tr(),
                                      icon: Icon(Icons.local_fire_department_rounded, color: Colors.redAccent),
                                      unit: 'wizard_summary.kcal'.tr(),
                                      currentValue: calories,
                                      maxValue: 3000,
                                      filledColor: Colors.orange,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: CalorieGaugeWizard(
                                      title: 'wizard_summary.protein'.tr(),
                                      icon: Icon(Icons.fitness_center, color: Colors.green),
                                      unit: 'wizard_summary.g'.tr(),
                                      currentValue: proteins,
                                      maxValue: 300,
                                      filledColor: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              // Row 2: Carbs and Fats
                              Row(
                                children: [
                                  Expanded(
                                    child: CalorieGaugeWizard(
                                      title: 'wizard_summary.carbs'.tr(),
                                      icon: Icon(Icons.bakery_dining, color: Colors.amber),
                                      unit: 'wizard_summary.g'.tr(),
                                      currentValue: carbs,
                                      maxValue: 500,
                                      filledColor: Colors.amber,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: CalorieGaugeWizard(
                                      title: 'wizard_summary.fats'.tr(),
                                      icon: Icon(Icons.opacity, color: Colors.red),
                                      unit: 'wizard_summary.g'.tr(),
                                      currentValue: fats,
                                      maxValue: 200,
                                      filledColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Goals section
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r)),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'wizard_summary.how_to_reach_goals'.tr(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                // fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _GoalRow(
                              icon: AppIcons.recommendaion_2,
                              color: Colors.green[600]!,
                              text: 'wizard_summary.goal_tip_1'.tr(),
                            ),
                            SizedBox(height: 8.h),
                            _GoalRow(
                              icon: AppIcons.recommendaion_1,
                              color: Colors.indigo,
                              text: 'wizard_summary.goal_tip_2'.tr(),
                            ),
                            SizedBox(height: 8.h),
                            _GoalRow(
                              icon: AppIcons.recommendaion_3,
                              color: Colors.redAccent,
                              text: 'wizard_summary.goal_tip_3'.tr(),
                            ),
                            SizedBox(height: 8.h),
                            _GoalRow(
                              icon: AppIcons.recommendaion_4,
                              color: Colors.teal,
                              text: 'wizard_summary.goal_tip_4'.tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_summary.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WizardReferal(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final String icon;
  final Color color;
  final String text;

  const _GoalRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SizedBox(
        // height: 50.h,
        width: double.infinity,
        // decoration: BoxDecoration(
        //   color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 240),
        //   borderRadius: BorderRadius.circular(8.r),
        // ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 4.sp),
              // width: 28.w,
              // height: 28.w,
              // decoration: BoxDecoration(
              //   color: color.withValues(alpha: 0.13),
              //   borderRadius: BorderRadius.circular(8.r),
              // ),
              child: WizardIcon(
                assetPath: icon,
                size: 70,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  // fontWeight: FontWeight.bold,
                  // fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
