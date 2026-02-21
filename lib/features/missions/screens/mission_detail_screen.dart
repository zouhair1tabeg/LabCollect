import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../providers/mission_provider.dart';

class MissionDetailScreen extends ConsumerWidget {
  final String missionId;

  const MissionDetailScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionState = ref.watch(missionProvider);
    final mission = missionState.missions
        .where((m) => m.id == missionId)
        .firstOrNull;

    if (mission == null) {
      return GlassScaffold(
        title: 'Mission',
        body: Center(
          child: Text(
            'Mission non trouvée',
            style: LiquidGlass.bodySecondary(),
          ),
        ),
      );
    }

    return GlassScaffold(
      title: mission.title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            GlassCard(
              borderColor: _statusColor(mission.status).withValues(alpha: 0.40),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(mission.status),
                    color: _statusColor(mission.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STATUT', style: LiquidGlass.label()),
                      const SizedBox(height: 2),
                      Text(
                        mission.status.label,
                        style: LiquidGlass.heading(
                          fontSize: 18,
                        ).copyWith(color: _statusColor(mission.status)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mission details
            _DetailRow(
              icon: Icons.assignment,
              label: 'TITRE',
              value: mission.title,
            ),
            if (mission.description.isNotEmpty)
              _DetailRow(
                icon: Icons.description,
                label: 'DESCRIPTION',
                value: mission.description,
              ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'CRÉÉE LE',
              value: _formatDate(mission.createdAt),
            ),
            if (mission.updatedAt != null)
              _DetailRow(
                icon: Icons.update,
                label: 'MISE À JOUR',
                value: _formatDate(mission.updatedAt!),
              ),
            if (mission.status == MissionStatus.inProgress)
              _DetailRow(
                icon: Icons.linear_scale,
                label: 'ÉTAPE ACTUELLE',
                value:
                    '${mission.currentStepIndex + 1} / ${CollectionStep.totalSteps}',
              ),

            const SizedBox(height: 40),

            // Action button
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: _actionLabel(mission.status),
                icon: _actionIcon(mission.status),
                accentColor: _statusColor(mission.status),
                onPressed: () {
                  if (mission.status == MissionStatus.completed) {
                    context.push(
                      '/collection/${mission.id}/${CollectionStep.totalSteps - 1}',
                    );
                  } else {
                    if (mission.status == MissionStatus.pending) {
                      ref
                          .read(missionProvider.notifier)
                          .startMission(mission.id);
                    }
                    context.push(
                      '/collection/${mission.id}/${mission.currentStepIndex}',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

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
        return Icons.play_circle;
      case MissionStatus.completed:
        return Icons.check_circle;
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

  IconData _actionIcon(MissionStatus status) {
    switch (status) {
      case MissionStatus.pending:
        return Icons.play_arrow;
      case MissionStatus.inProgress:
        return Icons.fast_forward;
      case MissionStatus.completed:
        return Icons.visibility;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: LiquidGlass.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: LiquidGlass.label()),
                const SizedBox(height: 2),
                Text(value, style: LiquidGlass.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
