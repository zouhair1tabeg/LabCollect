import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/mission_provider.dart';

class MissionListScreen extends ConsumerWidget {
  const MissionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final missionState = ref.watch(missionProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Missions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Synchronisation',
              onPressed: () => context.push('/sync-status'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion',
              onPressed: () => _confirmLogout(context, ref),
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              final filter = MissionFilter.values[index];
              ref.read(missionProvider.notifier).setFilter(filter);
            },
            tabs: [
              _buildTab('Toutes', missionState.missions.length, theme),
              _buildTab('En attente', missionState.pendingCount, Colors.orange),
              _buildTab(
                'En cours',
                missionState.inProgressCount,
                theme.colorScheme.primary,
              ),
              _buildTab('Terminées', missionState.completedCount, Colors.green),
            ],
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        body: missionState.isLoading
            ? const LoadingWidget(message: 'Chargement des missions...')
            : missionState.error != null
            ? _ErrorView(
                error: missionState.error!,
                onRetry: () =>
                    ref.read(missionProvider.notifier).loadMissions(),
              )
            : missionState.filteredMissions.isEmpty
            ? _EmptyView(filter: missionState.filter)
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(missionProvider.notifier).loadMissions(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: missionState.filteredMissions.length,
                  itemBuilder: (context, index) {
                    final mission = missionState.filteredMissions[index];
                    return _MissionCard(
                      mission: mission,
                      onTap: () => _navigateToMission(context, ref, mission),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Tab _buildTab(String label, int count, dynamic colorOrTheme) {
    final Color badgeColor;
    if (colorOrTheme is Color) {
      badgeColor = colorOrTheme;
    } else if (colorOrTheme is ThemeData) {
      badgeColor = colorOrTheme.colorScheme.primary;
    } else {
      badgeColor = Colors.grey;
    }

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMission(
    BuildContext context,
    WidgetRef ref,
    MissionModel mission,
  ) {
    switch (mission.status) {
      case MissionStatus.pending:
        ref.read(missionProvider.notifier).startMission(mission.id);
        context.push('/collection/${mission.id}/0');
        break;
      case MissionStatus.inProgress:
        final step = (mission.lastCompletedStep + 1).clamp(
          0,
          CollectionStep.totalSteps - 1,
        );
        context.push('/collection/${mission.id}/$step');
        break;
      case MissionStatus.completed:
        context.push('/missions/${mission.id}');
        break;
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

// ── Mission Card ────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback onTap;

  const _MissionCard({required this.mission, required this.onTap});

  Color _statusColor(MissionStatus status) {
    switch (status) {
      case MissionStatus.pending:
        return Colors.orange;
      case MissionStatus.inProgress:
        return const Color(0xFF1565C0);
      case MissionStatus.completed:
        return Colors.green;
    }
  }

  IconData _statusIcon(MissionStatus status) {
    switch (status) {
      case MissionStatus.pending:
        return Icons.pending_actions;
      case MissionStatus.inProgress:
        return Icons.play_circle_outline;
      case MissionStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  String _actionLabel(MissionStatus status) {
    switch (status) {
      case MissionStatus.pending:
        return 'Commencer Collecte';
      case MissionStatus.inProgress:
        return 'Reprendre Collecte';
      case MissionStatus.completed:
        return 'Voir Détails';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(mission.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Status color strip
            Container(width: 5, height: 100, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _statusIcon(mission.status),
                          color: statusColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mission.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            mission.status.label,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    if (mission.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        mission.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (mission.status == MissionStatus.inProgress)
                          Text(
                            'Étape ${mission.lastCompletedStep + 2}/${CollectionStep.totalSteps}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _actionLabel(mission.status),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: statusColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ──────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty View ──────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final MissionFilter filter;

  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String message;
    final IconData icon;

    switch (filter) {
      case MissionFilter.all:
        message = 'Aucune mission assignée';
        icon = Icons.assignment_outlined;
        break;
      case MissionFilter.pending:
        message = 'Aucune mission en attente';
        icon = Icons.pending_actions;
        break;
      case MissionFilter.inProgress:
        message = 'Aucune mission en cours';
        icon = Icons.play_circle_outline;
        break;
      case MissionFilter.completed:
        message = 'Aucune mission terminée';
        icon = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
