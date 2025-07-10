import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_animations.dart';
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

class WizardHowFast extends StatelessWidget {
  const WizardHowFast({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    final steps = [0.1, 0.8, 1.5];
    final current = provider.goalSpeed;
    final selectedGoal = provider.selectedGoal ?? 0; // 0=lose, 1=maintain, 2=gain
    final isGain = selectedGoal == 2;

    int getActiveIndex() {
      double minDiff = (current - steps[0]).abs();
      int idx = 0;
      for (int i = 1; i < steps.length; i++) {
        double diff = (current - steps[i]).abs();
        if (diff < minDiff) {
          minDiff = diff;
          idx = i;
        }
      }
      return idx;
    }

    final active = getActiveIndex();

    String getAdvice() {
      if (active == 0) return isGain ? 'wizard_how_fast.advice_gain_slow'.tr() : 'wizard_how_fast.advice_lose_slow'.tr();
      if (active == 1) return isGain ? 'wizard_how_fast.advice_gain_good'.tr() : 'wizard_how_fast.advice_lose_good'.tr();
      return isGain ? 'wizard_how_fast.advice_gain_fast'.tr() : 'wizard_how_fast.advice_lose_fast'.tr();
    }

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
                            'wizard_how_fast.title'.tr(),
                            style: AppTextStyles.headingLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: kTitleTextStyle.fontSize,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'wizard_how_fast.subtitle'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 50.h),
                          Text(
                            "${current.toStringAsFixed(1)} ${'wizard_how_fast.kg_per_week'.tr()}",
                            style: AppTextStyles.headingLarge.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(height: 50.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: isRtl ? [

                              _SpeedAnimalItem(
                                activeAsset: AppAnimations.rabbit_g,
                                inactiveAsset: AppIcons.rabbit_b,
                                active: active == 0,
                                isRtl: isRtl,
                              ),
                              _SpeedAnimalItem(
                                activeAsset: AppAnimations.horse_g,
                                inactiveAsset: AppIcons.horse_b,
                                active: active == 1,
                                isRtl: isRtl,
                              ),_SpeedAnimalItem(
                                activeAsset: AppAnimations.tiger_g,
                                inactiveAsset: AppIcons.tiger_b,
                                active: active == 2,
                                isRtl: isRtl,
                              ),
                            ] : [
                              _SpeedAnimalItem(
                                activeAsset: AppAnimations.rabbit_g,
                                inactiveAsset: AppIcons.rabbit_b,
                                active: active == 0,
                                isRtl: isRtl,
                              ),
                              _SpeedAnimalItem(
                                activeAsset: AppAnimations.horse_g,
                                inactiveAsset: AppIcons.horse_b,
                                active: active == 1,
                                isRtl: isRtl,
                              ),
                              _SpeedAnimalItem(
                                activeAsset: AppAnimations.tiger_g,
                                inactiveAsset: AppIcons.tiger_b,
                                active: active == 2,
                                isRtl: isRtl,
                              ),
                            ],
                          ),
                          SizedBox(height: 0.h),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              activeTrackColor: Colors.black,
                              inactiveTrackColor: Colors.black26,
                              thumbColor: Colors.black,
                            ),
                            child: Slider(
                              value: current,
                              min: steps.first,
                              max: steps.last,
                              divisions: 14,
                              onChanged: (value) async {
                                AppHaptics.vibrate();
                                provider.setGoalSpeed(value);
                                await provider.saveAllWizardData();
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'wizard_how_fast.slow'.tr(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 10.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'wizard_how_fast.medium'.tr(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 10.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'wizard_how_fast.fast'.tr(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 10.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 50.h),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              getAdvice(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
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
          label: 'wizard_how_fast.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}

class _SpeedAnimalItem extends StatelessWidget {
  final String activeAsset;
  final String inactiveAsset;
  final bool active;
  final bool isRtl;

  const _SpeedAnimalItem({
    required this.activeAsset,
    required this.inactiveAsset,
    required this.active,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = active
        ? Image.asset(
            activeAsset,
            width: 50.w,
            height: 50.w,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          )
        : WizardIcon(
            assetPath: inactiveAsset,
            size: 50,
          );
    return isRtl
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.14159),
            child: image,
          )
        : image;
  }
}
