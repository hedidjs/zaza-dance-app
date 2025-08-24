import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Zaza Dance logo widget with customizable size and glow effects
class ZazaLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool withGlow;
  final Color? glowColor;
  final double glowRadius;
  final BoxFit fit;

  const ZazaLogo({
    super.key,
    this.width,
    this.height,
    this.withGlow = true,
    this.glowColor,
    this.glowRadius = 20.0,
    this.fit = BoxFit.contain,
  });

  /// Factory constructor for app bar logo
  const ZazaLogo.appBar({
    super.key,
    this.width = 160,
    this.height = 55,
    this.withGlow = false,
    this.glowColor,
    this.glowRadius = 15.0,
    this.fit = BoxFit.contain,
  });

  /// Factory constructor for home page hero logo
  const ZazaLogo.hero({
    super.key,
    this.width = 250,
    this.height = 80,
    this.withGlow = false,
    this.glowColor,
    this.glowRadius = 30.0,
    this.fit = BoxFit.contain,
  });

  /// Factory constructor for splash screen logo
  const ZazaLogo.splash({
    super.key,
    this.width = 200,
    this.height = 65,
    this.withGlow = false,
    this.glowColor,
    this.glowRadius = 25.0,
    this.fit = BoxFit.contain,
  });

  /// Factory constructor for small contexts (like cards)
  const ZazaLogo.small({
    super.key,
    this.width = 80,
    this.height = 25,
    this.withGlow = false,
    this.glowColor,
    this.glowRadius = 10.0,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Image.network(
      'https://yyvoavzgapsyycjwirmg.supabase.co/storage/v1/object/public/logo/ZAZA%20LOGO.png',
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: Text(
            'Zaza Dance',
            style: TextStyle(
              fontSize: (height ?? 40) * 0.4,
              fontWeight: FontWeight.bold,
              color: glowColor ?? const Color(0xFFFF00FF),
            ),
          ),
        );
      },
    );

    if (!withGlow) {
      return logo.animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8));
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor ?? const Color(0xFFFF00FF),
            blurRadius: glowRadius,
            spreadRadius: glowRadius / 4,
          ),
          BoxShadow(
            color: (glowColor ?? const Color(0xFFFF00FF)).withValues(alpha: 0.3),
            blurRadius: glowRadius * 2,
            spreadRadius: glowRadius / 2,
          ),
        ],
      ),
      child: logo,
    ).animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8))
        .then()
        .shimmer(
          duration: 2000.ms,
          color: glowColor ?? const Color(0xFFFF00FF),
        );
  }
}

/// Zaza Dance icon widget for contexts where just the icon is needed
class ZazaIcon extends StatelessWidget {
  final double size;
  final bool withGlow;
  final Color? glowColor;
  final double glowRadius;

  const ZazaIcon({
    super.key,
    this.size = 40,
    this.withGlow = false,
    this.glowColor,
    this.glowRadius = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Image.asset(
      'assets/images/zaza_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor ?? const Color(0xFFFF00FF),
          ),
          child: Icon(
            Icons.music_note,
            size: size * 0.6,
            color: Colors.white,
          ),
        );
      },
    );

    if (!withGlow) {
      return icon;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor ?? const Color(0xFFFF00FF),
            blurRadius: glowRadius,
            spreadRadius: glowRadius / 4,
          ),
        ],
      ),
      child: icon,
    );
  }
}