import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class FinalReviewScreen extends ConsumerWidget {
  final String missionId;

  const FinalReviewScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(collectionProvider(missionId));

    return GlassScaffold(
      title: 'Révision Finale',
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
                    style: LiquidGlass.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vérifiez les informations avant validation',
                    style: LiquidGlass.bodySecondary(),
                  ),
                  const SizedBox(height: 24),

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
                  child: GlassButton(
                    label: 'Précédent',
                    isOutlined: true,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    label: 'Valider & Terminer',
                    accentColor: LiquidGlass.done,
                    onPressed: () =>
                        context.push('/collection/$missionId/completion'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: LiquidGlass.accentBlue),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: LiquidGlass.label().copyWith(
                    color: LiquidGlass.accentBlue,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.white.withValues(alpha: 0.10), height: 20),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        item.label,
                        style: LiquidGlass.bodySecondary(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: LiquidGlass.body(fontSize: 14),
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
