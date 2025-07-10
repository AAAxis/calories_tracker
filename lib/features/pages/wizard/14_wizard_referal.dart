import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';
import '15_wizard_great_potential.dart';
import 'dart:io';
import '16_wizard_apple_health.dart';
import '17_wizard_google_fit.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardReferal extends StatefulWidget {
  const WizardReferal({super.key});

  void _navigateToNextScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WizardGreatPotential()),
    );
  }

  @override
  State<WizardReferal> createState() => _WizardReferalState();
}

class _WizardReferalState extends State<WizardReferal> {
  final TextEditingController referralController = TextEditingController();
  final Map<String, String> promoDict = {'777777': 'Success'};
  bool? isPromoValid; // null: not checked, true: valid, false: invalid

  @override
  void initState() {
    super.initState();
    referralController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    referralController.removeListener(_onTextChanged);
    referralController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      // Reset validation when text changes
      isPromoValid = null;
    });
  }

  void _checkPromo() {
    final code = referralController.text.trim();
    setState(() {
      if (promoDict.containsKey(code)) {
        isPromoValid = true;
      } else {
        isPromoValid = false;
      }
    });
  }

  void _navigateToHealthScreen() {
    if (Platform.isIOS) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WizardAppleHealth()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WizardGoogleFit()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<WizardProvider>(context);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120.h), // Add padding to prevent content from being hidden behind fixed button
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 38.h),
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
                SizedBox(height: Constants.afterIcon),
                Text(
                  'wizard_referral.title'.tr(),
                  style: AppTextStyles.headingLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: kTitleTextStyle.fontSize,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                // Input + Submit Button Row in a light container
                Center(
                  child: Container(
                    width: 300.w,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: referralController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Promo Code',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                              counterText: "",
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: referralController.text.trim().isNotEmpty 
                                ? Colors.black 
                                : colorScheme.onSurface.withOpacity(0.15),
                            foregroundColor: referralController.text.trim().isNotEmpty 
                                ? Colors.white 
                                : colorScheme.onSurface.withOpacity(0.7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                          ),
                          onPressed: referralController.text.trim().isNotEmpty ? _checkPromo : null,
                          child: Text('wizard_referral.submit'.tr()),
                        ),
                        SizedBox(width: 8.w),
                        if (isPromoValid != null)
                          Icon(
                            isPromoValid! ? Icons.check_circle : Icons.cancel,
                            color: isPromoValid! ? Colors.green : Colors.red,
                            size: 28.sp,
                          ),
                      ],
                    ),
                  ),
                ),
                if (isPromoValid == true) ...[
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.black, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'wizard_referral.applied'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_referral.continue'.tr(),
          isEnabled: true, // Explicitly enable the button
          onPressed: () {
            AppHaptics.continue_vibrate();
            print("Continue button pressed - navigating to next screen");

            // Since this screen is navigated to via Navigator.push(),
            // we need to use direct navigation to the next screen
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WizardGreatPotential(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
