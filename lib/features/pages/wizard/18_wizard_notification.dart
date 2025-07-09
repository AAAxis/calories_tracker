import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../providers/wizard_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '19_wizard_recommendation.dart';
import 'package:easy_localization/easy_localization.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardNotification extends StatefulWidget {
  const WizardNotification({super.key});

  @override
  State<WizardNotification> createState() => _WizardNotificationState();
}

class _WizardNotificationState extends State<WizardNotification> {
  bool _isRequesting = false;
  PermissionStatus? _notificationStatus;

  void _navigateToComments() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WizardRecommendationApp()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationStatus = status;
    });
  }

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final status = await Permission.notification.request();
      setState(() {
        _notificationStatus = status;
        _isRequesting = false;
      });

      if (status.isGranted) {
        _showSuccess('wizard_notification.success_enabled'.tr());
      } else if (status.isDenied) {
        _showInfo('wizard_notification.info_denied'.tr());
      } else if (status.isPermanentlyDenied) {
        _showError('wizard_notification.error_permanently_denied'.tr());
      }
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });
      _showError('${'wizard_notification.error_request'.tr()} $e');
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
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
              SizedBox(height: 20.h),
              
              // Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset(
                    AppImages.notif,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              
              Text(
                'wizard_notification.title'.tr(),
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: kTitleTextStyle.fontSize,
                ),
                textAlign: TextAlign.center,
                ),
              SizedBox(height: 12.h),
              
              Text(
                'wizard_notification.description'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              
              // Permission Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isRequesting ? null : () async {
                        // Skip notifications but save preference
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('notifications_enabled', false);
                        if (!mounted) return;
                        _navigateToComments();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Text(
                        'wizard_notification.dont_allow'.tr(),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : () async {
                        setState(() => _isRequesting = true);
                        try {
                          // Request notification permissions
                          final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
                          bool granted = true;

                          // Android permissions
                          final androidPlugin = flutterLocalNotificationsPlugin
                              .resolvePlatformSpecificImplementation<
                                AndroidFlutterLocalNotificationsPlugin
                              >();
                          if (androidPlugin != null) {
                            final result = await androidPlugin.requestNotificationsPermission();
                            if (result != null && result == false) granted = false;
                          }

                          // iOS permissions
                          final iosPlugin = flutterLocalNotificationsPlugin
                              .resolvePlatformSpecificImplementation<
                                IOSFlutterLocalNotificationsPlugin
                              >();
                          if (iosPlugin != null) {
                            final result = await iosPlugin.requestPermissions(
                              alert: true,
                              badge: true,
                              sound: true,
                            );
                            if (result != null && result == false) granted = false;
                          }

                          // Save preference
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notifications_enabled', granted);

                          if (!mounted) return;
                          _navigateToComments();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'wizard_notification.error_failed'.tr(),
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isRequesting = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'wizard_notification.allow'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              Text(
                'wizard_notification.settings_note'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_notification.continue'.tr(),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _navigateToComments();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
