import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/custom_widgets/wizard_icon.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardHearAboutUs extends StatelessWidget {
  const WizardHearAboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<WizardProvider>(context);
    final selectedSocialMedia = provider.selectedSocialMedia;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 38.h), // or a shared constant
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 120.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Constants.beforeIcon),
                      // Title
                      Text(
                        "wizard_hear_about_us.where_did_you_hear".tr(),
                        style: AppTextStyles.headingMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: kTitleTextStyle.fontSize),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'wizard_hear_about_us.subtitle'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50.h),
                      // Options (buttons with icons)
                      _OptionButton(
                        label: 'wizard_hear_about_us.instagram'.tr(),
                        icon: AppIcons.insta,
                        isSelected: selectedSocialMedia == 0,
                        onTap: () async {
                          AppHaptics.vibrate();
                          provider.selectSocialMedia(0);
                          await provider.saveAllWizardData();
                        },
                      ),
                      SizedBox(height: 14.h),
                      _OptionButton(
                        label: 'wizard_hear_about_us.facebook'.tr(),
                        icon: AppIcons.fb,
                        isSelected: selectedSocialMedia == 1,
                        onTap: () async {
                          AppHaptics.vibrate();
                          provider.selectSocialMedia(1);
                          await provider.saveAllWizardData();
                        },
                      ),
                      SizedBox(height: 14.h),
                      _OptionButton(
                        label: 'wizard_hear_about_us.website'.tr(),
                        icon: AppIcons.web,
                        isSelected: selectedSocialMedia == 2,
                        onTap: () async {
                          AppHaptics.vibrate();
                          provider.selectSocialMedia(2);
                          await provider.saveAllWizardData();
                        },
                      ),
                      SizedBox(height: 14.h),
                      _OptionButton(
                        label: 'wizard_hear_about_us.tiktok'.tr(),
                        icon: AppIcons.tiktok,
                        isSelected: selectedSocialMedia == 3,
                        onTap: () async {
                          AppHaptics.vibrate();
                          provider.selectSocialMedia(3);
                          await provider.saveAllWizardData();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_hear_about_us.continue'.tr(),
          onPressed: () {
            AppHaptics.vibrate();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          isEnabled: selectedSocialMedia != null,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}

// Option Button Widget (for Instagram, Facebook, etc.)
class _OptionButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 66.h,
        padding: EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 18.w),
            WizardIcon(
              assetPath: icon,
              size: 32,
            ),
            SizedBox(width: 22.w),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 19.sp,
              ),
            ),
            const Spacer(),
            Container(
              margin: isRtl
                  ? EdgeInsets.only(left: 16.w)
                  : EdgeInsets.only(right: 16.w),
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? colorScheme.primary : colorScheme.surface,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 13.w,
                        height: 13.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
