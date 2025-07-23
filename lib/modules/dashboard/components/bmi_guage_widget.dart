import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BmiGaugeWidget extends StatelessWidget {
  final double bmiValue = 30;

  @override
  Widget build(BuildContext context) {
    final bmiCategory = getBmiCategory(bmiValue);
    final markerPosition = getBmiPosition(bmiValue); // 0.0 to 1.0

    return Container(
      width: MediaQuery.sizeOf(context).width,

      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icons/bmi.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Text Row
            Row(
              children: [
                Text(
                  'Your BMI',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: MediaQuery.sizeOf(context).width * .2),
                Text(
                  bmiValue.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gauge with marker
            SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Gradient Bar
                  Positioned(
                    bottom: 10,
                    // top: MediaQuery.sizeOf(context).height * .01,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * .8,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Marker
                  Positioned(
                    left:
                        markerPosition * MediaQuery.sizeOf(context).width * 0.9,
                    top: 3,
                    child: Column(
                      children: [
                        // Bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),

                            image: DecorationImage(
                              image: AssetImage('assets/icons/tip.png'),
                              fit: BoxFit.fill,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            bmiCategory,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(width: 2, height: 30, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 12),

            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _BmiLabel(text: 'Under Weight', color: Colors.blue),
                _BmiLabel(text: 'Healthy', color: Colors.green),
                _BmiLabel(text: 'Over Weight', color: Colors.orange),
                _BmiLabel(text: 'Obese', color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // BMI category logic
  String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Under Weight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Over Weight';
    return 'Obese';
  }

  // Calculate position of marker (0.0 - 1.0)
  double getBmiPosition(double bmi) {
    if (bmi < 10) return 0.0;
    if (bmi > 40) return 1.0;
    return (bmi - 10) / 30; // Normalize 10–40 BMI range to 0.0–1.0
  }
}

class _BmiLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _BmiLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.black87)),
      ],
    );
  }
}
