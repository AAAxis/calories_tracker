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
import '../../../core/utils/haptics.dart';

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
    try {
      final status = await Permission.notification.status;
      print('🔔 Notification permission status: $status');
      print('🔔 Is granted: ${status.isGranted}');
      print('🔔 Is denied: ${status.isDenied}');
      print('🔔 Is permanently denied: ${status.isPermanentlyDenied}');
      print('🔔 Is restricted: ${status.isRestricted}');
      
      setState(() {
        _notificationStatus = status;
      });
      
      // Don't show automatic messages - let user decide to request
    } catch (e) {
      print('❌ Error checking notification permission: $e');
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      print('🔔 Requesting notification permission...');
      
      // Use flutter_local_notifications to trigger the native iOS dialog
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      
      // For iOS, this should trigger the native permission dialog
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      bool granted = false;
      
      if (iosPlugin != null) {
        // This should show the native iOS permission dialog
        print('🍎 Requesting iOS notification permissions...');
        final result = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = result ?? false;
        print('🍎 iOS permission result: $granted');
      } else {
        // For Android, use permission_handler
        print('🤖 Requesting Android notification permissions...');
        final status = await Permission.notification.request();
        granted = status.isGranted;
        print('🤖 Android permission result: $status');
      }
      
      // Update our state
      final finalStatus = await Permission.notification.status;
      setState(() {
        _notificationStatus = finalStatus;
        _isRequesting = false;
      });

      print('🔔 Final permission status: $finalStatus');
      print('🔔 Granted: $granted');

      // Show result to user
      if (granted) {
        print('✅ Notification permission granted successfully');
        _showSuccess('Notifications enabled successfully!');
      } else {
        print('⚠️ Notification permission denied by user');
        _showInfo('Notifications not enabled - you can enable them later in Settings');
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      setState(() {
        _isRequesting = false;
      });
      _showError('Failed to request notification permission: $e');
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
                        // Use PageView navigation instead of direct navigation
                        Provider.of<WizardProvider>(context, listen: false).nextPage();
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
                        await _requestNotificationPermission();
                        
                        // Save preference based on final status
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('notifications_enabled', _notificationStatus?.isGranted ?? false);
                        
                        // Always continue to next screen regardless of permission result
                        if (mounted) {
                          Provider.of<WizardProvider>(context, listen: false).nextPage();
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
            AppHaptics.continue_vibrate();
            // Use PageView navigation instead of direct navigation
            Provider.of<WizardProvider>(context, listen: false).nextPage();
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}
