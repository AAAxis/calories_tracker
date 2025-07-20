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
import '../../../core/services/paywall_service.dart';
import '../../../core/utils/haptics.dart';
import 'package:easy_localization/easy_localization.dart';

class WizardPager extends StatelessWidget {
  const WizardPager({super.key});

  // Get total screen count based on platform
  static int getTotalScreenCount() {
    if (Platform.isIOS) {
      return 20; // iOS has Apple Health screen
    } else {
      return 19; // Android skips Google Fit screen
    }
  }

  List<Widget> _getScreens() {
    final screens = [
      const WizardHearAboutUs(),                    // 0
      const WizardGender(),                         // 1
      const WizardYourWeight(),                     // 2
      const WizardCurrentHeight(),                  // 3
      const WizardYourAge(),                        // 4
      const WizardGoalType(),                       // 5
      const WizardDietType(),                       // 6
      const WizardDreamWeight(),                    // 7
      const WizardMotivationAchiement(isGain: false,), // 8
      const WizardWorkout(),                        // 9
      const WizardHowFast(),                        // 10
      const WizardLoadingPage(),                    // 11
      const WizardSummaryDateAndMeasurments(),      // 12
      const WizardReferal(),                        // 13
      const WizardGreatPotential(),                 // 14
      // Health integration - only for iOS for now (Google Fit commented out for app approval)
      if (Platform.isIOS) const WizardAppleHealth(), // 15 (only on iOS)
      // if (Platform.isAndroid) const WizardGoogleFit(), // Commented out for app approval
      const WizardNotification(),                   // 16 (iOS) / 15 (Android)
      const WizardRecommendationApp(),              // 17 (iOS) / 16 (Android)
      const PaywallTriggerScreen(),                 // 18 (iOS) / 17 (Android)
      const LoginScreen(),                          // 19 (iOS) / 18 (Android)
    ];
    
    print('🎬 WizardPager: Total screens configured: ${screens.length}');
    if (Platform.isIOS) {
      print('🎬 WizardPager: iOS - PaywallTriggerScreen at index 18');
      print('🎬 WizardPager: iOS - LoginScreen at index 19');
    } else {
      print('🎬 WizardPager: Android - PaywallTriggerScreen at index 17 (Google Fit skipped)');
      print('🎬 WizardPager: Android - LoginScreen at index 18 (Google Fit skipped)');
    }
    
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Index of LoadingPage and results screen
    const loadingIndex = 11; // LoadingPage index
    const resultsIndex = 12; // Wizard11 (results) index
    const paywallIndex = 18; // Paywall trigger screen index
    final showIndicators = provider.currentIndex != loadingIndex && 
                          provider.currentIndex != resultsIndex && 
                          provider.currentIndex != paywallIndex;
    
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

// Paywall Trigger Screen
class PaywallTriggerScreen extends StatefulWidget {
  const PaywallTriggerScreen({super.key});

  @override
  State<PaywallTriggerScreen> createState() => _PaywallTriggerScreenState();
}

class _PaywallTriggerScreenState extends State<PaywallTriggerScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🎬 PaywallTriggerScreen: initState called');
    // Automatically show paywall when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎬 PaywallTriggerScreen: PostFrameCallback triggered');
      _showPaywall();
    });
  }

  Future<void> _showPaywall() async {
    print('🎬 PaywallTriggerScreen: _showPaywall() called');
    setState(() => _isLoading = true);
    
    try {
      // Add haptic feedback
      AppHaptics.continue_vibrate();
      
      // Small delay for better UX
      await Future.delayed(Duration(milliseconds: 800));
      
      print('🔍 Checking subscription status...');
      // Check if user already has active subscription
      final hasActiveSubscription = await PaywallService.hasActiveSubscription();
      
      if (hasActiveSubscription) {
        // User already has subscription, skip to next screen
        print('✅ User already has active subscription, skipping paywall');
        _navigateToNextScreen();
        return;
      }
      
      print('❌ No active subscription found, proceeding with paywall');
      
      // Get referral code from wizard provider
      final provider = Provider.of<WizardProvider>(context, listen: false);
      final referralCode = provider.referralCode;
      
      print('🎫 Referral code from wizard: ${referralCode ?? 'none'}');
      if (referralCode == 'DEV511') {
        print('🎁 Special DEV511 referral code detected - will use discount offering');
      }
      
      print('🚀 About to show paywall...');
      // Show RevenueCat paywall with referral consideration
      final purchased = await PaywallService.showPaywallWithReferral(
        context,
        referralCode: referralCode,
      );
      
      print('🏁 Paywall returned with result: $purchased');
      
      if (purchased) {
        print('✅ User purchased subscription!');
        AppHaptics.continue_vibrate(); // Success haptic
      } else {
        print('❌ User cancelled or failed purchase');
      }
      
      // Navigate to next screen regardless of purchase result
      _navigateToNextScreen();
      
    } catch (e) {
      print('❌ Error showing paywall: $e');
      print('📊 Error details: ${e.toString()}');
      
      // Show error state briefly before continuing
      if (mounted) {
        setState(() => _isLoading = false);
        await Future.delayed(Duration(milliseconds: 1500));
      }
      
      // Navigate to next screen even if paywall fails
      _navigateToNextScreen();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToNextScreen() {
    print('🎬 PaywallTriggerScreen: _navigateToNextScreen called');
    final provider = Provider.of<WizardProvider>(context, listen: false);
    print('🎬 Current wizard index: ${provider.currentIndex}, total screens: ${provider.totalScreens}');
    provider.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                Text(
                  'wizard_hear_about_us.app_title'.tr(),
                  style: TextStyle(
                    fontFamily: 'RusticRoadway',
                    color: colorScheme.primary,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                
                if (_isLoading) ...[
                  // Loading animation
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Loading subscription options...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Preparing your premium experience',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Success state
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Almost there!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Get ready for your premium experience',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
