import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/custom_widgets/wizard_icon.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);
const double kGoalIconSize = 30.0;

class WizardGoalType extends StatelessWidget {
  const WizardGoalType({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<WizardProvider>(context);
    final selectedGoal = provider.selectedGoal;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    final goals = [
      {
        'label': 'wizard_goal_type.lose_weight'.tr(),
        'icon': AppIcons.loseWeight_10,
      },
      {
        'label': 'wizard_goal_type.maintain_weight'.tr(),
        'icon': AppIcons.maintainWeight_5,
      },
      {
        'label': 'wizard_goal_type.gain_weight'.tr(),
        'icon': AppIcons.gainWeight_10,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: Constants.afterIcon),
                          Text(
                            'wizard_goal_type.title'.tr(),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: kTitleTextStyle.fontSize,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_goal_type.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 100.h),
                          ...List.generate(goals.length, (i) {
                            final isSelected = selectedGoal == i;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 18.h),
                              child: GestureDetector(
                                onTap: () async {
                                  AppHaptics.vibrate();
                                  provider.selectGoal(i);
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
                                        assetPath: goals[i]['icon']!,
                                        size: kGoalIconSize,
                                      ),
                                      SizedBox(width: 22.w),
                                      Text(
                                        goals[i]['label']!,
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
          label: 'wizard_goal_type.continue'.tr(),
          onPressed: () {
            AppHaptics.vibrate();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          isEnabled: selectedGoal != null,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
