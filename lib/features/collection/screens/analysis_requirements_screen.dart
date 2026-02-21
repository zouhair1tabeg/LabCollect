import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_input.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class AnalysisRequirementsScreen extends ConsumerStatefulWidget {
  final String missionId;

  const AnalysisRequirementsScreen({super.key, required this.missionId});

  @override
  ConsumerState<AnalysisRequirementsScreen> createState() =>
      _AnalysisRequirementsScreenState();
}

class _AnalysisRequirementsScreenState
    extends ConsumerState<AnalysisRequirementsScreen> {
  late List<String> _selectedTypes;
  String _priority = 'Normal';
  late final TextEditingController _notesController;

  static const List<String> _analysisTypes = [
    'Microbiologique',
    'Physico-chimique',
    'Toxicologique',
    'Organoleptique',
    'Radiologique',
    'Nutritionnel',
    'Contaminants',
    'Métaux lourds',
    'Pesticides',
    'Allergènes',
  ];

  static const List<String> _priorities = ['Urgent', 'Élevé', 'Normal', 'Bas'];

  @override
  void initState() {
    super.initState();
    final data = ref.read(collectionProvider(widget.missionId));
    _selectedTypes = List<String>.from(data.analysisRequirements?.tests ?? []);
    _priority = data.analysisRequirements?.priorite ?? 'Normal';
    _notesController = TextEditingController(
      text: data.analysisRequirements?.delai ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    ref
        .read(collectionProvider(widget.missionId).notifier)
        .setAnalysisRequirements(
          tests: _selectedTypes,
          priorite: _priority,
          delai: _notesController.text.trim(),
        );

    context.push('/collection/${widget.missionId}/documentation');
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Exigences Analyse',
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 5),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exigences d\'Analyse',
                    style: LiquidGlass.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sélectionnez les types d\'analyses requises',
                    style: LiquidGlass.bodySecondary(),
                  ),
                  const SizedBox(height: 24),

                  Text('TYPES D\'ANALYSE', style: LiquidGlass.label()),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _analysisTypes.map((type) {
                      final isSelected = _selectedTypes.contains(type);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTypes.remove(type);
                            } else {
                              _selectedTypes.add(type);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? LiquidGlass.accentBlue.withValues(alpha: 0.20)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? LiquidGlass.accentBlue.withValues(
                                      alpha: 0.50,
                                    )
                                  : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            type,
                            style: LiquidGlass.body(fontSize: 13).copyWith(
                              color: isSelected
                                  ? LiquidGlass.accentBlue
                                  : LiquidGlass.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  Text('PRIORITÉ', style: LiquidGlass.label()),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: _priorities.map((p) {
                      return ButtonSegment(value: p, label: Text(p));
                    }).toList(),
                    selected: {_priority},
                    onSelectionChanged: (selected) {
                      setState(() => _priority = selected.first);
                    },
                  ),

                  const SizedBox(height: 24),

                  GlassInput(
                    controller: _notesController,
                    maxLines: 4,
                    labelText: 'Notes supplémentaires',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes),
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
                    label: 'Suivant',
                    onPressed: _selectedTypes.isNotEmpty ? _saveAndNext : null,
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
