import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import './12_wizard_loading_page.dart';
import './14_wizard_referal.dart';
import './16_wizard_apple_health.dart';
import './17_wizard_google_fit.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';

import '5_wizard_your_age.dart';
import '4_wizard_current_height.dart';
import '3_wizard_your_weight.dart';
import '2_wizard_gender.dart';
import '6_wizard_goal_type.dart';
import '7_diet_type.dart';
import '8_wizard_dream_weight.dart';
import '9_wizard_motivation_acheivement.dart';
import '10_wizard_workout.dart';
import '11_wizard_how_fast.dart';
import '13_wizard_summary_date_and_measurments.dart';
import '15_wizard_great_potential.dart';
import '18_wizard_notification.dart';
import '19_wizard_recommendation.dart';
import '1_wizard_hear_about_us.dart';

class WizardPager extends StatelessWidget {
  const WizardPager({super.key});

  List<Widget> _getScreens() {
    return [
      const WizardHearAboutUs(),
      const WizardGender(),
      const WizardYourWeight(),
      const WizardCurrentHeight(),
      const WizardYourAge(),
      const WizardGoalType(),
      const WizardDietType(),
      const WizardDreamWeight(),
      const WizardMotivationAchiement(),
      const WizardWorkout(),
      const WizardHowFast(),
      const WizardLoadingPage(),
      const WizardSummaryDateAndMeasurments(),
      const WizardReferal(),
      const WizardGreatPotential(),
      if (Platform.isIOS) const WizardAppleHealth() else const WizardGoogleFit(),
      const WizardNotification(),
      const WizardRecommendationApp(),
      const LoginScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Index of LoadingPage and results screen
    const loadingIndex = 11; // LoadingPage index
    const resultsIndex = 12; // Wizard11 (results) index
    final showIndicators = provider.currentIndex != loadingIndex && provider.currentIndex != resultsIndex;
    
    // Calculate visible dots range (show 5 dots at a time)
    final currentIndex = provider.currentIndex;
    final totalPages = _getScreens().length;
    final visibleDots = 5;
    
    int startDot = currentIndex - (visibleDots ~/ 2);
    startDot = startDot.clamp(0, totalPages - visibleDots);
    int endDot = startDot + visibleDots;
    endDot = endDot.clamp(visibleDots, totalPages);
    startDot = endDot - visibleDots;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: provider.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: provider.onPageChanged,
              children: _getScreens().map((screen) => 
                Container(
                  color: colorScheme.surface,
                  child: screen,
                )
              ).toList(),
            ),
          ),
          if (showIndicators) ...[
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show left ellipsis if needed
                if (startDot > 0)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                  ),
                
                // Show visible dots
                ...List.generate(endDot - startDot, (index) {
                  final dotIndex = startDot + index;
                  final isActive = provider.currentIndex == dotIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isActive ? 14.w : 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
                
                // Show right ellipsis if needed
                if (endDot < totalPages)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 28.h),
          ],
        ],
      ),
    );
  }
}
