import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';
class WizardYourAge extends StatelessWidget {
  const WizardYourAge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<WizardProvider>(context);
    final selectedAge = provider.age;
    final selectedGender = provider.selectedGender;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    // Set sensible default if age is not set
    final effectiveAge = selectedAge == 0 ? 30 : selectedAge;
    if (selectedAge == 0) provider.setAge(30);
    final controller =
        FixedExtentScrollController(initialItem: effectiveAge - 10);

    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                            AppHaptics.vibrate();
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
                            'wizard_age.title'.tr(),
                            style: AppTextStyles.headingLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_age.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 36.h),
                          SizedBox(
                            height: 300.h,
                            child: ListWheelScrollView.useDelegate(
                              controller: controller,
                              itemExtent: 100.h,
                              diameterRatio: 1.15,
                              perspective: 0.004,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) async {
                                provider.setAge(index + 10);
                                await provider.saveAllWizardData();
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 70,
                                builder: (context, i) {
                                  final age = i + 10;
                                  final isSelected = age == provider.age;
                                  return Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, vertical: 7.h),
                                      decoration: isSelected
                                          ? BoxDecoration(
                                              color:
                                                  colorScheme.primary.withValues(alpha: 0.66),
                                              borderRadius: BorderRadius.circular(16),
                                            )
                                          : null,
                                      child: Text(
                                        '$age',
                                        style: AppTextStyles.headingLarge.copyWith(
                                          color: isSelected
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface.withValues(alpha: 0.5),
                                          fontSize: isSelected ? 60.sp : 48.sp,
                                          fontWeight:
                                              isSelected ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_age.continue'.tr(),
          onPressed: () {
            AppHaptics.vibrate();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
