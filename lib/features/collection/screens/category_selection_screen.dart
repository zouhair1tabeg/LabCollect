import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class CategorySelectionScreen extends ConsumerWidget {
  final String missionId;

  const CategorySelectionScreen({super.key, required this.missionId});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Eau', 'icon': Icons.water_drop, 'color': Color(0xFF2196F3)},
    {'name': 'Sol', 'icon': Icons.terrain, 'color': Color(0xFF795548)},
    {'name': 'Air', 'icon': Icons.air, 'color': Color(0xFF90CAF9)},
    {
      'name': 'Alimentaire',
      'icon': Icons.restaurant,
      'color': Color(0xFFFF9800),
    },
    {'name': 'Biologique', 'icon': Icons.biotech, 'color': Color(0xFF4CAF50)},
    {'name': 'Chimique', 'icon': Icons.science, 'color': Color(0xFF9C27B0)},
    {'name': 'Matériaux', 'icon': Icons.build, 'color': Color(0xFF607D8B)},
    {'name': 'Environnemental', 'icon': Icons.eco, 'color': Color(0xFF00BCD4)},
    {'name': 'Autre', 'icon': Icons.more_horiz, 'color': Color(0xFF9E9E9E)},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionData = ref.watch(collectionProvider(missionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Catégorie')),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sélectionnez la catégorie d\'analyse',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez le type d\'analyse correspondant à cette mission',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected =
                            collectionData.category == category['name'];

                        return _CategoryTile(
                          name: category['name'] as String,
                          icon: category['icon'] as IconData,
                          color: category['color'] as Color,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(collectionProvider(missionId).notifier)
                                .setCategory(category['name'] as String);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Next button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: collectionData.category != null
                    ? () => context.push('/collection/$missionId/location')
                    : null,
                child: const Text('Suivant'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.15)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
