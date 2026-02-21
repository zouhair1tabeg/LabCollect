import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_input.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class ClientInfoScreen extends ConsumerStatefulWidget {
  final String missionId;

  const ClientInfoScreen({super.key, required this.missionId});

  @override
  ConsumerState<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends ConsumerState<ClientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final data = ref.read(collectionProvider(widget.missionId));
    _nameController = TextEditingController(text: data.clientInfo?.nom ?? '');
    _phoneController = TextEditingController(
      text: data.clientInfo?.contact ?? '',
    );
    _emailController = TextEditingController(
      text: data.clientInfo?.reference ?? '',
    );
    _addressController = TextEditingController(
      text: data.clientInfo?.adresse ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(collectionProvider(widget.missionId).notifier)
        .setClientInfo(
          nom: _nameController.text.trim(),
          contact: _phoneController.text.trim(),
          reference: _emailController.text.trim(),
          adresse: _addressController.text.trim(),
        );

    context.push('/collection/${widget.missionId}/product');
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Informations Client',
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du Client',
                      style: LiquidGlass.heading(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Renseignez les coordonnées du client',
                      style: LiquidGlass.bodySecondary(),
                    ),
                    const SizedBox(height: 24),
                    GlassInput(
                      controller: _nameController,
                      labelText: 'Nom du client *',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      labelText: 'Téléphone',
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),
                    GlassInput(
                      controller: _addressController,
                      maxLines: 3,
                      labelText: 'Adresse',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      alignLabelWithHint: true,
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
