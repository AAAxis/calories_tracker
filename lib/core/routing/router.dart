// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';

// Import all your screen widgets here:
import '../../features/pages/splash/splash_screen.dart';
import '../../features/pages/onboarding/onboarding_screen_2.dart';
import '../../features/pages/onboarding/onboarding_screen_3.dart';
import '../../features/pages/onboarding/onboarding_pager.dart';

// Import auth screens
import '../../features/pages/auth/login_screen.dart';
import '../../features/pages/auth/signup_screen.dart';
import '../../modules/bottom_nav/views/bottom_nav_view.dart';
import '../../features/pages/wizard/16_wizard_apple_health.dart';
import '../../features/pages/wizard/17_wizard_google_fit.dart';
import '../../features/pages/wizard/12_wizard_loading_page.dart';
import '../../features/pages/wizard/5_wizard_your_age.dart';
import '../../features/pages/wizard/11_wizard_how_fast.dart';
import '../../features/pages/wizard/13_wizard_summary_date_and_measurments.dart';
import '../../features/pages/wizard/15_wizard_great_potential.dart';
import '../../features/pages/wizard/18_wizard_notification.dart';
import '../../features/pages/wizard/19_wizard_recommendation.dart';
import '../../features/pages/wizard/1_wizard_hear_about_us.dart';
import '../../features/pages/wizard/4_wizard_current_height.dart';
import '../../features/pages/wizard/3_wizard_your_weight.dart';
import '../../features/pages/wizard/2_wizard_gender.dart';
import '../../features/pages/wizard/6_wizard_goal_type.dart';
import '../../features/pages/wizard/7_diet_type.dart';
import '../../features/pages/wizard/8_wizard_dream_weight.dart';
import '../../features/pages/wizard/9_wizard_motivation_acheivement.dart';
import '../../features/pages/wizard/10_wizard_workout.dart';
import '../../features/pages/wizard/wizard_pager.dart';
import '../../features/providers/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:calories_tracker/modules/profile/views/profile_view.dart';
import '../../modules/item_detail/views/item_detail_view.dart';
import 'package:calories_tracker/modules/item_detail/views/ingredients_view.dart';
import 'package:calories_tracker/modules/item_detail/views/edit_ingredients_view.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/modules/bottom_nav/views/camera_screen.dart';
import 'package:calories_tracker/features/models/meal_model.dart';

// Import wizard screens (add your real widgets)

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // GoRoute(
      //   path: AppRoutes.initial,
      //   name: 'initial',
      //   redirect: (context, state) => AppRoutes.splash,
      // ),
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Onboarding screens
      GoRoute(
        path: AppRoutes.onboarding1,
        name: 'onboarding1',
        builder: (context, state) => const OnboardingPager(),
      ),
      GoRoute(
        path: AppRoutes.onboarding2,
        name: 'onboarding2',
        builder: (context, state) => const OnboardingScreen2(),
      ),
      GoRoute(
        path: AppRoutes.onboarding3,
        name: 'onboarding3',
        builder: (context, state) => const OnboardingScreen3(),
      ),

      // Auth screens
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      // Profile screen
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileView(),
      ),
      // Item Detail screen
      GoRoute(
        path: '/item-detail',
        name: 'item_detail',
        builder: (context, state) {
          final meal = state.extra as Meal;
          return ItemDetailView(meal: meal);
        },
      ),
      // Ingredients screen
      GoRoute(
        path: '/ingredients',
        name: 'ingredients',
        builder: (context, state) => const IngredientsView(),
      ),
      // Edit Ingredients screen
      GoRoute(
        path: '/edit-ingredients',
        name: 'edit_ingredients',
        builder: (context, state) {
          final ingredient = state.extra as String?;
          return EditIngredientsView(ingredient: ingredient ?? '');
        },
      ),
      // New dashboard route
      GoRoute(
        path: '/bottom-nav',
        name: 'bottom_nav',
        builder: (context, state) => const BottomNavView(),
      ),

      // Camera screen route
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) {
          print('🚗 Camera route accessed');
          print('🚗 state.extra: ${state.extra}');
          final meals = state.extra is Map && (state.extra as Map).containsKey('meals')
              ? (state.extra as Map)['meals'] as List<Meal>?
              : null;
          final updateMeals = state.extra is Map && (state.extra as Map).containsKey('updateMeals')
              ? (state.extra as Map)['updateMeals'] as Function(List<Meal>)?
              : null;
          print('🚗 Extracted meals: ${meals?.length ?? 'null'}');
          print('🚗 Extracted updateMeals: ${updateMeals != null ? 'present' : 'null'}');
          return CameraScreen(meals: meals, updateMeals: updateMeals);
        },
      ),

      // Wizard screens
      GoRoute(
        path: AppRoutes.wizardPager,
        name: 'wizard_pager',
        builder: (context, state) => const WizardPager(),
      ),
      GoRoute(
        path: AppRoutes.wizard1,
        name: 'wizard1',
        builder: (context, state) => const WizardYourAge(),
      ),
      GoRoute(
        path: AppRoutes.wizard2,
        name: 'wizard2',
        builder: (context, state) => const WizardCurrentHeight(),
      ),
      GoRoute(
        path: AppRoutes.wizard3,
        name: 'wizard3',
        builder: (context, state) => const WizardYourWeight(),
      ),
      GoRoute(
        path: AppRoutes.wizard4,
        name: 'wizard4',
        builder: (context, state) => const WizardGender(),
      ),
      GoRoute(
        path: AppRoutes.wizard5,
        name: 'wizard5',
        builder: (context, state) => const WizardGoalType(),
      ),
      GoRoute(
        path: AppRoutes.wizard6,
        name: 'wizard6',
        builder: (context, state) => const WizardDietType(),
      ),
      GoRoute(
        path: AppRoutes.wizard7,
        name: 'wizard7',
        builder: (context, state) => const WizardDreamWeight(),
      ),
      GoRoute(
        path: AppRoutes.wizard8,
        name: 'wizard8',
        builder: (context, state) => const WizardMotivationAchiement(isGain: false,),
      ),
      GoRoute(
        path: AppRoutes.wizard9,
        name: 'wizard9',
        builder: (context, state) => const WizardWorkout(),
      ),
      GoRoute(
        path: AppRoutes.wizard10,
        name: 'wizard10',
        builder: (context, state) => const WizardHowFast(),
      ),
      GoRoute(
        path: AppRoutes.wizard11,
        name: 'wizard11',
        builder: (context, state) => const WizardSummaryDateAndMeasurments(),
      ),
      GoRoute(
        path: AppRoutes.wizard12,
        name: 'wizard12',
        builder: (context, state) => const WizardGreatPotential(),
      ),
      GoRoute(
        path: AppRoutes.wizard13,
        name: 'wizard13',
        builder: (context, state) => const WizardNotification(),
      ),
      GoRoute(
        path: AppRoutes.wizard14,
        name: 'wizard14',
        builder: (context, state) => const WizardRecommendationApp(),
      ),
      GoRoute(
        path: AppRoutes.wizard15,
        name: 'wizard15',
        builder: (context, state) => const WizardHearAboutUs(),
      ),
      GoRoute(
        path: AppRoutes.appleHealth,
        name: 'apple_health',
        builder: (context, state) => const WizardAppleHealth(),
      ),
      GoRoute(
        path: AppRoutes.googleFit,
        name: 'google_fit',
        builder: (context, state) => const WizardGoogleFit(),
      ),
      GoRoute(
        path: AppRoutes.loadingPage,
        name: 'loading_page',
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) {
              final provider = LoadingProvider();
              provider.startLoading(); // start auto-progress
              return provider;
            },
            child: const WizardLoadingPage(),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.toString()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go to Splash'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // Add your auth or intro logic here if needed
      return null;
    },
  );

  static GoRouter get router => _router;
}
