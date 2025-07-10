import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/constants.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/store/shared_pref.dart';
import '../auth/login_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/haptics.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardRecommendationApp extends StatefulWidget {
  const WizardRecommendationApp({super.key});

  @override
  State<WizardRecommendationApp> createState() => _WizardRecommendationAppState();
}

class _WizardRecommendationAppState extends State<WizardRecommendationApp> {
  int selectedRating = 0;

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'wizard_recommendation.review_1_name'.tr(),
      'rating': 5,
      'review': 'wizard_recommendation.review_1_text'.tr(),
    },
    {
      'name': 'wizard_recommendation.review_2_name'.tr(),
      'rating': 5,
      'review': 'wizard_recommendation.review_2_text'.tr(),
    },
    {
      'name': 'wizard_recommendation.review_1_name'.tr(),
      'rating': 5,
      'review': 'wizard_recommendation.review_1_text'.tr(),
    },
    {
      'name': 'wizard_recommendation.review_2_name'.tr(),
      'rating': 5,
      'review': 'wizard_recommendation.review_2_text'.tr(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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

                  SizedBox(height: Constants.beforeIcon),

                  // Give us rating title
                  Text(
                    'wizard_recommendation.title'.tr(),
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: kTitleTextStyle.fontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 30.h),

                  // Interactive Star Rating
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < 4
                                ? Icons.star
                                : Icons.star_half, // Adjust for 4.7
                            color: Colors.amber,
                            size: 32.sp,
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Rating Summary
                  _RatingSummary(),

                  SizedBox(height: 30.h),

                  // Reviews List
                  ...reviews.map((review) => _ReviewCard(
                        name: review['name'],
                        rating: review['rating'],
                        review: review['review'],
                      )),

                  SizedBox(height: 120.h), // Space for fixed button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_recommendation.create_account'.tr(),
          onPressed: () {
            AppHaptics.vibrate();
            // Mark wizard as completed
            SharedPref.setWizardCompleted(true);
            _navigateToAuth();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> ratingBreakdown = [
      {'stars': 5, 'percentage': 0.85},
      {'stars': 4, 'percentage': 0.10},
      {'stars': 3, 'percentage': 0.03},
      {'stars': 2, 'percentage': 0.01},
      {'stars': 1, 'percentage': 0.01},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Large rating number
        Column(
          children: [
            Text(
              'wizard_recommendation.rating'.tr(),
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 72.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'wizard_recommendation.total_reviews'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),

        SizedBox(width: 32.w),

        // Rating breakdown bars
        Expanded(
          child: Column(
            children: ratingBreakdown.map((item) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Text(
                      "${item['stars']}",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item['percentage'],
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String review;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(width: 8.w),
              ...List.generate(
                rating,
                (index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '"$review"',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
