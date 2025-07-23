import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:calories_tracker/features/providers/loading_provider.dart';
import 'package:calories_tracker/features/providers/wizard_provider.dart';
import 'package:calories_tracker/core/initialization/initialization.dart';
import 'package:calories_tracker/core/routing/router.dart';
import 'package:calories_tracker/core/theme/light_theme.dart';
import 'package:calories_tracker/core/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:calories_tracker/features/pages/wizard/wizard_pager.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    // Initialize app services
    await initializeApp(
      onSuccess: () {
        print('✅ App initialized successfully');
      },
      onError: (error, stackTrace) {
        print('❌ App initialization failed: $error');
        print(stackTrace.toString());
      },
    );

    // Run app with localization support
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'), // English
          Locale('he'), // Hebrew
          Locale('ru'), // Russian
        ],
        path: 'assets/translations',
        // fallbackLocale: const Locale('he'),
        // startLocale: const Locale('he'),
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ Fatal error during app initialization: $e');
    print(stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(Constants.screenW, Constants.screenH),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => DashboardProvider(),
            lazy: false,
          ),
          ChangeNotifierProvider(
            create:
                (_) => WizardProvider(
                  totalScreens: WizardPager.getTotalScreenCount(),
                ),
          ),
          ChangeNotifierProvider(create: (_) => LoadingProvider()),
        ],
        child: MaterialApp.router(
          title: 'Calzo',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          theme: lightTheme,
          // EasyLocalization configuration
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, child) {
            // Initialize DashboardProvider after the widget tree is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final dashboardProvider = Provider.of<DashboardProvider>(
                context,
                listen: false,
              );
              dashboardProvider.initialize();
            });
            return child!;
          },
        ),
      ),
    );
  }
}
