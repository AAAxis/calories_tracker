import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepProgressCircle extends StatelessWidget {
  final int steps;
  final int calories;
  final double distance;
  final double percent; // 0.0 to 1.0

  const StepProgressCircle({
    super.key,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width - 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.65),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xff999999).withOpacity(.25),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _DonutProgressPainter(percent: percent),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              steps.toString(),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Steps',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$calories Kcal',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 32),

                Text(
                  '${distance}Km',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutProgressPainter extends CustomPainter {
  final double percent;
  _DonutProgressPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 5.0;

    // Draw filled center (smaller than the donut ring)
    final innerRadius = radius - strokeWidth / 2 + 1; // +1 for crisp edge
    final fillPaint =
        Paint()
          ..color = Color(0xff2E3034)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, fillPaint);

    // Draw background circle (donut track)
    final bgPaint =
        Paint()
          ..color = const Color(0xFF434548)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final arcPaint =
        Paint()
          ..color = const Color(0xFF1EC6B6)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;
    double sweepAngle = 2 * 3.141592653589793 * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
