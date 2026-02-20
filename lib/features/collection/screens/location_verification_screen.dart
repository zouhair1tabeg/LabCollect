import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../shared/widgets/step_progress_indicator.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/collection_provider.dart';

class LocationVerificationScreen extends ConsumerStatefulWidget {
  final String missionId;

  const LocationVerificationScreen({super.key, required this.missionId});

  @override
  ConsumerState<LocationVerificationScreen> createState() =>
      _LocationVerificationScreenState();
}

class _LocationVerificationScreenState
    extends ConsumerState<LocationVerificationScreen> {
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Les services de localisation sont désactivés.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permission de localisation refusée.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Permission de localisation refusée définitivement. Modifiez les paramètres.';
          _isLoading = false;
        });
        return;
      }

      // Get location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Save to provider
      ref
          .read(collectionProvider(widget.missionId).notifier)
          .setLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
    } catch (e) {
      setState(() {
        _error = 'Erreur de localisation: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collectionData = ref.watch(collectionProvider(widget.missionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Localisation')),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vérification GPS',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confirmez votre position pour cette collecte',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Location status
                  if (_isLoading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Recherche de localisation GPS...'),
                        ],
                      ),
                    )
                  else if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_currentPosition != null)
                    _LocationInfoCard(
                      latitude: _currentPosition!.latitude,
                      longitude: _currentPosition!.longitude,
                      accuracy: _currentPosition!.accuracy,
                    ),

                  const Spacer(),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CustomButton(
                        label: 'Réessayer',
                        icon: Icons.refresh,
                        isOutlined: true,
                        width: double.infinity,
                        onPressed: _checkLocation,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Précédent'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: collectionData.location != null
                        ? () => context.push(
                            '/collection/${widget.missionId}/client',
                          )
                        : null,
                    child: const Text('Suivant'),
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

class _LocationInfoCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracy;

  const _LocationInfoCard({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          Text(
            'Position vérifiée',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Latitude', value: latitude.toStringAsFixed(6)),
          _InfoRow(label: 'Longitude', value: longitude.toStringAsFixed(6)),
          _InfoRow(
            label: 'Précision',
            value: '±${accuracy.toStringAsFixed(1)} m',
          ),
        ],
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
