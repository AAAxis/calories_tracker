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
import 'package:calories_tracker/features/providers/wizard_provider.dart';
import 'package:calories_tracker/core/store/shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'user_info.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoggingOut = false;

  Future<void> _showLanguageDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'profile.select_language'.tr(),
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text('🇺🇸'),
                title: Text(
                  'English',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  context.setLocale(Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Text('🇮🇱'),
                title: Text(
                  'עברית',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  context.setLocale(Locale('he'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Text('🇷🇺'),
                title: Text(
                  'Русский',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  context.setLocale(Locale('ru'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'profile.cancel'.tr(),
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSubscriptionSettings() async {
    try {
      if (Platform.isIOS) {
        // Open iOS subscription settings
        await launchUrl(Uri.parse('https://apps.apple.com/account/subscriptions'));
      } else {
        // Open Google Play subscription settings
        await launchUrl(Uri.parse('https://play.google.com/store/account/subscriptions'));
      }
    } catch (e) {
      print('Error opening subscription settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.error_opening_subscriptions'.tr())),
        );
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    try {
      await launchUrl(
        Uri.parse('https://www.calzo-app.com/privacy'),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error opening privacy policy: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.error_opening_privacy'.tr())),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      // Reset wizard provider state before logout
      final wizardProvider = Provider.of<WizardProvider>(context, listen: false);
      print('🎬 Logout: Resetting wizard provider state');
      wizardProvider.reset();
      
      // Reset wizard completion flag so user goes through wizard again
      await SharedPref.resetWizardCompletion();
      print('🎬 Logout: Reset wizard completion flag');
      
      // Sign out and clear user data
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
                            // Show upload progress overlay
                            if (controller.isUploading)
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: controller.isUploading ? null : () async {
                                  try {
                                    await controller.getImage(ImageSource.gallery);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('profile.image_uploaded_successfully'.tr()),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('profile.image_upload_failed'.tr()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: controller.isUploading ? Colors.grey : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      'assets/icons/edit.svg',
                                      colorFilter: ColorFilter.mode(
                                        controller.isUploading ? Colors.grey[400]! : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserInfoView()),
                        );
                      },
                      icon: Icons.person,
                      title: 'profile.personal_information'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {
                        _openSubscriptionSettings();
                      },
                      icon: Icons.subscriptions,
                      title: 'profile.subscriptions'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {
                        _showLanguageDialog();
                      },
                      icon: Icons.language,
                      title: 'profile.language'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: () {
                        _openPrivacyPolicy();
                      },
                      icon: Icons.privacy_tip,
                      title: 'profile.privacy_policy'.tr(),
                    ),
                    SizedBox(height: 20.h(context)),
                    RowData(
                      onTap: _isLoggingOut ? null : () { _handleLogout(); },
                      icon: Icons.logout,
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
  final IconData icon;
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
              Icon(
                icon, 
                size: 24,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 10.w(context)),
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
