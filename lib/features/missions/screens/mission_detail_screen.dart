import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/mission_provider.dart';

class MissionDetailScreen extends ConsumerWidget {
  final String missionId;

  const MissionDetailScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final missionState = ref.watch(missionProvider);
    final mission = missionState.missions
        .where((m) => m.id == missionId)
        .firstOrNull;

    if (mission == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mission')),
        body: const Center(child: Text('Mission non trouvée')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(mission.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor(mission.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusColor(mission.status).withValues(alpha: 0.3),
                ),
              ),
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
                      Text(
                        'Statut',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        mission.status.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _statusColor(mission.status),
                          fontWeight: FontWeight.bold,
                        ),
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
              label: 'Titre',
              value: mission.title,
            ),
            if (mission.description.isNotEmpty)
              _DetailRow(
                icon: Icons.description,
                label: 'Description',
                value: mission.description,
              ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Créée le',
              value: _formatDate(mission.createdAt),
            ),
            if (mission.updatedAt != null)
              _DetailRow(
                icon: Icons.update,
                label: 'Mise à jour',
                value: _formatDate(mission.updatedAt!),
              ),
            if (mission.status == MissionStatus.inProgress)
              _DetailRow(
                icon: Icons.linear_scale,
                label: 'Étape actuelle',
                value:
                    '${mission.currentStepIndex + 1} / ${CollectionStep.totalSteps}',
              ),

            const SizedBox(height: 40),

            // Action button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: _actionLabel(mission.status),
                icon: _actionIcon(mission.status),
                onPressed: () {
                  if (mission.status == MissionStatus.completed) {
                    // View read-only details
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
        return Colors.orange;
      case MissionStatus.inProgress:
        return const Color(0xFF0D6E4F);
      case MissionStatus.completed:
        return Colors.green;
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
