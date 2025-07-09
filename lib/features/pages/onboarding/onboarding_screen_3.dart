import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/custom_widgets/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen3 extends StatelessWidget {
  final VoidCallback? onFinish;
  const OnboardingScreen3({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';
    final dots = [
      // First dot
      Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          shape: BoxShape.circle,
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
      // Third wider dot (active)
      AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 24.w,
        height: 8.h,
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(50.r),
        ),
      ),
    ];

    // Use your actual image asset from app_images.dart
    final bgImage = AssetImage(AppImages.foodGirl);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(child: Image(image: bgImage, fit: BoxFit.cover)),
// Weight goal card
          Positioned(
            top: 55.h,
            left: 32.w,
            right: 32.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 22.w, vertical: 6.h), // reduced vertical padding
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(100),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "onboarding3.weight_goal".tr(),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp, // reduced from 20
                          ),
                        ),
                        Text(
                          "onboarding3.weight_value".tr(),
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 26.sp, // reduced from 32
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32.h, // reduced from 40
                    width: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.onPrimary,
                        width: 2.w,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppIcons.drop,
                        color: colorScheme.onPrimary,
                        height: 20.h,
                        width: 20.w,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Bottom card with info
          Positioned(
            left: 18.w,
            right: 18.w,
            bottom: 30.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(200), // ~88% opacity
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "onboarding3.transform_body".tr(),
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "onboarding3.start_today".tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18.h),
                  Center(
                    child: PrimaryButton(
                      label: 'onboarding3.get_started'.tr(),
                      onPressed: onFinish ?? () => context.go(AppRoutes.wizardPager),
                    ),
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
        ],
      ),
    );
  }
}
