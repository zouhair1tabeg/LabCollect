import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';
import 'glass_card.dart';

/// A centered loading indicator with optional message, wrapped in glass.
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: LiquidGlass.accentBlue),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: LiquidGlass.bodySecondary()),
            ],
          ],
        ),
      ),
    );
  }
}
