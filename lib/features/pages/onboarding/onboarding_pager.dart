import 'package:flutter/material.dart';
import 'onboarding_screen_1.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_screen_3.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class OnboardingPager extends StatefulWidget {
  const OnboardingPager({super.key});

  @override
  State<OnboardingPager> createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  final PageController _controller = PageController();

   void nextPage() {
    if (_controller.page! < 2) {
      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void finishOnboarding() {
    context.go(AppRoutes.wizardPager);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const ClampingScrollPhysics(),
        children: [
          OnboardingScreen1(onNext: nextPage),
          OnboardingScreen2(onNext: nextPage),
          OnboardingScreen3(onFinish: finishOnboarding),
        ],
      ),
    );
  }
} 