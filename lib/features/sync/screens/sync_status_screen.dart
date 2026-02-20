import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/services/connectivity_service.dart';
import '../providers/sync_provider.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final syncState = ref.watch(syncProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronisation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Connectivity banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isOnline
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 18,
                  color: isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline
                      ? 'Connecté — synchronisation possible'
                      : 'Hors ligne — en attente de connexion',
                  style: TextStyle(
                    color: isOnline
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Stats cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(
                  label: 'En attente',
                  count: syncState.pendingCount,
                  color: Colors.orange,
                  icon: Icons.hourglass_empty,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Synchronisés',
                  count: syncState.syncedCount,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Échoués',
                  count: syncState.failedCount,
                  color: Colors.red,
                  icon: Icons.error,
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        syncState.uiStatus == SyncUiStatus.syncing || !isOnline
                        ? null
                        : () => ref.read(syncProvider.notifier).syncNow(),
                    icon: syncState.uiStatus == SyncUiStatus.syncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      syncState.uiStatus == SyncUiStatus.syncing
                          ? 'Synchronisation...'
                          : 'Synchroniser',
                    ),
                  ),
                ),
                if (syncState.failedCount > 0) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(syncProvider.notifier).retryFailed(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ],
            ),
          ),

          // Message
          if (syncState.message != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: syncState.uiStatus == SyncUiStatus.error
                      ? theme.colorScheme.errorContainer
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  syncState.message!,
                  style: TextStyle(
                    color: syncState.uiStatus == SyncUiStatus.error
                        ? theme.colorScheme.onErrorContainer
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ),

          // Last sync time
          if (syncState.lastSyncTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Dernière synchronisation: ${_formatTime(syncState.lastSyncTime!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          const Divider(height: 32),

          // Queue list
          Expanded(
            child: syncState.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun élément en attente',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: syncState.items.length,
                    itemBuilder: (context, index) {
                      final item = syncState.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            _statusIcon(item.status),
                            color: _statusColor(item.status),
                          ),
                          title: Text('Mission: ${item.missionId}'),
                          subtitle: Text(
                            '${item.status.label} • ${item.attempts} tentative(s)',
                          ),
                          trailing: Text(
                            _formatTime(item.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Clear completed
          if (syncState.syncedCount > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(syncProvider.notifier).clearCompleted(),
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Effacer les éléments synchronisés'),
              ),
            ),
        ],
      ),
    );
  }

  IconData _statusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Icons.hourglass_empty;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.check_circle;
      case SyncStatus.failed:
        return Icons.error;
    }
  }

  Color _statusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Stat Card ───────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
