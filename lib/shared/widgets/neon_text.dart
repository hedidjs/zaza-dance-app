import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color glowColor;
  final FontWeight fontWeight;
  final Color? textColor;
  final double glowRadius;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;
  final double? letterSpacing;
  final double? height;

  const NeonText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.glowColor,
    this.fontWeight = FontWeight.normal,
    this.textColor,
    this.glowRadius = 10.0,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Enhanced Hebrew typography with Google Fonts
    final textStyle = GoogleFonts.assistant(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor ?? Colors.white,
      letterSpacing: letterSpacing ?? _getOptimalLetterSpacing(),
      height: height ?? _getOptimalLineHeight(),
    );

    return GlowText(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      glowColor: glowColor,
      blurRadius: glowRadius,
      offset: const Offset(0, 0),
      textDirection: TextDirection.rtl, // Always RTL for Hebrew
    );
  }

  // Optimal letter spacing for Hebrew text at different sizes
  double _getOptimalLetterSpacing() {
    if (fontSize >= 24) {
      return 0.5; // Larger headings need more spacing
    } else if (fontSize >= 16) {
      return 0.25; // Medium text
    } else {
      return 0.1; // Small text
    }
  }

  // Optimal line height for Hebrew readability
  double _getOptimalLineHeight() {
    if (fontSize >= 24) {
      return 1.2; // Tighter for headings
    } else {
      return 1.4; // More spacing for body text
    }
  }
}