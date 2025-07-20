import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/custom_widgets/wizard_icon.dart';
import '../../../core/theme/app_text_styles.dart';
import 'dart:io';
import 'dart:ui';
import '16_wizard_apple_health.dart';
import '17_wizard_google_fit.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';
import 'package:provider/provider.dart';
import '../../providers/wizard_provider.dart';

import 'package:flutter/material.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardGreatPotential extends StatefulWidget {
  const WizardGreatPotential({super.key});

  @override
  WizardGreatPotentialState createState() => WizardGreatPotentialState();
}

class WizardGreatPotentialState extends State<WizardGreatPotential>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnimation;

  bool isGain = true; // Set to true for weight gain, false for weight loss
  bool isRtl = false;
  void _navigateToHealthScreen(BuildContext context) {
    isRtl = Localizations.localeOf(context).languageCode == 'he';

    if (Platform.isIOS) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WizardAppleHealth()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WizardGoogleFit()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Line animation goes from 0 to 1 (representing the graph growth)
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRecommendationItem(String text, Color iconColor, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    isRtl = Localizations.localeOf(context).languageCode == 'he';

    // Sample data for the graph
    final List<double> sampleWeights = [86, 78, 76, 74, 72];
    final List<String> sampleDays = ['Today', '3d', '7d', '14d', '30d'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Text(
                'wizard_great_potential.title'.tr(),
                style: TextStyle(
                  fontSize: kTitleTextStyle.fontSize!.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              Text(
                'wizard_great_potential.how_to_reach_goals'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),

              // Recommendations Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r)),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 0.h, horizontal: 16.w),
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
                        // SizedBox(height: 16.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_2,
                          color: Colors.green[600]!,
                          text: 'wizard_summary.goal_tip_1'.tr(),
                        ),
                        // SizedBox(height: 8.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_1,
                          color: Colors.indigo,
                          text: 'wizard_summary.goal_tip_2'.tr(),
                        ),
                        // SizedBox(height: 8.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_3,
                          color: Colors.redAccent,
                          text: 'wizard_summary.goal_tip_3'.tr(),
                        ),
                        // SizedBox(height: 8.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_4,
                          color: Colors.teal,
                          text: 'wizard_summary.goal_tip_4'.tr(),
                        ),

                        Image.asset(
                          AppAnimations.goal,
                          // width: 250.w,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'wizard_great_potential.consistency_tip'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Add bottom padding to ensure content is visible above the button
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_great_potential.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            // Use PageView navigation instead of direct navigation
            Provider.of<WizardProvider>(context, listen: false).nextPage();
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
              padding: EdgeInsets.only(left: 10.sp),
              // width: 28.w,
              // height: 28.w,
              // decoration: BoxDecoration(
              //   color: color.withValues(alpha: 0.13),
              //   borderRadius: BorderRadius.circular(8.r),
              // ),
              child: WizardIcon(
                assetPath: icon,
                size: 60,
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
