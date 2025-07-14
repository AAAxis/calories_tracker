import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';

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
        backgroundColor: Colors.white,
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
                  label: 'Scan Meal',
                  onTap: () => _openCamera(context),
                ),
                SizedBox(height: 24.h),
                _buildOptionButton(
                  context,
                  icon: Icons.inventory_2,
                  label: 'Scan Ingredient',
                  onTap: () => _scanIngredients(context),
                ),
                  SizedBox(height: 24.h),
                _buildOptionButton(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Scan Receipt',
                  onTap: () => _scanReceipt(context),
                ),
                SizedBox(height: 24.h),
                _buildOptionButton(
                  context,
                  icon: Icons.edit_note,
                  label: 'Log Manually',
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

  void _openCamera(BuildContext context) {
    // Navigate to camera screen with dashboard provider data
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    context.push('/camera', extra: {
      'meals': dashboardProvider.meals,
      'updateMeals': dashboardProvider.updateMeals,
    });
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