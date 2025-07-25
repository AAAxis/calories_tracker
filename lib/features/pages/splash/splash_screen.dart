import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkWizardCompletion();
  }

  void _checkWizardCompletion() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        // Get the appropriate route based on auth state
        final route = AuthService.getInitialRoute();
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Calzo',
          style: textTheme.headlineLarge?.copyWith(
            fontFamily: 'RusticRoadway',
            color: Colors.black,
            fontSize: 60.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ) ?? AppTextStyles.headingLarge.copyWith(
            fontFamily: 'RusticRoadway',
            color: Colors.black,
            fontSize: 60.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
