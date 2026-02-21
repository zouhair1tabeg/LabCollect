import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_input.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class ProductInfoScreen extends ConsumerStatefulWidget {
  final String missionId;

  const ProductInfoScreen({super.key, required this.missionId});

  @override
  ConsumerState<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends ConsumerState<ProductInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _batchController;
  late final TextEditingController _originController;

  @override
  void initState() {
    super.initState();
    final data = ref.read(collectionProvider(widget.missionId));
    _nameController = TextEditingController(text: data.productInfo?.nom ?? '');
    _typeController = TextEditingController(text: data.productInfo?.code ?? '');
    _batchController = TextEditingController(text: data.productInfo?.lot ?? '');
    _originController = TextEditingController(
      text: data.productInfo?.fabricant ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _batchController.dispose();
    _originController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(collectionProvider(widget.missionId).notifier)
        .setProductInfo(
          nom: _nameController.text.trim(),
          code: _typeController.text.trim(),
          lot: _batchController.text.trim(),
          fabricant: _originController.text.trim(),
        );

    context.push('/collection/${widget.missionId}/sample');
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Informations Produit',
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du Produit',
                      style: LiquidGlass.heading(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Décrivez le produit à analyser',
                      style: LiquidGlass.bodySecondary(),
                    ),
                    const SizedBox(height: 24),
                    GlassInput(
                      controller: _nameController,
                      labelText: 'Nom du produit *',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _typeController,
                      labelText: 'Type de produit',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _batchController,
                      labelText: 'Numéro de lot',
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _originController,
                      labelText: 'Origine / Provenance',
                      prefixIcon: const Icon(Icons.public),
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
