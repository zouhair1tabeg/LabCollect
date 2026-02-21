import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';
import 'glass_button.dart';

/// Reusable confirmation dialog styled with Liquid Glass.
class ConfirmDialog {
  /// Show a glass-styled confirmation dialog and return true if confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LiquidGlass.glassRadius),
            side: BorderSide(color: LiquidGlass.glassBorder),
          ),
          title: Text(title, style: LiquidGlass.heading(fontSize: 20)),
          content: Text(message, style: LiquidGlass.bodySecondary()),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Expanded(
              child: GlassButton(
                label: cancelLabel,
                isOutlined: true,
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                label: confirmLabel,
                accentColor: isDestructive ? LiquidGlass.error : null,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  /// Show unsaved changes dialog
  static Future<bool> showUnsavedChanges(BuildContext context) {
    return show(
      context: context,
      title: 'Modifications non sauvegardées',
      message:
          'Vous avez des modifications non sauvegardées. Voulez-vous quitter sans sauvegarder ?',
      confirmLabel: 'Quitter',
      cancelLabel: 'Rester',
      isDestructive: true,
    );
  }
}
