import 'package:flutter/material.dart';

/// Reusable confirmation dialog for critical actions
class ConfirmDialog {
  /// Show a confirmation dialog and return true if confirmed
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
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
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
