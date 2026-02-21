import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/services/connectivity_service.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_scaffold.dart';
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
      await ref
          .read(missionProvider.notifier)
          .completeMission(widget.missionId);

      final isOnline = ref.read(isOnlineProvider);

      if (isOnline) {
        await ref.read(syncServiceProvider).syncMission(widget.missionId);
      } else {
        await ref
            .read(syncServiceProvider)
            .queueForSync(
              widget.missionId,
              ref.read(collectionProvider(widget.missionId)).toJson(),
            );
      }

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
    final isOnline = ref.watch(isOnlineProvider);

    if (_isSaved) {
      return GlassScaffold(
        showAppBar: false,
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
                    color: LiquidGlass.done.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: LiquidGlass.done.withValues(alpha: 0.20),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: LiquidGlass.done,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mission Complétée !',
                  style: LiquidGlass.heading(
                    fontSize: 28,
                  ).copyWith(color: LiquidGlass.done),
                ),
                const SizedBox(height: 12),
                Text(
                  isOnline
                      ? 'Données synchronisées avec le serveur'
                      : 'Données sauvegardées localement\n(Synchronisation automatique une fois en ligne)',
                  textAlign: TextAlign.center,
                  style: LiquidGlass.bodySecondary(),
                ),
                const SizedBox(height: 48),
                GlassButton(
                  label: 'Retour aux Missions',
                  icon: Icons.list,
                  onPressed: () => context.go('/missions'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GlassScaffold(
      title: 'Complétion',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done_outlined,
              size: 80,
              color: LiquidGlass.accentBlue,
            ),
            const SizedBox(height: 24),
            Text(
              'Prêt à enregistrer',
              style: LiquidGlass.heading(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              'Toutes les données ont été collectées. Appuyez pour enregistrer la mission.',
              textAlign: TextAlign.center,
              style: LiquidGlass.bodySecondary(),
            ),
            const SizedBox(height: 16),

            // Connectivity pill
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: 20,
              borderColor: isOnline
                  ? LiquidGlass.done.withValues(alpha: 0.30)
                  : LiquidGlass.pending.withValues(alpha: 0.30),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: isOnline ? LiquidGlass.done : LiquidGlass.pending,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'En ligne' : 'Hors ligne',
                    style: LiquidGlass.body(fontSize: 13).copyWith(
                      color: isOnline ? LiquidGlass.done : LiquidGlass.pending,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: _isSaving
                    ? 'Enregistrement...'
                    : 'Enregistrer la Mission',
                icon: _isSaving ? null : Icons.save,
                isLoading: _isSaving,
                accentColor: LiquidGlass.done,
                onPressed: _isSaving ? null : _saveMission,
              ),
            ),

            const SizedBox(height: 12),

            GlassButton(
              label: 'Revenir à la révision',
              isOutlined: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
