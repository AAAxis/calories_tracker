import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/custom_widgets/custom_text_field.dart';
import '../../../core/custom_widgets/wide_elevated_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_text_styles.dart';
import 'forgot_password_screen.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({super.key});

  @override
  _LoginWithEmailScreenState createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('🔑 Attempting login with email: ${_emailController.text.trim()}');
      
      final result = await AuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.isSuccess) {
        await _handleLoginSuccess();
      } else {
        _showError(result.error ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      _showError('An unexpected error occurred. Please try again.');
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
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // X button in top right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.go('/bottom-nav');
                        },
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurface,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  
                  // App Logo
                  Image.asset(
                    AppIcons.kali,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: 20.h),
                  
                  // Title
                  Text(
                    "Welcome Back!",
                    style: AppTextStyles.headingMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  
                  // Subtitle
                  Text(
                    "Sign in to continue your journey",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 36.h),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    labelText: "Email Address",
                    hintText: "Enter your email",
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      child: Image.asset(
                        AppIcons.email,
                        color: colorScheme.onSurfaceVariant,
                        width: 18.w,
                        height: 18.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: "Password",
                    hintText: "Enter your password",
                    obscureText: _obscurePassword,
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      child: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                        size: 18.sp,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 150.h),

                  // Login Button
                  WideElevatedButton(
                    label: _isLoading ? 'Signing In...' : 'Sign In',
                    onPressed: _isLoading ? null : _handleEmailLogin,
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                    borderRadius: 24,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    elevation: 10,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  
                  SizedBox(height: 24.h),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
                        },
                        child: Text(
                          "Sign Up",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 