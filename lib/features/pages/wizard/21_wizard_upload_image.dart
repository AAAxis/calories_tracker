import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class Wizard16 extends StatelessWidget {
  const Wizard16({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
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
              SizedBox(height: 20.h),
              // Title
              Text(
                'wizard_upload_image.title'.tr(),
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: kTitleTextStyle.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              // Placeholder for Image Icon (you can replace it with an image picker later)
              Container(
                height: 120.h,
                width: 120.w,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 60.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: 28.h),
              // Buttons: Add Photo, Skip for now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add Photo Button
                  ElevatedButton(
                    onPressed: () {
                      // Add logic to allow the user to pick an image
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.w, vertical: 14.h),
                    ),
                    child: Text(
                      'wizard_upload_image.add_photo'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Skip Button
                  ElevatedButton(
                    onPressed: () {
                      // Add logic for skipping the upload
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.w, vertical: 14.h),
                    ),
                    child: Text(
                      'wizard_upload_image.skip_for_now'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_upload_image.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            // Your action here
            Provider.of<WizardProvider>(context, listen: false)
                .nextPage();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
