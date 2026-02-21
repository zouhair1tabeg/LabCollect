import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/liquid_glass_theme.dart';
import '../../features/sync/providers/sync_provider.dart';
import '../services/connectivity_service.dart';
import 'glass_card.dart';

/// Glass pill sync indicator with animated dot for AppBar.
class SyncStatusIcon extends ConsumerWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final isOnline = ref.watch(isOnlineProvider);

    final Color color;
    final String text;

    if (!isOnline) {
      color = LiquidGlass.syncOffline;
      text = 'Hors ligne';
    } else if (syncState.uiStatus == SyncUiStatus.syncing) {
      color = LiquidGlass.accentBlue;
      text = 'Sync...';
    } else if (syncState.pendingCount > 0) {
      color = LiquidGlass.syncOffline;
      text = '${syncState.pendingCount} en attente';
    } else {
      color = LiquidGlass.syncOnline;
      text = 'Synced';
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedDot(color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: LiquidGlass.body(
              fontSize: 11,
            ).copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot that fades between 0.5 and 1.0 opacity.
class _AnimatedDot extends StatefulWidget {
  final Color color;
  const _AnimatedDot({required this.color});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
