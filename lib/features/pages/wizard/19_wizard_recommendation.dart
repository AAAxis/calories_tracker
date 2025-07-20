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
import '../../providers/wizard_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Debug wizard provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WizardProvider>(context, listen: false);
      print('🎬 Recommendation: InitState - Current index: ${provider.currentIndex}, Total: ${provider.totalScreens}');
      
      // Set the correct index for the recommendation screen (index 17)
      if (provider.currentIndex != 17) {
        print('🎬 Recommendation: Setting current index to 17');
        provider.setCurrentIndex(17, notify: false);
      }
    });
  }

  void _navigateToAuth() {
    print('🎬 Recommendation: _navigateToAuth called');
    
    try {
      // Use wizard provider navigation to continue to paywall
      final provider = Provider.of<WizardProvider>(context, listen: false);
      print('🎬 Recommendation: Provider found - Current index ${provider.currentIndex}, total screens: ${provider.totalScreens}');
      
      // Check if we can navigate to next page
      if (provider.currentIndex < provider.totalScreens - 1) {
        print('🎬 Recommendation: Calling nextPage()...');
        provider.nextPage();
        print('🎬 Recommendation: nextPage() completed - New index: ${provider.currentIndex}');
      } else {
        print('❌ Recommendation: Already at last screen, cannot navigate further');
      }
    } catch (e) {
      print('❌ Recommendation: Error with provider navigation: $e');
      print('📊 Recommendation: Stack trace: ${StackTrace.current}');
    }
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h), // Reduced from default
                    // App Title
                    Text(
                      'wizard_hear_about_us.app_title'.tr(),
                      style: TextStyle(
                        fontFamily: 'RusticRoadway',
                        color: colorScheme.primary,
                        fontSize: 32.sp, // Slightly smaller
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h), // Reduced spacing

                    // Title
                    Text(
                      'wizard_recommendation.title'.tr(),
                      style: AppTextStyles.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 22.sp, // Slightly smaller
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16.h), // Reduced spacing

                    // Rating
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h), // Reduced padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w), // Reduced padding
                            child: Icon(
                              index < 4
                                  ? Icons.star
                                  : Icons.star_half, // Adjust for 4.7
                              color: Colors.amber,
                              size: 28.sp, // Slightly smaller
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 24.h), // Reduced spacing

                    // Rating Summary
                    _RatingSummary(),

                    SizedBox(height: 20.h), // Reduced spacing

                    // Reviews List - make more compact
                    ...reviews.map((review) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h), // Reduced spacing between reviews
                      child: _ReviewCard(
                        name: review['name'],
                        rating: review['rating'],
                        review: review['review'],
                      ),
                    )),

                    SizedBox(height: 20.h), // Add some bottom padding for scroll
                  ],
                ),
              ),
            ),
            // Fixed bottom button
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h), // Reduced top padding
              child: WizardButton(
                label: 'wizard_recommendation.continue'.tr(),
                onPressed: () {
                  print('🎬 Recommendation: Continue button pressed');
                  AppHaptics.continue_vibrate();
                  // Don't mark wizard as completed yet - let it continue to paywall
                  _navigateToAuth();
                },
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w), // Slightly smaller button
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), // Reduced padding
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'wizard_recommendation.rating'.tr(),
            style: AppTextStyles.headingLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: 28.sp, // Slightly smaller
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.star, color: Colors.amber, size: 24.sp), // Smaller star
          SizedBox(width: 12.w),
          Text(
            'wizard_recommendation.total_reviews'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13.sp, // Smaller text
            ),
          ),
        ],
      ),
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
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h), // Reduced margin
      padding: EdgeInsets.all(16.w), // Reduced padding
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.08),
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
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 14.sp, // Slightly smaller
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(rating, (index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 14.sp, // Smaller stars
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 6.h), // Reduced spacing
          Text(
            review,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 13.sp, // Slightly smaller
            ),
            maxLines: 3, // Limit lines to save space
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
