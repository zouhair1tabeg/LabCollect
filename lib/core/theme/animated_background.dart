import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'liquid_glass_theme.dart';

/// Animated dark background with 3 floating color orbs.
/// Creates the "Liquid Glass" ambient effect behind all content.
class AnimatedGlassBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGlassBackground({super.key, required this.child});

  @override
  State<AnimatedGlassBackground> createState() =>
      _AnimatedGlassBackgroundState();
}

class _AnimatedGlassBackgroundState extends State<AnimatedGlassBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LiquidGlass.bgDark,
      child: Stack(
        children: [
          // Blue orb — top left
          AnimatedBuilder(
            animation: _ctrl1,
            builder: (context, child) {
              final dy = math.sin(_ctrl1.value * math.pi) * 30;
              return Positioned(
                top: -40 + dy,
                left: -60,
                child: _Orb(
                  color: LiquidGlass.orbBlue,
                  opacity: LiquidGlass.orbBlueOpacity,
                  radius: 180,
                ),
              );
            },
          ),
          // Violet orb — bottom right
          AnimatedBuilder(
            animation: _ctrl2,
            builder: (context, child) {
              final dy = math.cos(_ctrl2.value * math.pi) * 30;
              return Positioned(
                bottom: -60 + dy,
                right: -40,
                child: _Orb(
                  color: LiquidGlass.orbViolet,
                  opacity: LiquidGlass.orbVioletOpacity,
                  radius: 200,
                ),
              );
            },
          ),
          // Green orb — center
          AnimatedBuilder(
            animation: _ctrl3,
            builder: (context, child) {
              final dy = math.sin(_ctrl3.value * math.pi * 0.8) * 25;
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.35 + dy,
                left: MediaQuery.of(context).size.width * 0.25,
                child: _Orb(
                  color: LiquidGlass.orbGreen,
                  opacity: LiquidGlass.orbGreenOpacity,
                  radius: 160,
                ),
              );
            },
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double opacity;
  final double radius;

  const _Orb({
    required this.color,
    required this.opacity,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
