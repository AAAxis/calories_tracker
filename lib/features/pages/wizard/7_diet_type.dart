import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/custom_widgets/wizard_icon.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardDietType extends StatelessWidget {
  const WizardDietType({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<WizardProvider>(context);
    final selectedDiet = provider.selectedDiet;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    final diets = [
      {
        'label': 'wizard_diet_type.regular'.tr(),
        'icon': AppIcons.regular_1,
      },
      {
        'label': 'wizard_diet_type.vegetarian'.tr(),
        'icon':  AppIcons.vegetarian_2,
      },
      {
        'label': 'wizard_diet_type.vegan'.tr(),
        'icon':  AppIcons.vegan_1,
      },
      {
        'label': 'wizard_diet_type.keto'.tr(),
        'icon':  AppIcons.kato_2,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 38.h),
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w, top: 8.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                      onPressed: () {
                        // Navigate back using the wizard provider
                        Provider.of<WizardProvider>(context, listen: false).prevPage();
                      },
                    ),
                  ),
                ),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 120.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: Constants.beforeIcon),
                          Text(
                            'wizard_diet_type.title'.tr(),
                            style: AppTextStyles.headingLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: kTitleTextStyle.fontSize,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_diet_type.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 34.h),
                          ...List.generate(diets.length, (i) {
                            final isSelected = selectedDiet == i;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 18.h),
                              child: GestureDetector(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  provider.selectDiet(i);
                                  await provider.saveAllWizardData();
                                },
                                child: Container(
                                  height: 66.h,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(alpha: 0.06),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 18.w),
                                      WizardIcon(
                                        assetPath: diets[i]['icon']!,
                                        size: 30,
                                      ),
                                      SizedBox(width: 22.w),
                                      Text(
                                        diets[i]['label']!,
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
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.outline,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.surface,
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
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_diet_type.continue'.tr(),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          isEnabled: selectedDiet != null,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
