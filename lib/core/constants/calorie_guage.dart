import 'dart:math';

import 'package:flutter/material.dart';

class CalorieGaugePainter extends CustomPainter {
  final double fillPercent;
  final int segments;
  final Color filledColor;
  final Color unfilledColor;
  final double segmentHeight;
  final double topWidth;
  final double bottomWidth;
  final double cornerRadius;

  final double startAngle = pi;
  final double sweepAngle = pi;

  CalorieGaugePainter({
    required this.fillPercent,
    required this.segments,
    required this.filledColor,
    required this.unfilledColor,
    required this.segmentHeight,
    required this.topWidth,
    required this.bottomWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final segmentAngle = sweepAngle / segments;
    final radius = size.width / 2 - segmentHeight / 2;
    final center = Offset(size.width / 2, size.height);

    final totalFillSeg = fillPercent * segments;
    final fullSegments = totalFillSeg.floor();
    final partialFrac = totalFillSeg - fullSegments;

    final spacingFactor = 0.0;

    for (int i = 0; i < segments; i++) {
      final angle = startAngle + (i + 0.5) * segmentAngle;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      Color color;
      if (i < fullSegments) {
        color = filledColor;
      } else if (i == fullSegments && partialFrac > 0) {
        color = Color.lerp(filledColor, unfilledColor, 1 - partialFrac)!;
      } else {
        color = unfilledColor;
      }

      final adjustedTopWidth = topWidth * (1.2 - spacingFactor);
      final adjustedBottomWidth = bottomWidth * (1.1 - spacingFactor);

      final path = Path();

      path.moveTo(-adjustedBottomWidth / 2 + cornerRadius, segmentHeight / 2);

      path.quadraticBezierTo(
        -adjustedBottomWidth / 2,
        segmentHeight / 2,
        -adjustedBottomWidth / 2,
        segmentHeight / 2 - cornerRadius,
      );

      path.lineTo(-adjustedTopWidth / 2, -segmentHeight / 2 + cornerRadius);

      path.quadraticBezierTo(
        -adjustedTopWidth / 2,
        -segmentHeight / 2,
        -adjustedTopWidth / 2 + cornerRadius,
        -segmentHeight / 2,
      );

      path.lineTo(adjustedTopWidth / 2 - cornerRadius, -segmentHeight / 2);

      path.quadraticBezierTo(
        adjustedTopWidth / 2,
        -segmentHeight / 2,
        adjustedTopWidth / 2,
        -segmentHeight / 2 + cornerRadius,
      );

      path.lineTo(adjustedBottomWidth / 2, segmentHeight / 2 - cornerRadius);

      path.quadraticBezierTo(
        adjustedBottomWidth / 2,
        segmentHeight / 2,
        adjustedBottomWidth / 2 - cornerRadius,
        segmentHeight / 2,
      );

      path.close();

      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CalorieGaugePainter oldDelegate) =>
      oldDelegate.fillPercent != fillPercent ||
      oldDelegate.segments != segments ||
      oldDelegate.segmentHeight != segmentHeight ||
      oldDelegate.topWidth != topWidth ||
      oldDelegate.bottomWidth != bottomWidth ||
      oldDelegate.cornerRadius != cornerRadius;
}
