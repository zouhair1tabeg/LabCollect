import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Informations Produit')),
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Décrivez le produit à analyser',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit *',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Type de produit',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de lot',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _originController,
                      decoration: const InputDecoration(
                        labelText: 'Origine / Provenance',
                        prefixIcon: Icon(Icons.public),
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
