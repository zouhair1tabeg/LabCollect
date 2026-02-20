import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sync/providers/sync_provider.dart';
import '../services/connectivity_service.dart';

/// Sync status icon for AppBar
/// Green = synced, Orange = pending, Red = offline
class SyncStatusIcon extends ConsumerWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final isOnline = ref.watch(isOnlineProvider);

    final Color color;
    final IconData icon;
    final String tooltip;

    if (!isOnline) {
      color = Colors.red;
      icon = Icons.cloud_off;
      tooltip = 'Hors ligne';
    } else if (syncState.uiStatus == SyncUiStatus.syncing) {
      color = Colors.blue;
      icon = Icons.sync;
      tooltip = 'Synchronisation en cours...';
    } else if (syncState.pendingCount > 0) {
      color = Colors.orange;
      icon = Icons.cloud_upload;
      tooltip = '${syncState.pendingCount} en attente';
    } else {
      color = Colors.green;
      icon = Icons.cloud_done;
      tooltip = 'Synchronisé';
    }

    return Tooltip(
      message: tooltip,
      child: Stack(
        children: [
          IconButton(
            icon: syncState.uiStatus == SyncUiStatus.syncing
                ? _AnimatedSyncIcon(color: color)
                : Icon(icon, color: color),
            onPressed: () {},
          ),
          if (syncState.pendingCount > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '${syncState.pendingCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated rotating sync icon
class _AnimatedSyncIcon extends StatefulWidget {
  final Color color;
  const _AnimatedSyncIcon({required this.color});

  @override
  State<_AnimatedSyncIcon> createState() => _AnimatedSyncIconState();
}

class _AnimatedSyncIconState extends State<_AnimatedSyncIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.sync, color: widget.color),
    );
  }
}
