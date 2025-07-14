import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/core/widgets/user_avatar.dart';
import 'package:calories_tracker/gen/assets.gen.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_calendart.dart';
import 'package:calories_tracker/modules/dashboard/views/dashboard_content.dart';
// Removed water_tracker_view import - stats now only in bottom navigation
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Removed PageController and _pages since dashboard now shows only single content

  // Helper function to check if user should have free camera access
  Future<bool> _shouldAllowFreeCameraAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check referral scans first
      final hasUsedReferralCode = prefs.getBool('has_used_referral_code') ?? false;
      if (hasUsedReferralCode) {
        final referralFreeScans = prefs.getInt('referral_free_scans') ?? 0;
        final usedReferralScans = prefs.getInt('used_referral_scans') ?? 0;

        if (usedReferralScans < referralFreeScans) {
          print('🎁 User has ${referralFreeScans - usedReferralScans} referral scans');
          return true;
        }
      }

      // Check daily scan limit (1 scan per day for free users)
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      final canUseFreeScan = !dashboardProvider.hasScansToday();
      print('🔍 Daily scan check: $canUseFreeScan');
      return canUseFreeScan;

    } catch (e) {
      print('❌ Error checking free camera access: $e');
      return false;
    }
  }

  Future<void> _triggerCameraAccess() async {
    print('🚀 _triggerCameraAccess called - opening camera directly');
    print('🎯 Context mounted: ${context.mounted}');

    try {
      if (context.mounted) {
        print('📸 Opening camera page...');

        // Navigate to camera page and wait for result
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        await context.push('/camera', extra: {
          'meals': dashboardProvider.meals,
          'updateMeals': dashboardProvider.updateMeals,
        });

        // No need to refresh dashboard - camera screen already updates meals via updateMeals
      }

    } catch (e) {
      print('❌ Error in _triggerCameraAccess: $e');
      print('❌ Stack trace: ${StackTrace.current}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening camera. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Wrapper(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UserAvatar(
                          size: 50.0,
                          onTap: () {
                            context.push('/profile');
                          },
                        ),
                        const Spacer(),
                        Image.asset(Assets.icons.premium.path),
                        SizedBox(width: 4.w(context)),
                        AppText(
                          'dashboard.get_premium'.tr(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            context.push('/profile');
                          },
                          child: Icon(Icons.menu, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h(context)),
                  CalorieCalendar(maxCalories: 2000),
                  SizedBox(height: 10.h(context)),
                  // Single page dashboard content (no more PageView needed)
                  const DashboardContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
