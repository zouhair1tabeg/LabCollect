import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Exigences Analyse')),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez les types d\'analyses requises',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Analysis types as chips
                  Text('Types d\'analyse', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _analysisTypes.map((type) {
                      final isSelected = _selectedTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTypes.add(type);
                            } else {
                              _selectedTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Priority
                  Text('Priorité', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
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

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes supplémentaires',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes),
                    ),
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
                    onPressed: _selectedTypes.isNotEmpty ? _saveAndNext : null,
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
