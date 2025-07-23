import 'package:calories_tracker/core/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionGoalsRowData extends StatelessWidget {
  const NutritionGoalsRowData({
    super.key,
    required this.title,
    required this.controller,
    required this.hintText,
  });
  final String title;
  final String hintText;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        Container(
          width: 100,
          height: 37,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/textfield.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: TextFormField(
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              suffixIcon: Icon(Icons.edit, size: 15, color: Colors.black),
              contentPadding: EdgeInsets.only(left: 10, right: 10, bottom: 14),
            ),
          ),
        ),
      ],
    );
  }
}
