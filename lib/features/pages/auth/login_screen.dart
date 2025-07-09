import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/constants/app_icons.dart';
import '../../../core/custom_widgets/social_button.dart';
import '../../../core/services/auth_service.dart';
import 'login_with_email_screen.dart';

import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.signInWithApple();

      if (result.isSuccess) {
        await _handleLoginSuccess();
      } else {
        _showError(result.error ?? 'login.apple_sign_in_failed'.tr());
      }
    } catch (e) {
      _showError('${'login.apple_sign_in_failed'.tr()}: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.signInWithGoogle();

      if (result.isSuccess) {
        await _handleLoginSuccess();
      } else {
        _showError(result.error ?? 'login.google_sign_in_failed'.tr());
      }
    } catch (e) {
      _showError('${'login.google_sign_in_failed'.tr()}: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLoginSuccess() async {
    if (mounted) {
      // Navigate to new dashboard using go_router
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/bottom-nav');
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // X button in top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8.h, right: 8.w),
                    child: IconButton(
                      onPressed: _isLoading ? null : () {
                        context.go('/bottom-nav');
                      },
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface,
                        size: 24.sp,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size(44.w, 44.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
              // App Title
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
              SizedBox(height: 8.h),
              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Sign in to continue your journey',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              
              // Platform-specific social login buttons
              if (Platform.isIOS) ...[
                // Apple Button (iOS only)
                SocialButton(
                  label: 'login.continue_with_apple'.tr(),
                  assetPath: AppIcons.apple,
                  onPressed: _isLoading ? null : _handleAppleSignIn,
                  borderColor: colorScheme.outline,
                  textColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surface,
                ),
                SizedBox(height: 18.h),
              ],
              
              if (Platform.isAndroid) ...[
                // Google Button (Android only)
                SocialButton(
                  label: 'login.continue_with_google'.tr(),
                  assetPath: AppIcons.google,
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  borderColor: colorScheme.outline,
                  textColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surface,
                ),
                SizedBox(height: 18.h),
              ],
              
              // Email button (always available)
              SocialButton(
                label: 'login.continue_with_email'.tr(),
                assetPath: AppIcons.email,
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginWithEmailScreen(),
                    ),
                  );
                },
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
                backgroundColor: colorScheme.surface,
              ),
              
              // Loading indicator
              if (_isLoading) ...[
                SizedBox(height: 32.h),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ],
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
