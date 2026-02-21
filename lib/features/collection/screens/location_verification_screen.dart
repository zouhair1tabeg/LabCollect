import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class LocationVerificationScreen extends ConsumerStatefulWidget {
  final String missionId;

  const LocationVerificationScreen({super.key, required this.missionId});

  @override
  ConsumerState<LocationVerificationScreen> createState() =>
      _LocationVerificationScreenState();
}

class _LocationVerificationScreenState
    extends ConsumerState<LocationVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  String? _error;
  Position? _position;
  late final AnimationController _pingCtrl;

  @override
  void initState() {
    super.initState();
    _pingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _checkLocation();
  }

  @override
  void dispose() {
    _pingCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Les services de localisation sont désactivés.';
          _isChecking = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permission de localisation refusée.';
            _isChecking = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permission de localisation refusée de façon permanente.';
          _isChecking = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      ref
          .read(collectionProvider(widget.missionId).notifier)
          .setLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
          );

      setState(() {
        _position = position;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur GPS: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Localisation',
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Vérification GPS',
                    style: LiquidGlass.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confirmez votre position pour la traçabilité',
                    style: LiquidGlass.bodySecondary(),
                  ),
                  const SizedBox(height: 32),

                  // GPS Animation / Result
                  if (_isChecking) ...[
                    _GpsPing(controller: _pingCtrl),
                    const SizedBox(height: 24),
                    Text(
                      'Acquisition GPS...',
                      style: LiquidGlass.bodySecondary(),
                    ),
                  ] else if (_error != null) ...[
                    GlassCard(
                      borderColor: LiquidGlass.error.withValues(alpha: 0.40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 48,
                            color: LiquidGlass.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: LiquidGlass.body().copyWith(
                              color: LiquidGlass.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlassButton(
                            label: 'Réessayer',
                            icon: Icons.refresh,
                            onPressed: _checkLocation,
                          ),
                        ],
                      ),
                    ),
                  ] else if (_position != null) ...[
                    GlassCard(
                      borderColor: LiquidGlass.done.withValues(alpha: 0.40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: LiquidGlass.done,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Position vérifiée',
                            style: LiquidGlass.heading(
                              fontSize: 18,
                            ).copyWith(color: LiquidGlass.done),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: 'Latitude',
                            value: _position!.latitude.toStringAsFixed(6),
                          ),
                          _InfoRow(
                            label: 'Longitude',
                            value: _position!.longitude.toStringAsFixed(6),
                          ),
                          _InfoRow(
                            label: 'Précision',
                            value:
                                '${_position!.accuracy.toStringAsFixed(1)} m',
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Précédent',
                    isOutlined: true,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    label: 'Suivant',
                    onPressed: _position != null
                        ? () => context.push(
                            '/collection/${widget.missionId}/client',
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// GPS ping animation — 3 expanding circles
class _GpsPing extends StatelessWidget {
  final AnimationController controller;
  const _GpsPing({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children:
            List.generate(3, (i) {
              final delay = i * 0.33;
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final t = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: (1.0 - t).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: t * 3,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: LiquidGlass.accentBlue.withValues(
                              alpha: 0.50,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            })..add(
              Icon(Icons.my_location, color: LiquidGlass.accentBlue, size: 28),
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: LiquidGlass.label()),
          Text(value, style: LiquidGlass.body()),
        ],
      ),
    );
  }
}
