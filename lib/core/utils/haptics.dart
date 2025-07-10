import 'package:flutter/services.dart';

class AppHaptics {
  static void vibrate() {
    HapticFeedback.heavyImpact();
  }
  static void back_vibrate() {
    HapticFeedback.mediumImpact();
  }
  static void continue_vibrate() {
    HapticFeedback.mediumImpact();
  }
} 