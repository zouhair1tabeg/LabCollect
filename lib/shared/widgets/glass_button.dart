import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';

/// Gradient glass button with scale animation on press.
/// [isOutlined] renders a glass outline variant (no gradient fill).
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? accentColor;
  final double? width;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.accentColor,
    this.width,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? LiquidGlass.accentBlue;
    final darkerAccent = HSLColor.fromColor(accent)
        .withLightness(
          (HSLColor.fromColor(accent).lightness * 0.6).clamp(0.0, 1.0),
        )
        .toColor();

    final bool disabled = widget.onPressed == null || widget.isLoading;

    final child = widget.isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.isOutlined ? accent : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isOutlined ? accent : Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: LiquidGlass.body(fontSize: 15).copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isOutlined ? accent : Colors.white,
                ),
              ),
            ],
          );

    if (widget.isOutlined) {
      return SizedBox(
        width: widget.width,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, ch) =>
              Transform.scale(scale: _scaleAnim.value, child: ch),
          child: GestureDetector(
            onTapDown: disabled ? null : (_) => _scaleCtrl.forward(),
            onTapUp: disabled
                ? null
                : (_) {
                    _scaleCtrl.reverse();
                    widget.onPressed?.call();
                  },
            onTapCancel: disabled ? null : () => _scaleCtrl.reverse(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(LiquidGlass.buttonRadius),
                border: Border.all(
                  color: disabled
                      ? accent.withValues(alpha: 0.20)
                      : accent.withValues(alpha: 0.50),
                ),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, ch) =>
            Transform.scale(scale: _scaleAnim.value, child: ch),
        child: GestureDetector(
          onTapDown: disabled ? null : (_) => _scaleCtrl.forward(),
          onTapUp: disabled
              ? null
              : (_) {
                  _scaleCtrl.reverse();
                  widget.onPressed?.call();
                },
          onTapCancel: disabled ? null : () => _scaleCtrl.reverse(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LiquidGlass.buttonRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: disabled
                    ? [
                        accent.withValues(alpha: 0.30),
                        darkerAccent.withValues(alpha: 0.30),
                      ]
                    : [accent.withValues(alpha: 0.9), darkerAccent],
              ),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        blurRadius: 24,
                        color: LiquidGlass.buttonGlow(accent),
                      ),
                    ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
