import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LoadingProvider with ChangeNotifier {
  double _progress = 0.0;
  double get progress => _progress;

  List<String> _recommendations = [];
  List<String> get recommendations => _recommendations;

  String _currentStatus = '';
  String get currentStatus => _currentStatus;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Timer? _timer;

  void startLoading({VoidCallback? onComplete}) {
    _progress = 0;
    _isInitialized = true;
    _currentStatus = 'wizard_loading_page.status_initializing'.tr();
    _recommendations = [
      'wizard_loading_page.recommendation_1'.tr(),
      'wizard_loading_page.recommendation_2'.tr(),
      'wizard_loading_page.recommendation_3'.tr(),
      'wizard_loading_page.recommendation_4'.tr(),
      'wizard_loading_page.recommendation_5'.tr(),
    ];
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_progress >= 100) {
        timer.cancel();
        _currentStatus = 'wizard_loading_page.status_ready'.tr();
        notifyListeners();
        onComplete?.call();
      } else {
        _progress += 1;
        _updateStatus();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void _updateStatus() {
    if (_progress < 20) {
      _currentStatus = 'wizard_loading_page.status_analyzing'.tr();
    } else if (_progress < 40) {
      _currentStatus = 'wizard_loading_page.status_calculating'.tr();
    } else if (_progress < 60) {
      _currentStatus = 'wizard_loading_page.status_optimizing'.tr();
    } else if (_progress < 80) {
      _currentStatus = 'wizard_loading_page.status_finalizing'.tr();
    } else if (_progress < 100) {
      _currentStatus = 'wizard_loading_page.status_almost_ready'.tr();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
