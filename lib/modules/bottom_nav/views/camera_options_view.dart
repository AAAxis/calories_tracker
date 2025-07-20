import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/core/services/paywall_service.dart';

class CameraOptionsView extends StatelessWidget {
  const CameraOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    return Wrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'camera_options.scan_meal'.tr(),
                  onTap: () => _openCamera(context),
                ),
                SizedBox(height: 24.h),
                _buildOptionButton(
                  context,
                  icon: Icons.inventory_2,
                  label: 'camera_options.scan_ingredient'.tr(),
                  onTap: () => _scanIngredients(context),
                ),
                  SizedBox(height: 24.h),
                _buildOptionButton(
                  context,
                  icon: Icons.receipt_long,
                  label: 'camera_options.scan_receipt'.tr(),
                  onTap: () => _scanReceipt(context),
                ),
                SizedBox(height: 24.h),
                _buildOptionButton(
                  context,
                  icon: Icons.edit_note,
                  label: 'camera_options.log_manually'.tr(),
                  onTap: () => _logManually(context),
                ),
              
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 28.sp),
            SizedBox(width: 16.w),
            AppText(
              label,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    
    // Check if user should be blocked and show paywall
    final shouldBlock = await dashboardProvider.shouldBlockScan();
    
    if (shouldBlock) {
      print('🚫 User is blocked - showing paywall');
      await _showPremiumPaywall(context);
    } else {
      print('✅ User can scan - opening camera');
      // Navigate to camera screen with dashboard provider data
      context.push('/camera', extra: {
        'meals': dashboardProvider.meals,
        'updateMeals': dashboardProvider.updateMeals,
      });
    }
  }

  Future<void> _showPremiumPaywall(BuildContext context) async {
    print('💎 Opening premium paywall...');
    
    try {
      final result = await PaywallService.showPaywall(
        context,
        offeringId: PaywallService.defaultOfferingId,
        forceCloseOnRestore: false,
      );
      
      if (result) {
        print('✅ Premium subscription activated!');
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

  void _logManually(BuildContext context) {
    // Navigate to manual logging screen
    context.push('/manual-log');
  }

  void _scanReceipt(BuildContext context) {
    // Navigate to receipt scanning screen
    context.push('/receipt-scan');
  }

  void _scanIngredients(BuildContext context) {
    // Navigate to ingredients scanning screen
    context.push('/ingredients-scan');
  }
} 