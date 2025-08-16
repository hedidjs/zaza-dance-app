import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

/// Enhanced neon effects for the hip-hop aesthetic
/// Provides advanced visual effects for the dance studio app
class NeonGlowContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final bool animate;
  final Duration pulseDuration;
  final BorderRadius? borderRadius;
  final double opacity;

  const NeonGlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppColors.neonPink,
    this.glowRadius = 20.0,
    this.animate = false,
    this.pulseDuration = const Duration(seconds: 2),
    this.borderRadius,
    this.opacity = 0.6,
  });

  @override
  State<NeonGlowContainer> createState() => _NeonGlowContainerState();
}

class _NeonGlowContainerState extends State<NeonGlowContainer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _pulseController = AnimationController(
        duration: widget.pulseDuration,
        vsync: this,
      );
      _pulseAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ));
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(widget.opacity),
            blurRadius: widget.glowRadius,
            spreadRadius: widget.glowRadius / 4,
          ),
          BoxShadow(
            color: widget.glowColor.withOpacity(widget.opacity * 0.5),
            blurRadius: widget.glowRadius * 2,
            spreadRadius: widget.glowRadius / 2,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.animate) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: 1.0 + (_pulseAnimation.value * 0.05),
            child: Opacity(
              opacity: 0.7 + (_pulseAnimation.value * 0.3),
              child: child,
            ),
          );
        },
      );
    }

    return child;
  }
}

/// Animated neon border effect
class NeonBorder extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final bool animate;

  const NeonBorder({
    super.key,
    required this.child,
    this.borderColor = AppColors.neonTurquoise,
    this.borderWidth = 2.0,
    this.borderRadius,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );

    if (animate) {
      return container
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: borderColor.withOpacity(0.3),
          );
    }

    return container;
  }
}

/// Floating neon particles effect
class NeonParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double maxSize;
  final double minSize;
  final Duration animationDuration;

  const NeonParticles({
    super.key,
    this.particleCount = 20,
    this.particleColor = AppColors.neonPink,
    this.maxSize = 4.0,
    this.minSize = 1.0,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<NeonParticles> createState() => _NeonParticlesState();
}

class _NeonParticlesState extends State<NeonParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _offsetAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _offsetAnimations = [];
    for (int index = 0; index < _controllers.length; index++) {
      _offsetAnimations.add(
        Tween<Offset>(
          begin: Offset(
            (index % 5) * 0.2 - 0.4, // Random X position
            1.2, // Start below screen
          ),
          end: Offset(
            (index % 5) * 0.2 - 0.4 + (index % 3 - 1) * 0.3, // Drift horizontally
            -0.2, // End above screen
          ),
        ).animate(CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.linear,
        )),
      );
    }

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.3),
      ));
    }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.particleCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return SlideTransition(
              position: _offsetAnimations[index],
              child: FadeTransition(
                opacity: _opacityAnimations[index],
                child: Container(
                  width: widget.minSize +
                      (index % 3) * (widget.maxSize - widget.minSize) / 3,
                  height: widget.minSize +
                      (index % 3) * (widget.maxSize - widget.minSize) / 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.particleColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.particleColor.withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Animated neon divider
class NeonDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double thickness;
  final bool animate;

  const NeonDivider({
    super.key,
    this.color = AppColors.neonTurquoise,
    this.height = 20.0,
    this.thickness = 1.0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget divider = Container(
      height: height,
      child: Center(
        child: Container(
          height: thickness,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                color,
                color,
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );

    if (animate) {
      return divider
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 3000.ms,
            color: color.withOpacity(0.3),
          );
    }

    return divider;
  }
}

/// Neon button with enhanced effects
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color glowColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.glowColor = AppColors.neonPink,
    this.textColor = AppColors.primaryText,
    this.fontSize = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: NeonGlowContainer(
              glowColor: widget.glowColor,
              glowRadius: _isPressed ? 15.0 : 25.0,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(25),
              opacity: _isPressed ? 0.8 : 0.6,
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      widget.glowColor.withOpacity(0.8),
                      widget.glowColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: widget.glowColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: widget.glowColor.withOpacity(0.8),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}