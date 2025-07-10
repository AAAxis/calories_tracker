import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_images.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardAccountSummary extends StatelessWidget {
  const WizardAccountSummary({super.key});

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
                'wizard_account_summary.title'.tr(),
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: kTitleTextStyle.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              // Description Text
              Text(
                'wizard_account_summary.description'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              // Image Display from Assets
              Image.asset(
                AppImages.fz,
                width: 358.w,
                height: 202.h,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_account_summary.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            // Your action here
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
