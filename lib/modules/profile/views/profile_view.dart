import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/widgets/user_avatar.dart';
import 'package:calories_tracker/modules/profile/controllers/image_picker_controller.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calories_tracker/core/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.signOut();
      if (!mounted) return;
      context.go('/onboarding1');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'profile.error_during_logout'.tr()}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImagePickerController(),
      child: Scaffold(
        body: Wrapper(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              'assets/icons/ingredients-back.png',
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'profile.my_profile'.tr(),
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20.h(context)),
                    Consumer<ImagePickerController>(
                      builder: (context, controller, child) {
                        return Stack(
                          children: [
                            controller.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(
                                      controller.image!,
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                  )
                                : UserAvatar(
                                    size: 100.0,
                                  ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  controller.getImage(ImageSource.gallery);
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset('assets/icons/edit.svg'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Text(
                      AuthService.currentUser?.displayName ?? 
                      AuthService.currentUser?.email?.split('@')[0] ?? 
                      'User',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AuthService.currentUser?.email ?? 'user@example.com',
                      style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {},
                      icon: 'assets/icons/account.png',
                      title: 'profile.personal_information'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {},
                      icon: 'assets/icons/meals.png',
                      title: 'profile.my_meals'.tr(),
                    ),

                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {},
                      icon: 'assets/icons/report.png',
                      title: 'profile.nutrition_report'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {},
                      icon: 'assets/icons/Favorite.png',
                      title: 'profile.favorites_food'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: _isLoggingOut ? null : () { _handleLogout(); },
                      icon: 'assets/icons/Logout.png',
                      title: 'profile.log_out'.tr(),
                    ),
                  ],
                ),
                if (_isLoggingOut)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RowData extends StatelessWidget {
  const RowData({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });
  final String title;
  final String icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 40.w(context), right: 20.w(context)),
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Image.asset(icon),
              SizedBox(width: 10.w(context)),
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
              ),
              const Spacer(),
              Image.asset('assets/icons/arrow-right.png'),
            ],
          ),
        ),
      ),
    );
  }
}
