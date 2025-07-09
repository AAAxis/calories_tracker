import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WizardIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final BoxFit fit;

  const WizardIcon({
    super.key,
    required this.assetPath,
    this.size = 32,
    this.fit = BoxFit.contain,
  });

  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
      );
    } else {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
      );
    }
  }
} 