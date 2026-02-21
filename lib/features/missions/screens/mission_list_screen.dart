import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/sync_status_icon.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/mission_provider.dart';

class MissionListScreen extends ConsumerWidget {
  const MissionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionState = ref.watch(missionProvider);

    return DefaultTabController(
      length: 4,
      child: GlassScaffold(
        title: 'Mes Missions',
        actions: [
          const SyncStatusIcon(),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout, color: LiquidGlass.textSecondary),
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
            _buildTab(
              'Toutes',
              missionState.missions.length,
              LiquidGlass.accentBlue,
            ),
            _buildTab(
              'En attente',
              missionState.pendingCount,
              LiquidGlass.pending,
            ),
            _buildTab(
              'En cours',
              missionState.inProgressCount,
              LiquidGlass.accentViolet,
            ),
            _buildTab(
              'Terminées',
              missionState.completedCount,
              LiquidGlass.done,
            ),
          ],
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
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
                color: LiquidGlass.accentBlue,
                backgroundColor: LiquidGlass.bgDark,
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

  Tab _buildTab(String label, int count, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: LiquidGlass.statusBadge(badgeColor),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 0.5,
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
        title: Text('Déconnexion', style: LiquidGlass.heading(fontSize: 20)),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: LiquidGlass.bodySecondary(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: TextStyle(color: LiquidGlass.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: Text(
              'Déconnexion',
              style: TextStyle(color: LiquidGlass.error),
            ),
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
        return LiquidGlass.pending;
      case MissionStatus.inProgress:
        return LiquidGlass.accentViolet;
      case MissionStatus.completed:
        return LiquidGlass.done;
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
        return 'Commencer';
      case MissionStatus.inProgress:
        return 'Reprendre';
      case MissionStatus.completed:
        return 'Voir Détails';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(mission.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              // Status color strip
              Container(
                width: 4,
                height: 90,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
                ),
              ),
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
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              mission.title,
                              style: LiquidGlass.body(
                                fontSize: 16,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: LiquidGlass.statusBadge(statusColor),
                            child: Text(
                              mission.status.label,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (mission.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          mission.description,
                          style: LiquidGlass.bodySecondary(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (mission.status == MissionStatus.inProgress)
                            Text(
                              'Étape ${mission.lastCompletedStep + 2}/${CollectionStep.totalSteps}',
                              style: LiquidGlass.bodySecondary(fontSize: 11),
                            )
                          else
                            const SizedBox.shrink(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _actionLabel(mission.status),
                                style: LiquidGlass.body(fontSize: 13).copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: LiquidGlass.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: LiquidGlass.bodySecondary().copyWith(
                color: LiquidGlass.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: EdgeInsets.zero,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: LiquidGlass.accentBlue),
                label: Text(
                  'Réessayer',
                  style: TextStyle(color: LiquidGlass.accentBlue),
                ),
              ),
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
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.20)),
          const SizedBox(height: 16),
          Text(message, style: LiquidGlass.bodySecondary(fontSize: 16)),
        ],
      ),
    );
  }
}
