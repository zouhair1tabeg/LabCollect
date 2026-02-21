import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';
import 'glass_button.dart';

/// Reusable empty state widget with icon, title, subtitle, and optional action.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.white.withValues(alpha: 0.20)),
            const SizedBox(height: 16),
            Text(
              title,
              style: LiquidGlass.heading(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: LiquidGlass.bodySecondary(),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GlassButton(
                label: actionLabel!,
                icon: Icons.refresh,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
