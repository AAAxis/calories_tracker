import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/custom_widgets/health_status_card.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/services/health_service.dart';
import '18_wizard_notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/haptics.dart';
import 'package:provider/provider.dart';
import '../../providers/wizard_provider.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardAppleHealth extends StatefulWidget {
  const WizardAppleHealth({super.key});

  @override
  State<WizardAppleHealth> createState() => _WizardAppleHealthState();
}

class _WizardAppleHealthState extends State<WizardAppleHealth> {
  final HealthService _healthService = HealthService();
  bool _isConnecting = false;
  bool _isConnected = false;
  String _lastSyncTime = '';

  void _navigateToNotifications(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WizardNotification()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    final connected = await _healthService.isHealthConnected();
    final lastSync = await _healthService.getLastSyncTime();
    
    setState(() {
      _isConnected = connected;
      _lastSyncTime = lastSync != null 
          ? '${'wizard_apple_health.last_synced'.tr()} ${_formatTime(lastSync)}'
          : 'wizard_apple_health.not_connected'.tr();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${'wizard_apple_health.minutes_ago'.tr()}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${'wizard_apple_health.hours_ago'.tr()}';
    } else {
      return '${difference.inDays}${'wizard_apple_health.days_ago'.tr()}';
    }
  }

  Future<void> _connectToAppleHealth() async {
    setState(() {
      _isConnecting = true;
      _isConnected = true; // Update switch immediately to show connecting state
    });

    try {
      // Check if health data is available
      final isAvailable = await _healthService.isHealthDataAvailable();
      if (!isAvailable) {
        _showError('wizard_apple_health.error_not_available'.tr());
        setState(() {
          _isConnected = false;
        });
        return;
      }

      // Request permissions
      final authorized = await _healthService.requestPermissions();
      if (!authorized) {
        _showError('wizard_apple_health.error_permissions'.tr());
        setState(() {
          _isConnected = false;
        });
        return;
      }

      // Sync health data
      final result = await _healthService.syncAllHealthData();
      if (result['success']) {
        _showSuccess('wizard_apple_health.success_connected'.tr());
        await _checkConnectionStatus();
      } else {
        _showError('${'wizard_apple_health.error_sync_failed'.tr()} ${result['error']}');
        setState(() {
          _isConnected = false;
        });
      }
    } catch (e) {
      _showError('${'wizard_apple_health.error_connection'.tr()} $e');
      setState(() {
        _isConnected = false;
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom - 
                        100.h, // Account for button area
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 46.h),
                  Image.asset(
                    AppImages.appleHealth,
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'wizard_apple_health.title'.tr(),
                    style: AppTextStyles.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: kTitleTextStyle.fontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'wizard_apple_health.subtitle'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.normal,
                      fontSize: 15.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'wizard_apple_health.description'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                  HealthStatusCard(
                    connected: _isConnected,
                    lastSynced: _lastSyncTime,
                    onChanged: (val) {
                      if (val) {
                        _connectToAppleHealth();
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_apple_health.done'.tr(),
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
