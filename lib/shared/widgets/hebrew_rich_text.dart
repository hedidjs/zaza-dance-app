import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// A specialized widget for rich Hebrew text with optimal typography
class HebrewRichText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? textColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final bool enableSelection;
  final List<TextSpan>? highlights;

  const HebrewRichText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.textColor,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.enableSelection = false,
    this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.assistant(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor ?? AppColors.primaryText,
      letterSpacing: letterSpacing ?? _getOptimalLetterSpacing(),
      wordSpacing: wordSpacing ?? _getOptimalWordSpacing(),
      height: height ?? _getOptimalLineHeight(),
    );

    Widget textWidget;
    
    if (highlights != null && highlights!.isNotEmpty) {
      // Rich text with highlights
      textWidget = RichText(
        text: _buildRichTextSpan(baseStyle),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textDirection: TextDirection.rtl,
      );
    } else {
      // Simple optimized text
      textWidget = Text(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textDirection: TextDirection.rtl,
      );
    }

    if (enableSelection) {
      return SelectableText(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
      );
    }

    return textWidget;
  }

  TextSpan _buildRichTextSpan(TextStyle baseStyle) {
    if (highlights == null || highlights!.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    // Build rich text with highlights
    final spans = <TextSpan>[];
    String remainingText = text;
    
    for (final highlight in highlights!) {
      final highlightText = highlight.text ?? '';
      final index = remainingText.indexOf(highlightText);
      
      if (index >= 0) {
        // Add text before highlight
        if (index > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, index),
            style: baseStyle,
          ));
        }
        
        // Add highlighted text
        spans.add(TextSpan(
          text: highlightText,
          style: baseStyle.merge(highlight.style),
        ));
        
        // Update remaining text
        remainingText = remainingText.substring(index + highlightText.length);
      }
    }
    
    // Add remaining text
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(
        text: remainingText,
        style: baseStyle,
      ));
    }
    
    return TextSpan(children: spans);
  }

  double _getOptimalLetterSpacing() {
    if (fontSize >= 28) {
      return 0.75; // Extra large headings
    } else if (fontSize >= 22) {
      return 0.5; // Large headings
    } else if (fontSize >= 18) {
      return 0.3; // Medium headings
    } else if (fontSize >= 14) {
      return 0.2; // Body text
    } else {
      return 0.1; // Small text
    }
  }

  double _getOptimalWordSpacing() {
    if (fontSize >= 18) {
      return 2.0; // More space for larger text
    } else {
      return 1.5; // Standard spacing for body text
    }
  }

  double _getOptimalLineHeight() {
    if (fontSize >= 24) {
      return 1.25; // Tighter for large headings
    } else if (fontSize >= 18) {
      return 1.35; // Medium spacing for subheadings
    } else {
      return 1.5; // Comfortable spacing for body text
    }
  }
}

/// Helper class for creating text highlights
class HebrewTextHighlight {
  static TextSpan neonHighlight(String text, Color glowColor) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: glowColor,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: glowColor.withValues(alpha: 0.8),
            blurRadius: 8,
          ),
          Shadow(
            color: glowColor.withValues(alpha: 0.4),
            blurRadius: 16,
          ),
        ],
      ),
    );
  }

  static TextSpan emphasisHighlight(String text, {double? fontSize}) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: AppColors.neonTurquoise,
        fontWeight: FontWeight.w600,
        fontSize: fontSize, // Now properly parameterized
      ),
    );
  }

  static TextSpan warningHighlight(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: AppColors.neonPink,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.neonPink.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Predefined Hebrew text styles for consistent typography
class HebrewTextStyles {
  static const double _baseLetterSpacing = 0.3;
  static const double _baseWordSpacing = 1.5;
  static const double _baseLineHeight = 1.4;

  static TextStyle get headline1 => GoogleFonts.assistant(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing * 2,
    wordSpacing: _baseWordSpacing * 1.5,
    height: 1.2,
  );

  static TextStyle get headline2 => GoogleFonts.assistant(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing * 1.5,
    wordSpacing: _baseWordSpacing * 1.2,
    height: 1.25,
  );

  static TextStyle get headline3 => GoogleFonts.assistant(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing,
    wordSpacing: _baseWordSpacing,
    height: 1.3,
  );

  static TextStyle get subtitle1 => GoogleFonts.assistant(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing * 0.8,
    wordSpacing: _baseWordSpacing,
    height: 1.35,
  );

  static TextStyle get body1 => GoogleFonts.assistant(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing * 0.6,
    wordSpacing: _baseWordSpacing,
    height: _baseLineHeight,
  );

  static TextStyle get body2 => GoogleFonts.assistant(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing * 0.5,
    wordSpacing: _baseWordSpacing * 0.8,
    height: _baseLineHeight,
  );

  static TextStyle get caption => GoogleFonts.assistant(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
    letterSpacing: _baseLetterSpacing * 0.4,
    wordSpacing: _baseWordSpacing * 0.6,
    height: 1.3,
  );

  static TextStyle get button => GoogleFonts.assistant(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: _baseLetterSpacing * 0.8,
    wordSpacing: _baseWordSpacing,
    height: 1.2,
  );
}