import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_input.dart';
import '../../../shared/widgets/glass_scaffold.dart';
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
    return GlassScaffold(
      title: 'Détails Échantillon',
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
                      style: LiquidGlass.heading(fontSize: 22),
                    ),
                    const SizedBox(height: 24),
                    GlassInput(
                      controller: _sampleIdController,
                      labelText: 'ID Échantillon *',
                      prefixIcon: const Icon(Icons.qr_code),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _typeController,
                      labelText: 'Conditionnement',
                      prefixIcon: const Icon(Icons.science_outlined),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GlassInput(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            labelText: 'Quantité',
                            prefixIcon: const Icon(Icons.straighten),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            dropdownColor: const Color(0xFF1A1A2E),
                            style: LiquidGlass.body(),
                            decoration: InputDecoration(
                              labelText: 'Unité',
                              labelStyle: LiquidGlass.bodySecondary(),
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
                    GlassInput(
                      controller: _conditionController,
                      labelText: 'Observations',
                      prefixIcon: const Icon(Icons.thermostat),
                      hintText: 'Ex: Réfrigéré, Température ambiante...',
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _collectionDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: LiquidGlass.accentBlue,
                                  surface: const Color(0xFF1A1A2E),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() => _collectionDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LiquidGlass.inputFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: LiquidGlass.inputBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: LiquidGlass.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE DE COLLECTE',
                                  style: LiquidGlass.label(),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_collectionDate.day.toString().padLeft(2, '0')}/${_collectionDate.month.toString().padLeft(2, '0')}/${_collectionDate.year}',
                                  style: LiquidGlass.body(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                  child: GlassButton(
                    label: 'Précédent',
                    isOutlined: true,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(label: 'Suivant', onPressed: _saveAndNext),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
