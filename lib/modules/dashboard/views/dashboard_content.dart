import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.7),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff999999).withOpacity(.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: CustomPaint(
                              size: const Size(300, 160),
                              painter: CalorieGaugePainter(
                                fillPercent: .88,
                                segments: 22,
                                filledColor: Colors.black.withOpacity(0.7),
                                unfilledColor: Color(0xff525151).withOpacity(.28),
                                segmentHeight: 60.0,
                                topWidth: 14.0,
                                bottomWidth: 10.0,
                                cornerRadius: 7.0,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10.h(context),
                            child: Column(
                              children: [
                                AppText(
                                  dashboardProvider.caloriesConsumed.toInt().toString(),
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                AppText(
                                  'Daily Calories Left',
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h(context)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CalorieTrackerProgressBar(
                              title: 'Protein',
                              value: dashboardProvider.proteinValue,
                              overallValue: '78/90g',
                              color: AppColors.greenColor,
                            ),
                            CalorieTrackerProgressBar(
                              title: 'Fats',
                              value: dashboardProvider.fatsValue,
                              overallValue: '45/70g',
                              color: AppColors.redColor,
                            ),
                            CalorieTrackerProgressBar(
                              title: 'Carbs',
                              value: dashboardProvider.carbsValue,
                              overallValue: '78/110g',
                              color: AppColors.yellowColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h(context)),
              // MOTIVATIONAL MESSAGE
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.black, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You have been logging meals for 7 days. It's looking good, keep it up!",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h(context)),
              AppText(
                'Recently Uploaded',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              Expanded(
                child: dashboardProvider.recentlyUploadedList.isEmpty
                    ? Center(
                        child: Text(
                          'No recently uploaded items',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final data = dashboardProvider.recentlyUploadedList[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () {
                                context.push('/item-detail', extra: data);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.12),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 110.h(context),
                                      width: 100.w(context),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: AssetImage(data.image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w(context)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 30.h(context),
                                          width: MediaQuery.of(context).size.width * .6,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppText(
                                                data.title,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                              const Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xffececec),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: AppText(
                                                    data.time,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.w(context)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4.h(context)),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xffececec),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            child: AppText(
                                              data.overalAllCalorie,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h(context)),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width * .6,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CalorieTrackerProgressBar(
                                                title: 'Protein',
                                                value: 0.30,
                                                overallValue:
                                                    '${data.proteinCalorie}/90g',
                                                color: AppColors.greenColor,
                                              ),
                                              CalorieTrackerProgressBar(
                                                title: 'Fats',
                                                value: 0.5,
                                                overallValue: '${data.fatsCalorie}/70g',
                                                color: AppColors.redColor,
                                              ),
                                              CalorieTrackerProgressBar(
                                                title: 'Carbs',
                                                value: 0.4,
                                                overallValue: '${data.carbsCalorie}/110g',
                                                color: AppColors.yellowColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 6.h(context)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: dashboardProvider.recentlyUploadedList.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
