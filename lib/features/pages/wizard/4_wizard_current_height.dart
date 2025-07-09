import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardCurrentHeight extends StatelessWidget {
  const WizardCurrentHeight({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isMetric = provider.isMetric;
    final height = provider.height;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    const minCm = 140;
    const maxCm = 220;
    const minInch = 48;
    const maxInch = 84;

    // Set sensible defaults if height is not set
    int defaultCm = 180;
    int defaultInch = 66;
    int effectiveHeight;
    if (height == 0) {
      effectiveHeight = isMetric ? defaultCm : defaultInch;
      provider.setHeight(effectiveHeight);
    } else {
      effectiveHeight = height;
    }

    final min = isMetric ? minCm : minInch;
    final max = isMetric ? maxCm : maxInch;
    final count = max - min + 1;

    // Ensure height is within valid range for current unit
    final clampedHeight = effectiveHeight.clamp(min, max);
    final initialIndex = clampedHeight - min;
    final controller = FixedExtentScrollController(initialItem: initialIndex);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 38.h),
                // Header Row with Back Button and App Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
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
                      Expanded(
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(isRtl ? 20 : -20, 0),
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
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 120.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: Constants.beforeIcon),
                          Text(
                            "wizard_height.title".tr(),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: kTitleTextStyle.fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_height.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 22.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _UnitToggleButton(
                                label: "wizard_height.inches".tr(),
                                isActive: !isMetric,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  if (isMetric) {
                                    final heightInInches = (height * 0.393701).round();
                                    final clampedHeight = heightInInches.clamp(minInch, maxInch);
                                    provider.setHeight(clampedHeight);
                                  }
                                  provider.toggleMetric(false);
                                  await provider.saveAllWizardData();
                                },
                              ),
                              SizedBox(width: 18.w),
                              _UnitToggleButton(
                                label: "wizard_height.cm".tr(),
                                isActive: isMetric,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  if (!isMetric) {
                                    final heightInCm = (height * 2.54).round();
                                    final clampedHeight = heightInCm.clamp(minCm, maxCm);
                                    provider.setHeight(clampedHeight);
                                  }
                                  provider.toggleMetric(true);
                                  await provider.saveAllWizardData();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 18.h),
                          SizedBox(
                            height: 300.h,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ListWheelScrollView.useDelegate(
                                  itemExtent: 50.h,
                                  diameterRatio: 1.5,
                                  physics: const FixedExtentScrollPhysics(),
                                  controller: controller,
                                  onSelectedItemChanged: (i) async {
                                    final selectedHeight = min + i;
                                    provider.setHeight(selectedHeight);
                                    await provider.saveAllWizardData();
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: count,
                                    builder: (context, i) {
                                      final value = min + i;
                                      final isSelected = value == height;
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (isSelected)
                                            Container(
                                              margin: EdgeInsets.only(top: 18.sp),
                                              child: Transform.rotate(
                                                angle: isRtl ? math.pi : 0,
                                              ),
                                            ),
                                          SizedBox(width: isSelected ? 8.w : 40.w),
                                          Text(
                                            isMetric ? "$value" : "$value",
                                            style: AppTextStyles.headingLarge.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? colorScheme.onSurface
                                                  : colorScheme.onSurface.withAlpha(90),
                                              fontSize: isSelected ? 42.sp : 22.sp,
                                            ),
                                          ),
                                          if (isSelected)
                                            Padding(
                                              padding: EdgeInsets.only(left: 6.w,top: 5.w,right: 10.w),
                                              child: Text(
                                                isMetric ? "wizard_height.cm".tr() : "wizard_height.inches".tr(),
                                                style: AppTextStyles.headingMedium.copyWith(
                                                  color: colorScheme.onSurface,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isSelected ? 30.sp : 22.sp,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 10.h),
                                        height: 2,
                                        width: 200.w,
                                        color: colorScheme.onSurface.withAlpha(50),
                                      ),
                                      SizedBox(height: 68.h),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 0.h),
                                        height: 2,
                                        width: 200.w,
                                        color: colorScheme.onSurface.withAlpha(50),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0.h),
          child: WizardButton(
            label: 'wizard_height.continue'.tr(),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Provider.of<WizardProvider>(context, listen: false).nextPage();
            },
            isEnabled: height > 0,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          ),
        ),
      ),
    );
  }
}

class _UnitToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _UnitToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outline.withAlpha(150),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
