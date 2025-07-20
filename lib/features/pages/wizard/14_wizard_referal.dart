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
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
  bool? isPromoValid; // null: not checked, true: valid, false: invalid
  bool isCheckingCode = false;
  String? validatedReferralCode;
  bool _isNavigating = false; // Add navigation lock

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
      validatedReferralCode = null;
    });
  }

  Future<void> _checkPromo() async {
    final code = referralController.text.trim().toUpperCase();
    if (code.isEmpty) {
      // If no code entered, just navigate to next screen
      _navigateToNextScreen();
      return;
    }

    setState(() {
      isCheckingCode = true;
      isPromoValid = null;
    });

    try {
      // Query Firebase Firestore for the referral code
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ReferralCodes')
          .where('code', isEqualTo: code)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Code exists and is active
        final docData = querySnapshot.docs.first.data();
        print('✅ Valid referral code found: $code');
        print('📧 Associated email: ${docData['email']}');
        
        setState(() {
          isPromoValid = true;
          validatedReferralCode = code;
          isCheckingCode = false;
        });

        // Store the referral code in the wizard provider for later use
        final provider = Provider.of<WizardProvider>(context, listen: false);
        provider.setReferralCode(code);
        
        // Show success message briefly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Text('wizard_referral.applied'.tr()),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1200),
          ),
        );
        
        // Mark as used and navigate after short delay
        await _markReferralCodeAsUsed();
        await Future.delayed(Duration(milliseconds: 1400));
        _navigateToNextScreen();
        
      } else {
        // Code doesn't exist or is not active
        print('❌ Invalid referral code: $code');
        setState(() {
          isPromoValid = false;
          validatedReferralCode = null;
          isCheckingCode = false;
        });
        
        // Show error message briefly then navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8.w),
                Text('Invalid referral code'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 1200),
          ),
        );
        
        // Navigate after showing error
        await Future.delayed(Duration(milliseconds: 1400));
        _navigateToNextScreen();
      }
    } catch (e) {
      print('❌ Error checking referral code: $e');
      setState(() {
        isPromoValid = false;
        validatedReferralCode = null;
        isCheckingCode = false;
      });
      
      // Show error message to user then navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking referral code. Continuing...'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 1200),
          ),
        );
        
        await Future.delayed(Duration(milliseconds: 1400));
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() {
    if (_isNavigating) {
      print('🚫 Navigation already in progress, ignoring...');
      return;
    }
    
    _isNavigating = true;
    print('🎬 _navigateToNextScreen called - setting navigation lock');
    
    try {
      final provider = Provider.of<WizardProvider>(context, listen: false);
      print('🎬 Calling provider.nextPage() from referral screen');
      provider.nextPage();
    } catch (e) {
      print('❌ Error during navigation: $e');
    } finally {
      // Reset navigation lock after a delay
      Future.delayed(Duration(milliseconds: 300), () {
        _isNavigating = false;
        print('🔓 Navigation lock released');
      });
    }
  }

  Future<void> _markReferralCodeAsUsed() async {
    if (validatedReferralCode == null) return;

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('⚠️ No authenticated user found');
        return;
      }

      // Query to find the specific referral code document for tracking info
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ReferralCodes')
          .where('code', isEqualTo: validatedReferralCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // DON'T update the original referral code document - keep it unchanged
        // Just create a usage record for tracking purposes
        await FirebaseFirestore.instance
            .collection('ReferralUsage')
            .add({
          'referralCode': validatedReferralCode,
          'usedBy': user.uid,
          'usedByEmail': user.email,
          'usedAt': FieldValue.serverTimestamp(),
          'originalReferrerEmail': querySnapshot.docs.first.data()['email'],
        });

        print('✅ Referral usage record created for tracking');
        print('📝 Original referral code remains unchanged for reuse');

        // Set RevenueCat custom attribute for the referral code
        await _setRevenueCatReferralAttribute(validatedReferralCode!);
      }
    } catch (e) {
      print('❌ Error tracking referral code usage: $e');
    }
  }

  Future<void> _setRevenueCatReferralAttribute(String referralCode) async {
    try {
      // Set custom attribute in RevenueCat
      await Purchases.setAttributes({
        'referral_code_used': referralCode,
      });
      
      print('✅ RevenueCat custom attribute set: referral_code_used = $referralCode');
      
    } catch (e) {
      print('❌ Error setting RevenueCat custom attribute: $e');
    }
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
    final provider = Provider.of<WizardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    print('🔍 REFERRAL SCREEN: Building at provider index ${provider.currentIndex}');
    print('🔍 REFERRAL SCREEN: Expected to be at index 13');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                                maxLength: 10, // Increased from 6 to accommodate codes like "INFL001"
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: referralController.text.trim().isNotEmpty && !isCheckingCode
                                    ? Colors.black 
                                    : colorScheme.onSurface.withOpacity(0.15),
                                foregroundColor: referralController.text.trim().isNotEmpty && !isCheckingCode
                                    ? Colors.white 
                                    : colorScheme.onSurface.withOpacity(0.7),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              ),
                              onPressed: isCheckingCode ? null : () {
                                if (_isNavigating) return; // Internal lock only
                                _checkPromo();
                              },
                              child: isCheckingCode 
                                  ? SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text('wizard_referral.submit'.tr()),
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            // X button in top right corner
            Positioned(
              top: 16.h,
              right: 16.w,
              child: GestureDetector(
                onTap: () {
                  if (_isNavigating) return; // Extra protection
                  
                  AppHaptics.continue_vibrate();
                  // Navigate to next screen instead of going back
                  _navigateToNextScreen();
                },
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: colorScheme.onSurface,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
