import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

/// Advanced Hebrew text widget with neon glow effects
/// Supports RTL layout and enhanced typography for hip-hop aesthetic
class NeonHebrewText extends StatelessWidget {
  final String text;
  final NeonTextStyle neonStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? glowColor;
  final bool animate;

  const NeonHebrewText(
    this.text, {
    super.key,
    this.neonStyle = NeonTextStyle.body,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.glowColor,
    this.animate = false,
  });

  /// Large hero text with strong glow
  const NeonHebrewText.hero(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.glowColor,
    this.animate = true,
  }) : neonStyle = NeonTextStyle.hero;

  /// Headline text with medium glow
  const NeonHebrewText.headline(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.glowColor,
    this.animate = false,
  }) : neonStyle = NeonTextStyle.headline;

  /// Title text with subtle glow
  const NeonHebrewText.title(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.glowColor,
    this.animate = false,
  }) : neonStyle = NeonTextStyle.title;

  /// Body text without glow
  const NeonHebrewText.body(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.glowColor,
    this.animate = false,
  }) : neonStyle = NeonTextStyle.body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = _getTextStyle(theme);
    final effectiveGlowColor = glowColor ?? _getDefaultGlowColor();

    Widget textWidget = Text(
      text,
      style: textStyle.copyWith(
        shadows: _createGlowEffect(effectiveGlowColor),
      ),
      textAlign: textAlign ?? TextAlign.right, // Default RTL alignment
      maxLines: maxLines,
      overflow: overflow,
      textDirection: TextDirection.rtl,
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return AnimatedOpacity(
            opacity: value,
            duration: const Duration(milliseconds: 500),
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: child,
            ),
          );
        },
        child: textWidget,
      );
    }

    return textWidget;
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (neonStyle) {
      case NeonTextStyle.hero:
        return GoogleFonts.assistant(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
          letterSpacing: 1.2,
        );
      case NeonTextStyle.headline:
        return GoogleFonts.assistant(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
          letterSpacing: 0.8,
        );
      case NeonTextStyle.title:
        return GoogleFonts.assistant(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
          letterSpacing: 0.5,
        );
      case NeonTextStyle.body:
        return GoogleFonts.assistant(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryText,
        );
    }
  }

  Color _getDefaultGlowColor() {
    switch (neonStyle) {
      case NeonTextStyle.hero:
        return AppColors.neonPink;
      case NeonTextStyle.headline:
        return AppColors.neonTurquoise;
      case NeonTextStyle.title:
        return AppColors.neonPink;
      case NeonTextStyle.body:
        return Colors.transparent;
    }
  }

  List<Shadow> _createGlowEffect(Color glowColor) {
    if (glowColor == Colors.transparent) return [];

    switch (neonStyle) {
      case NeonTextStyle.hero:
        return [
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 15,
            color: glowColor.withValues(alpha: 1.0),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 30,
            color: glowColor.withValues(alpha: 0.8),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 45,
            color: glowColor.withValues(alpha: 0.6),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 60,
            color: glowColor.withValues(alpha: 0.3),
          ),
        ];
      case NeonTextStyle.headline:
        return [
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 8,
            color: glowColor.withValues(alpha: 0.9),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 16,
            color: glowColor.withValues(alpha: 0.6),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 24,
            color: glowColor.withValues(alpha: 0.3),
          ),
        ];
      case NeonTextStyle.title:
        return [
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 5,
            color: glowColor.withValues(alpha: 0.8),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 10,
            color: glowColor.withValues(alpha: 0.4),
          ),
        ];
      case NeonTextStyle.body:
        return [];
    }
  }
}

/// Text style types with different glow intensities
enum NeonTextStyle {
  hero,     // Large text with strongest glow
  headline, // Medium text with strong glow
  title,    // Small text with subtle glow
  body,     // Body text without glow
}

/// Animated neon text with pulsing effect for special emphasis
class PulsingNeonText extends StatefulWidget {
  final String text;
  final NeonTextStyle style;
  final Color? glowColor;
  final Duration pulseDuration;

  const PulsingNeonText(
    this.text, {
    super.key,
    this.style = NeonTextStyle.headline,
    this.glowColor,
    this.pulseDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<PulsingNeonText> createState() => _PulsingNeonTextState();
}

class _PulsingNeonTextState extends State<PulsingNeonText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: NeonHebrewText(
            widget.text,
            neonStyle: widget.style,
            glowColor: widget.glowColor,
          ),
        );
      },
    );
  }
}