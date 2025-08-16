import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBackground,
                Color.lerp(
                  AppColors.darkBackground,
                  AppColors.neonPink.withOpacity(0.1),
                  _animation.value * 0.3,
                )!,
                Color.lerp(
                  AppColors.darkBackground,
                  AppColors.neonTurquoise.withOpacity(0.1),
                  (1 - _animation.value) * 0.3,
                )!,
                AppColors.darkBackground,
              ],
              stops: [
                0.0,
                0.3 + (_animation.value * 0.2),
                0.7 - (_animation.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}