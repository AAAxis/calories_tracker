import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/wizard_provider.dart';
import '../../providers/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardLoadingPage extends StatefulWidget {
  const WizardLoadingPage({super.key});

  @override
  State<WizardLoadingPage> createState() => _WizardLoadingPageState();
}

class _WizardLoadingPageState extends State<WizardLoadingPage> {
  void _navigateToResults() {
    // Use PageView navigation instead of pushReplacement for page-based routes
    final provider = Provider.of<WizardProvider>(context, listen: false);
    provider.nextPage();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoadingProvider>().startLoading(
        onComplete: () {
          // Navigate automatically when loading completes
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _navigateToResults();
              }
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loadingProvider = context.watch<LoadingProvider>();
    final progress = loadingProvider.progress;
    final recommendations = loadingProvider.recommendations;

    final checkedCount = (progress ~/ 20).clamp(0, recommendations.length);
    final isCompleted = progress >= 100;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 120.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      // Percentage with animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '${progress.toInt()}%',
                          key: ValueKey(progress.toInt()),
                          style: AppTextStyles.headingLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 64.sp,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'wizard_loading_page.building_message'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Gradient progress bar
                      SizedBox(
                        height: 4.h,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.r),
                          child: Stack(
                            children: [
                              Container(
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * (progress / 100),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue[400]!, Colors.green[300]!],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          loadingProvider.currentStatus,
                          key: ValueKey(loadingProvider.currentStatus),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Daily Recommendations
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'wizard_loading_page.daily_recommendations'.tr(),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              children: [
                                Text(
                                  '- ${'wizard_loading_page.recommendation_1'.tr()}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Spacer(),
                                if (0 < checkedCount)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('check_0'),
                                      color: colorScheme.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              children: [
                                Text(
                                  '- ${'wizard_loading_page.recommendation_2'.tr()}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Spacer(),
                                if (1 < checkedCount)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('check_1'),
                                      color: colorScheme.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              children: [
                                Text(
                                  '- ${'wizard_loading_page.recommendation_3'.tr()}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Spacer(),
                                if (2 < checkedCount)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('check_2'),
                                      color: colorScheme.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              children: [
                                Text(
                                  '- ${'wizard_loading_page.recommendation_4'.tr()}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Spacer(),
                                if (3 < checkedCount)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('check_3'),
                                      color: colorScheme.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              children: [
                                Text(
                                  '- ${'wizard_loading_page.recommendation_5'.tr()}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Spacer(),
                                if (4 < checkedCount)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('check_4'),
                                      color: colorScheme.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                              ],
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
          ],
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      //   child: WizardButton(
      //     label: 'wizard_loading_page.continue'.tr(),
      //     onPressed: () {
      //       AppHaptics.vibrate();
      //       _navigateToResults();
      //     },
      //     padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.wb),
      //   ),
      // ),
    );
  }
}
