import 'package:flutter/material.dart';
import 'glass_button.dart';

/// A styled reusable button for LabCollect — delegates to GlassButton.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isOutlined: isOutlined,
      accentColor: backgroundColor,
      width: width,
    );
  }
}
