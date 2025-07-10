import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
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
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [

            /// Main Content
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
                          SizedBox(height: Constants.beforeIcon),
                          SizedBox(height: 200.h), // Fixed spacing instead of Spacer
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background images (larger and positioned over text)
                              Positioned(
                                left: -30.w,
                                child: Image.asset(
                                  AppAnimations.goal,
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                ),
                              ),
                              Positioned(
                                right: -30.w,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(3.14159),
                                  child: Image.asset(
                                    AppAnimations.goal,
                                    width: 120.w,
                                    height: 120.h,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                              // Text content (centered and overlaid)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.w),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: isGain ? 'wizard_motivation_achievement.gaining'.tr() : 'wizard_motivation_achievement.losing'.tr(),
                                        style: AppTextStyles.headingMedium.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: kTitleTextStyle.fontSize,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${weightDifference.toStringAsFixed(1)} ${'wizard_motivation_achievement.kg'.tr()}",
                                        style: AppTextStyles.headingMedium.copyWith(
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: kTitleTextStyle.fontSize,
                                        ),
                                      ),
                                      TextSpan(
                                        text: isGain
                                            ? 'wizard_motivation_achievement.gain_message'.tr()
                                            : 'wizard_motivation_achievement.lose_message'.tr(),
                                        style: AppTextStyles.headingMedium.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: kTitleTextStyle.fontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 100.h), // Fixed spacing instead of Spacer
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
          label: 'wizard_motivation_achievement.continue'.tr(),
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
