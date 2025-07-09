import 'dart:math';
import 'package:flutter/material.dart';

extension ContextResponsiveExtension on num {
  static const double _baseWidth = 375;
  static const double _baseHeight = 810;

  double w(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return this * (screenWidth / _baseWidth);
  }

  double h(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeVertical =
        MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    final usableHeight = screenHeight - safeVertical;
    return this * (usableHeight / _baseHeight);
  }

  double sp(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minDim = min(size.width, size.height);
    final baseMinDim = min(_baseWidth, _baseHeight);
    return this * (minDim / baseMinDim);
  }
}
