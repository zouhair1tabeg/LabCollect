import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class SampleDetailsScreen extends ConsumerStatefulWidget {
  final String missionId;

  const SampleDetailsScreen({super.key, required this.missionId});

  @override
  ConsumerState<SampleDetailsScreen> createState() =>
      _SampleDetailsScreenState();
}

class _SampleDetailsScreenState extends ConsumerState<SampleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sampleIdController;
  late final TextEditingController _typeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _conditionController;
  String _selectedUnit = 'mL';
  DateTime _collectionDate = DateTime.now();

  static const List<String> _units = ['mL', 'L', 'g', 'kg', 'unité', 'cm³'];

  @override
  void initState() {
    super.initState();
    final data = ref.read(collectionProvider(widget.missionId));
    final sample = data.sampleDetails;
    _sampleIdController = TextEditingController(
      text: 'ECH-${const Uuid().v4().substring(0, 8).toUpperCase()}',
    );
    _typeController = TextEditingController(
      text: sample?.conditionnement ?? '',
    );
    _quantityController = TextEditingController(
      text: sample?.quantite?.toString() ?? '',
    );
    _conditionController = TextEditingController(
      text: sample?.observations ?? '',
    );
    _selectedUnit = sample?.unite ?? 'mL';
  }

  @override
  void dispose() {
    _sampleIdController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(collectionProvider(widget.missionId).notifier)
        .setSampleDetails(
          quantite: double.tryParse(_quantityController.text.trim()),
          unite: _selectedUnit,
          conditionnement: _typeController.text.trim(),
          temperature: null,
          observations: _conditionController.text.trim(),
        );

    context.push('/collection/${widget.missionId}/analysis');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Détails Échantillon')),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de l\'Échantillon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _sampleIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID Échantillon *',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Conditionnement',
                        prefixIcon: Icon(Icons.science_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantité',
                              prefixIcon: Icon(Icons.straighten),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unité',
                            ),
                            items: _units
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedUnit = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        labelText: 'Observations',
                        prefixIcon: Icon(Icons.thermostat),
                        hintText: 'Ex: Réfrigéré, Température ambiante...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date de collecte'),
                      subtitle: Text(
                        '${_collectionDate.day.toString().padLeft(2, '0')}/${_collectionDate.month.toString().padLeft(2, '0')}/${_collectionDate.year}',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _collectionDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _collectionDate = date);
                        }
                      },
                    ),
                  ],
                ),
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
                    onPressed: _saveAndNext,
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
