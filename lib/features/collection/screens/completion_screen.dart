import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/services/connectivity_service.dart';
import '../../missions/providers/mission_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../providers/collection_provider.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  final String missionId;

  const CompletionScreen({super.key, required this.missionId});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveMission() async {
    setState(() => _isSaving = true);

    try {
      // Mark mission as completed
      await ref
          .read(missionProvider.notifier)
          .completeMission(widget.missionId);

      // Check connectivity
      final isOnline = ref.read(isOnlineProvider);

      if (isOnline) {
        // Sync immediately
        await ref.read(syncServiceProvider).syncMission(widget.missionId);
      } else {
        // Queue for later sync
        await ref
            .read(syncServiceProvider)
            .queueForSync(
              widget.missionId,
              ref.read(collectionProvider(widget.missionId)).toJson(),
            );
      }

      // Clear draft
      await ref
          .read(collectionProvider(widget.missionId).notifier)
          .clearDraft();

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      _controller.forward();
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = ref.watch(isOnlineProvider);

    if (_isSaved) {
      return Scaffold(
        body: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mission Complétée !',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isOnline
                      ? 'Données synchronisées avec le serveur'
                      : 'Données sauvegardées localement\n(Synchronisation automatique une fois en ligne)',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () => context.go('/missions'),
                  icon: const Icon(Icons.list),
                  label: const Text('Retour aux Missions'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Complétion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done_outlined,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Prêt à enregistrer',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toutes les données ont été collectées. Appuyez pour enregistrer la mission.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Connectivity status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: isOnline ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveMission,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Enregistrement...' : 'Enregistrer la Mission',
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Revenir à la révision'),
            ),
          ],
        ),
      ),
    );
  }
}
