import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardYourWeight extends StatelessWidget {
  const WizardYourWeight({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isKg = provider.isKg;
    final weight = provider.weight;

    final min = isKg ? 40.0 : 90.0;
    final max = isKg ? 150.0 : 330.0;
    final step = 0.1;
    final itemCount = ((max - min) / step).floor() + 1;
    final initialIndex = ((weight - min) / step).round();
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    final itemExtent = isKg ? 20.w : 26.w;

    return SafeArea(
      child: Scaffold(
        body: Stack(
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
                        children: [
                          SizedBox(height: Constants.beforeIcon),
                          Text(
                            "wizard_weight.title".tr(),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: kTitleTextStyle.fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_weight.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _UnitToggleButton(
                                label: "wizard_weight.lbs".tr(),
                                isActive: !isKg,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  provider.toggleUnit(false);
                                  await provider.saveAllWizardData();
                                },
                              ),
                              SizedBox(width: 18.w),
                              _UnitToggleButton(
                                label: "wizard_weight.kgs".tr(),
                                isActive: isKg,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  provider.toggleUnit(true);
                                  await provider.saveAllWizardData();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 100.h),
                          Text(
                            '${weight.toStringAsFixed(1)} ${isKg ? "wizard_weight.kg".tr() : "wizard_weight.lb".tr()}',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 40.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.h),
                          SizedBox(
                            height: 100.h,
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: ListWheelScrollView.useDelegate(
                                controller: controller,
                                itemExtent: itemExtent,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) async {
                                  final value = min + (index * step);
                                  provider.setWeight(value);
                                  await provider.saveAllWizardData();
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: itemCount,
                                  builder: (context, idx) {
                                    final value = min + idx * step;
                                    final isSelected = (value.toStringAsFixed(1) == weight.toStringAsFixed(1));
                                    final isWholeUnit = (value * 10) % 10 == 0;

                                    double height;
                                    if (isSelected) {
                                      height = 55.h;
                                    } else if (isWholeUnit) {
                                      height = 40.h;
                                    } else {
                                      height = 25.h;
                                    }

                                    return RotatedBox(
                                      quarterTurns: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: isSelected ? 3.5.w : 2.w,
                                            height: height,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colorScheme.onSurface
                                                  : colorScheme.onSurface.withAlpha(100),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          if (isWholeUnit)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4.h),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  value.toStringAsFixed(0),
                                                  style: AppTextStyles.bodyLarge.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: colorScheme.onSurface,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
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
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: WizardButton(
            label: 'wizard_weight.continue'.tr(),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Provider.of<WizardProvider>(context, listen: false).nextPage();
            },
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
