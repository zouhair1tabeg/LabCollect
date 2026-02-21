import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class CategorySelectionScreen extends ConsumerWidget {
  final String missionId;

  const CategorySelectionScreen({super.key, required this.missionId});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Eau', 'icon': Icons.water_drop, 'color': Color(0xFF4FC3F7)},
    {'name': 'Sol', 'icon': Icons.terrain, 'color': Color(0xFFBCAAA4)},
    {'name': 'Air', 'icon': Icons.air, 'color': Color(0xFF90CAF9)},
    {
      'name': 'Alimentaire',
      'icon': Icons.restaurant,
      'color': Color(0xFFFFB74D),
    },
    {'name': 'Biologique', 'icon': Icons.biotech, 'color': Color(0xFF80CBC4)},
    {'name': 'Chimique', 'icon': Icons.science, 'color': Color(0xFFB39DDB)},
    {'name': 'Matériaux', 'icon': Icons.build, 'color': Color(0xFF90A4AE)},
    {'name': 'Environnemental', 'icon': Icons.eco, 'color': Color(0xFF80DEEA)},
    {'name': 'Autre', 'icon': Icons.more_horiz, 'color': Color(0xFF9E9E9E)},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionData = ref.watch(collectionProvider(missionId));

    return GlassScaffold(
      title: 'Catégorie',
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
                    'Sélectionnez la catégorie',
                    style: LiquidGlass.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Type d\'analyse pour cette mission',
                    style: LiquidGlass.bodySecondary(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Suivant',
                onPressed: collectionData.category != null
                    ? () => context.push('/collection/$missionId/location')
                    : null,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.20),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(
              name,
              style: LiquidGlass.body(fontSize: 11).copyWith(
                color: isSelected ? color : LiquidGlass.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
