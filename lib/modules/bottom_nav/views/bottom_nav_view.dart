import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/gen/assets.gen.dart';
import 'package:calories_tracker/modules/dashboard/views/dashboard_view.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const PlaceholderWidget(title: 'Stats', icon: Icons.start_sharp),
    const PlaceholderWidget(title: 'Scan', icon: Icons.camera_alt),
    const PlaceholderWidget(title: 'Fridge', icon: Icons.fork_right_rounded),
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
    return SafeArea(
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
              'Coming Soon!',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
