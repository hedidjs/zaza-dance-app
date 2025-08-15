import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color glowColor;
  final FontWeight fontWeight;
  final Color? textColor;
  final double glowRadius;
  final TextAlign textAlign;

  const NeonText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.glowColor,
    this.fontWeight = FontWeight.normal,
    this.textColor,
    this.glowRadius = 10.0,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return GlowText(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor ?? Colors.white,
      ),
      textAlign: textAlign,
      glowColor: glowColor,
      blurRadius: glowRadius,
      offset: const Offset(0, 0),
    );
  }
}