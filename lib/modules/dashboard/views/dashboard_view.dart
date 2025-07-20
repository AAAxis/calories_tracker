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
import 'package:calories_tracker/core/services/paywall_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Removed PageController and _pages since dashboard now shows only single content
  bool _isPremium = false;

  // Check if user should be blocked and show paywall
  Future<void> _checkScanPermissionAndNavigate() async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    
    // Check if user should be blocked
    final shouldBlock = await dashboardProvider.shouldBlockScan();
    
    if (shouldBlock) {
      print('🚫 User is blocked - showing paywall');
      await _showPremiumPaywall();
    } else {
      print('✅ User can scan - opening camera');
      await _triggerCameraAccess();
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

  Future<void> _showPremiumPaywall() async {
    print('💎 Opening NATIVE premium paywall...');
    
    try {
      final result = await PaywallService.showPaywall(
        context,
        offeringId: PaywallService.defaultOfferingId,
        forceCloseOnRestore: false, // Use native RevenueCat paywall, not custom dialog
      );
      
      if (result) {
        print('✅ Premium subscription activated!');
        // Update premium status
        await _checkPremiumStatus();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Welcome to Premium! Enjoy unlimited meal tracking!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('❌ Premium subscription cancelled or failed');
      }
    } catch (e) {
      print('❌ Error showing premium paywall: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load premium options. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('is_premium') ?? false;
      
      // Also check with PaywallService for more accurate status
      final hasActiveSubscription = await PaywallService.hasActiveSubscription();
      
      final premiumStatus = isPremium || hasActiveSubscription;
      
      if (mounted && premiumStatus != _isPremium) {
        setState(() {
          _isPremium = premiumStatus;
        });
      }
    } catch (e) {
      print('❌ Error checking premium status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Wrapper(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Fixed App Bar
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10,
                        bottom: 10,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                        child: Column(
                          children: [
                            // Loading Spinner at Top
                            if (dashboardProvider.isLoading)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // App Bar Content
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UserAvatar(
                                  size: 50.0,
                                  onTap: () {
                                    context.push('/profile');
                                  },
                                ),
                                const Spacer(),
                                if (_isPremium) 
                                  // Show Premium badge for premium users
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(Assets.icons.premium.path),
                                      SizedBox(width: 4.w(context)),
                                      AppText(
                                        'dashboard.premium'.tr(),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ],
                                  )
                                else
                                  // Show Get Premium button for free users
                                  GestureDetector(
                                    onTap: _showPremiumPaywall,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(Assets.icons.premium.path),
                                        SizedBox(width: 4.w(context)),
                                        AppText(
                                          'dashboard.get_premium'.tr(),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                      ],
                                    ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Fixed Calendar
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                      child: CalorieCalendar(maxCalories: 2000),
                    ),
                  ),
                ];
              },
              body: Container(
                padding: EdgeInsets.only(top: 10.h(context)),
                child: const DashboardContent(),
              ),
            ),
          ),
        );
      },
    );
  }
}
