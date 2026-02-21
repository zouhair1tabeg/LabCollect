import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/services/connectivity_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../providers/sync_provider.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return GlassScaffold(
      title: 'Synchronisation',
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: LiquidGlass.textPrimary),
        onPressed: () => context.pop(),
      ),
      body: Column(
        children: [
          // Connectivity banner
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: 0,
            borderColor: isOnline
                ? LiquidGlass.done.withValues(alpha: 0.30)
                : LiquidGlass.error.withValues(alpha: 0.30),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 18,
                  color: isOnline ? LiquidGlass.done : LiquidGlass.error,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline
                      ? 'Connecté — synchronisation possible'
                      : 'Hors ligne — en attente de connexion',
                  style: LiquidGlass.body(fontSize: 13).copyWith(
                    color: isOnline ? LiquidGlass.done : LiquidGlass.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(
                  label: 'EN ATTENTE',
                  count: syncState.pendingCount,
                  color: LiquidGlass.pending,
                  icon: Icons.hourglass_empty,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'SYNCHRONISÉS',
                  count: syncState.syncedCount,
                  color: LiquidGlass.done,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'ÉCHOUÉS',
                  count: syncState.failedCount,
                  color: LiquidGlass.error,
                  icon: Icons.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: syncState.uiStatus == SyncUiStatus.syncing
                        ? 'Synchronisation...'
                        : 'Synchroniser',
                    icon: Icons.sync,
                    isLoading: syncState.uiStatus == SyncUiStatus.syncing,
                    onPressed:
                        syncState.uiStatus == SyncUiStatus.syncing || !isOnline
                        ? null
                        : () => ref.read(syncProvider.notifier).syncNow(),
                  ),
                ),
                if (syncState.failedCount > 0) ...[
                  const SizedBox(width: 8),
                  GlassButton(
                    label: 'Réessayer',
                    icon: Icons.refresh,
                    isOutlined: true,
                    accentColor: LiquidGlass.pending,
                    onPressed: () =>
                        ref.read(syncProvider.notifier).retryFailed(),
                  ),
                ],
              ],
            ),
          ),

          // Message
          if (syncState.message != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                borderColor: syncState.uiStatus == SyncUiStatus.error
                    ? LiquidGlass.error.withValues(alpha: 0.30)
                    : LiquidGlass.done.withValues(alpha: 0.30),
                child: Text(
                  syncState.message!,
                  style: LiquidGlass.body().copyWith(
                    color: syncState.uiStatus == SyncUiStatus.error
                        ? LiquidGlass.error
                        : LiquidGlass.done,
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
                style: LiquidGlass.bodySecondary(fontSize: 12),
              ),
            ),

          Divider(color: Colors.white.withValues(alpha: 0.10), height: 32),

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
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun élément en attente',
                          style: LiquidGlass.bodySecondary(),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: syncState.items.length,
                    itemBuilder: (context, index) {
                      final item = syncState.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                _statusIcon(item.status),
                                color: _statusColor(item.status),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mission: ${item.missionId}',
                                      style: LiquidGlass.body(fontSize: 14),
                                    ),
                                    Text(
                                      '${item.status.label} • ${item.attempts} tentative(s)',
                                      style: LiquidGlass.bodySecondary(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatTime(item.createdAt),
                                style: LiquidGlass.bodySecondary(fontSize: 11),
                              ),
                            ],
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
              child: GlassButton(
                label: 'Effacer les éléments synchronisés',
                icon: Icons.cleaning_services,
                isOutlined: true,
                onPressed: () =>
                    ref.read(syncProvider.notifier).clearCompleted(),
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
        return LiquidGlass.pending;
      case SyncStatus.syncing:
        return LiquidGlass.accentBlue;
      case SyncStatus.synced:
        return LiquidGlass.done;
      case SyncStatus.failed:
        return LiquidGlass.error;
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
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderColor: color.withValues(alpha: 0.20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: LiquidGlass.heading(fontSize: 24).copyWith(color: color),
            ),
            Text(
              label,
              style: LiquidGlass.label().copyWith(color: color, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
