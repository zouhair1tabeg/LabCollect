import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';

/// Frosted glass card with backdrop blur, semi-transparent fill,
/// white border, and dual shadow (drop + inset highlight).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: LiquidGlass.glassBlur,
          sigmaY: LiquidGlass.glassBlur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: LiquidGlass.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor ?? LiquidGlass.glassBorder),
            boxShadow: [
              BoxShadow(
                blurRadius: 32,
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ],
          ),
          // Inset highlight at top
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
