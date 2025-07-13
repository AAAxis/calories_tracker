import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/gen/assets.gen.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_calendart.dart';
import 'package:calories_tracker/modules/dashboard/views/dashboard_content.dart';
import 'package:calories_tracker/modules/dashboard/views/water_tracker_view.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:calories_tracker/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DashboardContent(),
    const WaterTrackerView(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Wrapper(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: dashboardProvider.currentPage == 0
                  ? ScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(Assets.images.profile.path),
                          ),
                        ),
                        const Spacer(),
                        Image.asset(Assets.icons.premium.path),
                        SizedBox(width: 4.w(context)),
                        AppText(
                          'dashboard.get_premium'.tr(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            context.push('/profile');
                          },
                          child: Icon(Icons.menu),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                  CalorieCalendar(maxCalories: 2000),
                  SizedBox(height: 20.h(context)),
                  SizedBox(
                    height: dashboardProvider.currentPage == 0
                        ? MediaQuery.of(context).size.height * 1.2
                        : MediaQuery.sizeOf(context).height,
                    width: MediaQuery.of(context).size.width,
                    child: PageView(
                      pageSnapping: true,
                      controller: _pageController,
                      onPageChanged: (index) {
                        dashboardProvider.setCurrentPage(index);
                      },
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
