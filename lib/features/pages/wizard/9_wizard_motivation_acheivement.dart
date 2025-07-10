import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class WizardMotivationAchiement extends StatelessWidget {
  final bool isGain;

  const WizardMotivationAchiement({
    super.key,
    required this.isGain,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<double>(
      future: _calculateWeightDifference(),
      builder: (context, snapshot) {
        final weightDifference = snapshot.data ?? 0.0;

        return _buildContent(context, colorScheme, weightDifference);
      },
    );
  }

  Future<double> _calculateWeightDifference() async {
    final prefs = await SharedPreferences.getInstance();
    final currentWeight = prefs.getDouble('wizard_weight') ?? 70.0;
    final targetWeight = prefs.getDouble('wizard_target_weight') ?? 65.0;
    return (targetWeight - currentWeight).abs();
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, double weightDifference) {
    final isRtl = Localizations.localeOf(context).languageCode == 'he';
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

                            SizedBox(height: Constants.afterIcon),
                            const Spacer(),
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
                            const Spacer(),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
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
          label: 'wizard_motivation_achievement.continue'.tr(),
          onPressed: () {
            AppHaptics.continue_vibrate();
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          isEnabled: true,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
