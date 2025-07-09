import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';

class CalorieTrackerProgressBar extends StatelessWidget {
  const CalorieTrackerProgressBar({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.overallValue,
  });
  final String title;
  final double value;
  final Color color;
  final String overallValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        SizedBox(height: 5.h(context)),
        SizedBox(
          width: 62.w(context),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7.h(context),
            borderRadius: BorderRadius.circular(10),
            color: color,
            backgroundColor: AppColors.grey,
          ),
        ),
        SizedBox(height: 5.h(context)),
        Padding(
          padding: EdgeInsets.only(left: 10.w(context)),
          child: AppText(
            overallValue,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xff444444),
          ),
        ),
      ],
    );
  }
}
