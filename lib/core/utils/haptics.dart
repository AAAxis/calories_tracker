import 'dart:io' show Platform;
import 'package:flutter/services.dart';
// import 'package:vibration/vibration.dart';

class AppHaptics {
  // static Future<void> vibrateCustom({int durationMs = 1000}) async {
  //   if (Platform.isAndroid) {
  //     if (await Vibration.hasVibrator() ?? false) {
  //       Vibration.vibrate(duration: durationMs);
  //     } else {
  //       HapticFeedback.heavyImpact();
  //     }
  //   } else if (Platform.isIOS) {
  //     HapticFeedback.heavyImpact(); // Only short, system-defined vibration
  //   }
  // }

  static void vibrate() {
    HapticFeedback.heavyImpact();
    // vibrateCustom();
  }

  static void back_vibrate() {
    HapticFeedback.mediumImpact();
    // vibrateCustom();
  }
  static void continue_vibrate() {
    HapticFeedback.mediumImpact();
    // vibrateCustom();
  }
} 