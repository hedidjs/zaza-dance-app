import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';

/// Refined neon text widget with subtle glow effects
/// Maintains hip-hop aesthetic while being more readable and user-friendly
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
  final bool isSubtle; // New parameter for subtle mode

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
    this.isSubtle = true, // Default to subtle mode
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

    // Use subtle glow for better readability
    final effectiveGlowRadius = isSubtle ? glowRadius * 0.4 : glowRadius;
    final glowOpacity = isSubtle ? 0.4 : 0.8;

    return GlowText(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      glowColor: glowColor.withOpacity(glowOpacity),
      blurRadius: effectiveGlowRadius,
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