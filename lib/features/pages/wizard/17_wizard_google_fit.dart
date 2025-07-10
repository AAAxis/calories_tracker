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

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardGoogleFit extends StatefulWidget {
  const WizardGoogleFit({super.key});

  @override
  State<WizardGoogleFit> createState() => _WizardGoogleFitState();
}

class _WizardGoogleFitState extends State<WizardGoogleFit> {
  final HealthService _healthService = HealthService();
  bool _isConnecting = false;
  bool _isConnected = false;
  String _lastSyncTime = '';
  Map<String, dynamic> _healthData = {};

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
          ? '${'wizard_google_fit.last_synced'.tr()} ${_formatTime(lastSync)}'
          : 'wizard_google_fit.not_connected'.tr();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${'wizard_google_fit.minutes_ago'.tr()}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${'wizard_google_fit.hours_ago'.tr()}';
    } else {
      return '${difference.inDays}${'wizard_google_fit.days_ago'.tr()}';
    }
  }

  Future<void> _connectToGoogleFit() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Check if health data is available
      final isAvailable = await _healthService.isHealthDataAvailable();
      if (!isAvailable) {
        _showError('wizard_google_fit.error_not_available'.tr());
        return;
      }

      // Request permissions
      final authorized = await _healthService.requestPermissions();
      if (!authorized) {
        _showError('wizard_google_fit.error_permissions'.tr());
        return;
      }

      // Sync health data
      final result = await _healthService.syncAllHealthData();
      if (result['success']) {
        setState(() {
          _healthData = result;
        });
        _showSuccess('wizard_google_fit.success_connected'.tr());
        await _checkConnectionStatus();
      } else {
        _showError('${'wizard_google_fit.error_sync_failed'.tr()} ${result['error']}');
      }
    } catch (e) {
      _showError('${'wizard_google_fit.error_connection'.tr()} $e');
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 46.h),
              Image.asset(
                AppImages.googleFit,
                width: 90.w,
                height: 90.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 12.h),
              Text(
                'wizard_google_fit.title'.tr(),
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: kTitleTextStyle.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                'wizard_google_fit.subtitle'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.normal,
                  fontSize: 15.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'wizard_google_fit.description'.tr(),
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
                    _connectToGoogleFit();
                  }
                },
              ),
              if (_isConnected && _healthData.isNotEmpty) ...[
                SizedBox(height: 20.h),
                _buildHealthDataCard(),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: _isConnecting ? 'wizard_google_fit.connecting'.tr() : 'wizard_google_fit.done'.tr(),
          onPressed: _isConnecting 
            ? () {} // Empty function when connecting
            : () {
                 AppHaptics.continue_vibrate();
                _navigateToNotifications(context);
              },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }

  Widget _buildHealthDataCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wizard_google_fit.synced_data'.tr(),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          if (_healthData['steps'] != null)
            _buildDataRow('wizard_google_fit.steps'.tr(), '${_healthData['steps']}'),
          if (_healthData['sleep'] != null)
            _buildDataRow('wizard_google_fit.sleep'.tr(), '${_healthData['sleep'].toStringAsFixed(1)}${'wizard_google_fit.hours'.tr()}'),
          if (_healthData['calories'] != null)
            _buildDataRow('wizard_google_fit.calories_burned'.tr(), '${_healthData['calories'].round()}'),
          if (_healthData['heartRate'] != null)
            _buildDataRow('wizard_google_fit.heart_rate'.tr(), '${_healthData['heartRate'].round()} ${'wizard_google_fit.bpm'.tr()}'),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
