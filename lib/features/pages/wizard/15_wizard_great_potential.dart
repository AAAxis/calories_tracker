import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/custom_widgets/wizard_button.dart';
import '../../../core/custom_widgets/wizard_icon.dart';
import '../../../core/theme/app_text_styles.dart';
import 'dart:io';
import '16_wizard_apple_health.dart';
import '17_wizard_google_fit.dart';
import 'package:easy_localization/easy_localization.dart';

// Constants
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

class WizardGreatPotential extends StatefulWidget {
  const WizardGreatPotential({super.key});

  @override
  WizardGreatPotentialState createState() => WizardGreatPotentialState();
}

class WizardGreatPotentialState extends State<WizardGreatPotential>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnimation;

  bool isGain = true; // Set to true for weight gain, false for weight loss
  bool isRtl = false;
  void _navigateToHealthScreen(BuildContext context) {
    isRtl = Localizations.localeOf(context).languageCode == 'he';

    if (Platform.isIOS) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WizardAppleHealth()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WizardGoogleFit()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Line animation goes from 0 to 1 (representing the graph growth)
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRecommendationItem(String text, Color iconColor, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    isRtl = Localizations.localeOf(context).languageCode == 'he';

    // Sample data for the graph
    final List<double> sampleWeights = [86, 78, 76, 74, 72];
    final List<String> sampleDays = ['Today', '3d', '7d', '14d', '30d'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
              Text(
                'wizard_great_potential.title'.tr(),
                style: TextStyle(
                  fontSize: kTitleTextStyle.fontSize!.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              Text(
                'wizard_great_potential.how_to_reach_goals'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),

              // Recommendations Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r)),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 20.h, horizontal: 16.w),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'wizard_summary.how_to_reach_goals'.tr(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            // fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_2,
                          color: Colors.green[600]!,
                          text: 'wizard_summary.goal_tip_1'.tr(),
                        ),
                        SizedBox(height: 8.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_1,
                          color: Colors.indigo,
                          text: 'wizard_summary.goal_tip_2'.tr(),
                        ),
                        SizedBox(height: 8.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_3,
                          color: Colors.redAccent,
                          text: 'wizard_summary.goal_tip_3'.tr(),
                        ),
                        SizedBox(height: 8.h),
                        _GoalRow(
                          icon: AppIcons.recommendaion_4,
                          color: Colors.teal,
                          text: 'wizard_summary.goal_tip_4'.tr(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // AnimatedBuilder(
              //   animation: _lineAnimation,
              //   builder: (context, child) {
              //     return CustomPaint(
              //       size: const Size(320, 100),
              //       painter: _WeightGraphPainter(
              //         progress: _lineAnimation.value,
              //         isGain: isGain,
              //         isRtl: isRtl,
              //         weights: sampleWeights,
              //         days: sampleDays,
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: WizardButton(
          label: 'wizard_great_potential.continue'.tr(),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _navigateToHealthScreen(context);
          },
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
    );
  }
}

// Custom painter for the weight transition graph
class _WeightGraphPainter extends CustomPainter {
  final double progress;
  final bool isGain;
  final bool isRtl;
  final List<double> weights;
  final List<String> days;

  _WeightGraphPainter({
    required this.progress,
    required this.isGain,
    required this.isRtl,
    required this.weights,
    required this.days,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate min/max for scaling
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = (maxWeight - minWeight).abs();
    final n = weights.length;

    // Build points based on data
    List<Offset> points = List.generate(n, (i) {
      final x = size.width * (i / (n - 1));
      final y = size.height - ((weights[i] - minWeight) / (weightRange == 0 ? 1 : weightRange)) * (size.height * 0.8) - size.height * 0.1;
      return Offset(x, y);
    });

    // If it's weight gain, flip the Y coordinates
    if (isGain) {
      points = points.map((point) => Offset(point.dx, size.height - point.dy)).toList();
    }
    // If RTL, flip the X coordinates
    if (isRtl) {
      points = points.map((point) => Offset(size.width - point.dx, point.dy)).toList();
    }

    final theme = ThemeData.light();

    // 1. Horizontal grid lines (dotted)
    final dottedPaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withAlpha(60)
      ..strokeWidth = 1.0;
    for (int i = 0; i <= 4; i++) {
      final dy = size.height * i / 4;
      _drawDottedLine(canvas, Offset(0.0, dy), Offset(size.width, dy), dottedPaint);
    }

    // 2. Vertical lines at data points (dotted)
    for (var point in points) {
      _drawDottedLine(canvas, Offset(point.dx, 0.0), Offset(point.dx, size.height), dottedPaint);
    }

    // 3. Draw x-axis (solid)
    final xAxisPaint = Paint()
      ..color = theme.colorScheme.outline
      ..strokeWidth = 1.4;
    final xAxisY = size.height;
    canvas.drawLine(Offset(0.0, xAxisY), Offset(size.width, xAxisY), xAxisPaint);

    // 4. Gradient area under curve
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.orange.withAlpha(60),
          Colors.orange.withAlpha(20),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    final gradientPath = Path()..moveTo(points[0].dx, size.height);
    for (var i = 0; i < points.length; i++) {
      final animatedX = points[i].dx * progress;
      final animatedY = points[i].dy;
      gradientPath.lineTo(animatedX, animatedY);
    }
    gradientPath.lineTo(points.last.dx * progress, size.height);
    gradientPath.close();
    canvas.drawPath(gradientPath, gradientPaint);

    // 5. Line curve
    final linePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    final linePath = Path();
    linePath.moveTo(points[0].dx * progress, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final animatedX = points[i].dx * progress;
      final animatedY = points[i].dy;
      linePath.lineTo(animatedX, animatedY);
    }
    canvas.drawPath(linePath, linePaint);

    // 6. Data points & trophy
    final fillPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < points.length; i++) {
      final animatedX = points[i].dx * progress;
      final animatedY = points[i].dy;
      canvas.drawCircle(Offset(animatedX, animatedY), 6.0, fillPaint);
      canvas.drawCircle(Offset(animatedX, animatedY), 6.0, borderPaint);
      if (i == points.length - 1 && progress > 0.8) {
        final trophyPaint = Paint()..color = Colors.orange;
        canvas.drawCircle(Offset(animatedX, animatedY - 20.0), 12.0, trophyPaint);
      }
    }

    // 7. Add day labels on X-axis
    _drawDayLabels(canvas, size, progress, isRtl, points);
    // 8. Add weight labels on Y-axis
    _drawWeightLabels(canvas, size, isGain, isRtl, minWeight, maxWeight);
    // 9. Add axis titles
    _drawAxisTitles(canvas, size, isRtl);
  }

  void _drawDayLabels(Canvas canvas, Size size, double progress, bool isRtl, List<Offset> points) {
    final textPainter = TextPainter();
    for (int i = 0; i < days.length; i++) {
      final x = points[i].dx * progress;
      if (x <= size.width) {
        textPainter.text = TextSpan(
          text: days[i],
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        final textX = x - textPainter.width / 2;
        final textY = size.height + 5.0;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  void _drawWeightLabels(Canvas canvas, Size size, bool isGain, bool isRtl, double minWeight, double maxWeight) {
    final textPainter = TextPainter();
    final steps = 4;
    for (int i = 0; i <= steps; i++) {
      final weight = minWeight + (maxWeight - minWeight) * (steps - i) / steps;
      final y = size.height * i / steps;
      textPainter.text = TextSpan(
        text: '${weight.toStringAsFixed(0)} kg',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10.0,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      final textX = isRtl ? size.width - textPainter.width - 5.0 : 5.0;
      final textY = y - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  void _drawAxisTitles(Canvas canvas, Size size, bool isRtl) {
    final textPainter = TextPainter();
    // X-axis title (Time)
    textPainter.text = TextSpan(
      text: 'Time',
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    final timeTitleX = size.width / 2 - textPainter.width / 2;
    final timeTitleY = size.height + 25.0;
    textPainter.paint(canvas, Offset(timeTitleX, timeTitleY));
    // Y-axis title (Weight)
    textPainter.text = TextSpan(
      text: 'Weight (kg)',
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    final weightTitleX = 5.0;
    final weightTitleY = 5.0;
    textPainter.paint(canvas, Offset(weightTitleX, weightTitleY));
  }

  // Helper to draw dotted lines
  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final total = (end - start).distance;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    var distance = 0.0;

    while (distance < total) {
      final x1 = start.dx + (dx * distance / total);
      final y1 = start.dy + (dy * distance / total);
      distance += dashWidth;
      final x2 = start.dx + (dx * distance / total);
      final y2 = start.dy + (dy * distance / total);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      distance += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GoalRow extends StatelessWidget {
  final String icon;
  final Color color;
  final String text;

  const _GoalRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SizedBox(
        // height: 50.h,
        width: double.infinity,
        // decoration: BoxDecoration(
        //   color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 240),
        //   borderRadius: BorderRadius.circular(8.r),
        // ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 4.sp),
              // width: 28.w,
              // height: 28.w,
              // decoration: BoxDecoration(
              //   color: color.withValues(alpha: 0.13),
              //   borderRadius: BorderRadius.circular(8.r),
              // ),
              child: WizardIcon(
                assetPath: icon,
                size: 70,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  // fontWeight: FontWeight.bold,
                  // fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
