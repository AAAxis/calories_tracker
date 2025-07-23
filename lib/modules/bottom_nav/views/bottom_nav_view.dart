import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/gen/assets.gen.dart';
import 'package:calories_tracker/modules/dashboard/views/dashboard_view.dart';
import 'package:calories_tracker/modules/fridge/view/fridge_page.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/modules/bottom_nav/views/camera_options_view.dart';
import 'package:calories_tracker/modules/dashboard/views/water_tracker_view.dart'; // Contains StatsView

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const StatsView(), // Real stats view with water, steps, streaks, weight
    CameraOptionsView(),
    FridgePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Wrapper(child: _pages[_selectedIndex]),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        height: 65.0,

        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SvgPicture.asset(Assets.icons.dashboard),
          Image.asset(Assets.icons.statsPng.path),
          SvgPicture.asset(Assets.icons.scan),
          SvgPicture.asset(Assets.icons.fridge),
        ],
      ),
    );
  }
}

// Placeholder widget for tabs that haven't been implemented yet
class PlaceholderWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderWidget({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              SizedBox(height: 20.h(context)),
              AppText(
                title,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.greenColor,
              ),
              SizedBox(height: 10.h(context)),
              AppText(
                'bottom_nav.coming_soon'.tr(),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.black.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
