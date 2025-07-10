import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardWorkout extends StatelessWidget {
  const WizardWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    final options = [
      'wizard_workout.option_0_2'.tr(),
      'wizard_workout.option_2_4'.tr(),
      'wizard_workout.option_4_6'.tr(),
      'wizard_workout.option_6_8'.tr(),
    ];

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
                            // Navigate back using the wizard provider
                            AppHaptics.back_vibrate();
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: Constants.beforeIcon),
                          Text(
                            'wizard_workout.title'.tr(),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: kTitleTextStyle.fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_workout.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 70.h),
                          GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20.h,
                              crossAxisSpacing: 18.w,
                              childAspectRatio: 1.28,
                            ),
                            itemCount: options.length,
                            itemBuilder: (context, i) {
                              final isSelected = provider.selectedWorkoutIndex == i;
                              return GestureDetector(
                                onTap: () async {
                                  AppHaptics.vibrate();
                                  provider.selectWorkoutIndex(i);
                                  await provider.saveAllWizardData();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary.withValues(alpha: 0.1)
                                        : colorScheme.surface,
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                      width: isSelected ? 3 : 2,
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
                                  child: Center(
                                    child: Text(
                                      options[i],
                                      style: AppTextStyles.headingLarge.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
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
          label: 'wizard_workout.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          isEnabled: provider.selectedWorkoutIndex != null,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
