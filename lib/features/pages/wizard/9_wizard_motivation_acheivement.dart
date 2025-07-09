import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

class WizardMotivationAchiement extends StatelessWidget {
  const WizardMotivationAchiement({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateWeightDifferenceAndIsGain(),
      builder: (context, snapshot) {
        final weightDifference = snapshot.data?['weightDifference'] ?? 0.0;
        final isGain = snapshot.data?['isGain'] ?? false;
        return _buildContent(context, colorScheme, weightDifference, isGain);
      },
    );
  }

  Future<Map<String, dynamic>> _calculateWeightDifferenceAndIsGain() async {
    final prefs = await SharedPreferences.getInstance();
    final currentWeight = prefs.getDouble('wizard_weight') ?? 70.0;
    final targetWeight = prefs.getDouble('wizard_target_weight') ?? 65.0;
    final diff = targetWeight - currentWeight;
    return {
      'weightDifference': diff.abs(),
      'isGain': diff > 0,
    };
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, double weightDifference, bool isGain) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 38.h),
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
                  child: Stack(
                    children: [
                      /// Left-side party popper GIF
                      Positioned(
                        left: -10.w,
                        top: 200.h,
                        child: RepaintBoundary(
                          child: Image.asset(
                            AppAnimations.goal,
                            width: 250.w,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),

                      /// Right-side party popper GIF (mirrored)
                      Positioned(
                        right: -10.w,
                        top: 200.h,
                        child: RepaintBoundary(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: Image.asset(
                              AppAnimations.goal,
                              width: 250.w,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),

                      /// Main Content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: Constants.beforeIcon),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: isGain ? 'wizard_motivation_achievement.gaining'.tr() : 'wizard_motivation_achievement.losing'.tr(),
                                    style: AppTextStyles.headingMedium.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${weightDifference.toStringAsFixed(1)} ${'wizard_motivation_achievement.kg'.tr()}",
                                    style: AppTextStyles.headingMedium.copyWith(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: isGain
                                        ? 'wizard_motivation_achievement.gain_message'.tr()
                                        : 'wizard_motivation_achievement.lose_message'.tr(),
                                    style: AppTextStyles.headingMedium.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
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
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_motivation_achievement.continue'.tr(),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
