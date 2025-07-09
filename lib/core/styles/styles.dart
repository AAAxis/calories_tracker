import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//common text widget

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontFamily,
    this.lineSpacing,
    this.letterSpacing,
    this.textOverflow,
    this.maxLines,
    this.textDecoration,
    this.color,
    this.fontWeight,
    this.textAlign = TextAlign.start,
  });
  final String text;
  final String? fontFamily;
  final TextOverflow? textOverflow;
  final TextDecoration? textDecoration;
  final double? fontSize;
  final double? letterSpacing;
  final double? lineSpacing;
  final TextAlign textAlign;
  final Color? color;
  final int? maxLines;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: textOverflow ?? TextOverflow.visible,
      style: GoogleFonts.inter(
        height: lineSpacing,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
        decorationColor: Colors.white,

        fontWeight: fontWeight,
        fontSize: fontSize ?? Theme.of(context).textTheme.bodyMedium!.fontSize,
        color: color ?? Colors.black,
      ),
    );
  }
}
