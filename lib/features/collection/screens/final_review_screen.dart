import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class FinalReviewScreen extends ConsumerWidget {
  final String missionId;

  const FinalReviewScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(collectionProvider(missionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Révision Finale')),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résumé de la Collecte',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérifiez les informations avant validation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sections
                  _ReviewSection(
                    title: 'Catégorie',
                    icon: Icons.category,
                    items: [_ReviewItem('Type', data.category ?? 'Non défini')],
                  ),

                  _ReviewSection(
                    title: 'Localisation',
                    icon: Icons.location_on,
                    items: [
                      _ReviewItem(
                        'Vérifiée',
                        data.location != null ? 'Oui ✓' : 'Non ✗',
                      ),
                      if (data.location?.lat != null)
                        _ReviewItem(
                          'Coordonnées',
                          '${data.location?.lat?.toStringAsFixed(4)}, ${data.location?.lng?.toStringAsFixed(4)}',
                        ),
                    ],
                  ),

                  _ReviewSection(
                    title: 'Client',
                    icon: Icons.person,
                    items: [
                      _ReviewItem('Nom', data.clientInfo?.nom ?? '-'),
                      _ReviewItem('Contact', data.clientInfo?.contact ?? '-'),
                      _ReviewItem('Adresse', data.clientInfo?.adresse ?? '-'),
                    ],
                  ),

                  _ReviewSection(
                    title: 'Produit',
                    icon: Icons.inventory_2,
                    items: [
                      _ReviewItem('Nom', data.productInfo?.nom ?? '-'),
                      _ReviewItem('Code', data.productInfo?.code ?? '-'),
                      _ReviewItem('Lot', data.productInfo?.lot ?? '-'),
                    ],
                  ),

                  _ReviewSection(
                    title: 'Échantillon',
                    icon: Icons.science,
                    items: [
                      if (data.sampleDetails?.quantite != null)
                        _ReviewItem(
                          'Quantité',
                          '${data.sampleDetails!.quantite} ${data.sampleDetails?.unite ?? ''}',
                        ),
                      _ReviewItem(
                        'Conditionnement',
                        data.sampleDetails?.conditionnement ?? '-',
                      ),
                    ],
                  ),

                  _ReviewSection(
                    title: 'Analyses',
                    icon: Icons.analytics,
                    items: [
                      _ReviewItem(
                        'Tests',
                        data.analysisRequirements?.tests.isNotEmpty == true
                            ? data.analysisRequirements!.tests.join(', ')
                            : '-',
                      ),
                      _ReviewItem(
                        'Priorité',
                        data.analysisRequirements?.priorite ?? '-',
                      ),
                    ],
                  ),

                  _ReviewSection(
                    title: 'Documentation',
                    icon: Icons.photo_camera,
                    items: [
                      _ReviewItem(
                        'Photos',
                        '${data.documentation?.photos.length ?? 0} fichier(s)',
                      ),
                    ],
                  ),

                  _ReviewSection(
                    title: 'Export',
                    icon: Icons.upload_file,
                    items: [
                      _ReviewItem('Format', data.exportInfo?.format ?? '-'),
                      _ReviewItem(
                        'Destination',
                        data.exportInfo?.destination ?? '-',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                    onPressed: () =>
                        context.push('/collection/$missionId/completion'),
                    child: const Text('Valider & Terminer'),
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

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_ReviewItem> items;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        item.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: theme.textTheme.bodyMedium,
                      ),
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

class _ReviewItem {
  final String label;
  final String value;

  const _ReviewItem(this.label, this.value);
}
