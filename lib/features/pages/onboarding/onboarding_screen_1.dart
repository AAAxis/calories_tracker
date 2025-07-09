import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/custom_widgets/primary_button.dart';
import '../../../core/custom_widgets/scanner_frame.dart';
import '../../../core/custom_widgets/skip_button.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen1 extends StatelessWidget {
  final VoidCallback? onNext;
  const OnboardingScreen1({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';
    final dots = [
      // First wider dot (active)
      AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 24.w,
        height: 8.h,
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(50.r),
        ),
      ),
      SizedBox(width: 6.w),
      // Second dot
      Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: 6.w),
      // Third dot
      Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          shape: BoxShape.circle,
        ),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background food image
          Positioned.fill(
            child: Image.asset(AppImages.steak, fit: BoxFit.cover),
          ),
          // Overlay (use theme background with alpha)
          Positioned.fill(
            child: Container(
              color: colorScheme.primary.withAlpha(
                51,
              ), // Semi-transparent overlay
            ),
          ),
          // Skip button
          Positioned(
            top: 70.h,
            left: isRtl ? 20.w : null,
            right: isRtl ? null : 20.w,
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.onboarding3),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary
                      .withAlpha(50), // Slightly transparent, for soft overlay
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onPrimary
                          .withAlpha(80), // Soft glow using theme color
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.onPrimary
                        .withAlpha(50), // Soft border for clarity
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'onboarding2.skip'.tr(),
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary, // Always readable
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Scanning text
          Positioned(
            top: 80.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'onboarding2.scanning'.tr(),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          // White scanner box
          Padding(
            padding: EdgeInsets.only(bottom: 80.sp),
            child: Center(
              child: ScannerFrame(
                size: 240, // your size.w
                color: Theme.of(context).colorScheme.onPrimary,
                cornerRadius: 14, // Try 10~16 for a subtle round
                cornerLength: 32,
                thickness: 4,
              ),
            ),
          ),
          // Bottom content
          Positioned(
            left: 0,
            right: 0,
            bottom: 32.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(200),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "onboarding.effortless_calorie_tracking".tr(),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "onboarding.snap_meal".tr(),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    PrimaryButton(
                      label: "onboarding.continue".tr(),
                      onPressed: onNext ?? () => context.go(AppRoutes.onboarding2),
                    ),
                    SizedBox(height: 10.h),
                    // Indicator (•••)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: isRtl ? dots.reversed.toList() : dots,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
