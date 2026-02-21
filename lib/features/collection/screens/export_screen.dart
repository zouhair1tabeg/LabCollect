import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final String missionId;

  const ExportScreen({super.key, required this.missionId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _selectedFormat = 'PDF';
  String _selectedDestination = 'Serveur';

  static const List<Map<String, dynamic>> _formats = [
    {'name': 'PDF', 'icon': Icons.picture_as_pdf, 'color': Color(0xFFEF9A9A)},
    {'name': 'Excel', 'icon': Icons.table_chart, 'color': Color(0xFFA5D6A7)},
    {'name': 'CSV', 'icon': Icons.description, 'color': Color(0xFF4FC3F7)},
    {'name': 'JSON', 'icon': Icons.data_object, 'color': Color(0xFFFFB74D)},
  ];

  static const List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Serveur',
      'icon': Icons.cloud_upload,
      'desc': 'Upload vers le serveur central',
    },
    {'name': 'Email', 'icon': Icons.email, 'desc': 'Envoyer par email'},
    {
      'name': 'Local',
      'icon': Icons.phone_android,
      'desc': 'Sauvegarder sur l\'appareil',
    },
  ];

  @override
  void initState() {
    super.initState();
    final data = ref.read(collectionProvider(widget.missionId));
    _selectedFormat = data.exportInfo?.format ?? 'PDF';
    _selectedDestination = data.exportInfo?.destination ?? 'Serveur';
  }

  void _saveAndNext() {
    ref
        .read(collectionProvider(widget.missionId).notifier)
        .setExportInfo(
          format: _selectedFormat,
          destination: _selectedDestination,
        );
    context.push('/collection/${widget.missionId}/review');
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Export',
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 7),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Options d\'Export',
                    style: LiquidGlass.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choisissez le format et la destination',
                    style: LiquidGlass.bodySecondary(),
                  ),
                  const SizedBox(height: 24),

                  Text('FORMAT DE FICHIER', style: LiquidGlass.label()),
                  const SizedBox(height: 12),
                  Row(
                    children: _formats.map((format) {
                      final isSelected = _selectedFormat == format['name'];
                      final color = format['color'] as Color;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedFormat = format['name'] as String,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Colors.white.withValues(alpha: 0.10),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    format['icon'] as IconData,
                                    color: color,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    format['name'] as String,
                                    style: LiquidGlass.body(fontSize: 12)
                                        .copyWith(
                                          color: isSelected
                                              ? color
                                              : LiquidGlass.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  Text('DESTINATION', style: LiquidGlass.label()),
                  const SizedBox(height: 12),
                  ...(_destinations).map((dest) {
                    final isSelected = _selectedDestination == dest['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedDestination = dest['name'] as String,
                        ),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: isSelected
                              ? LiquidGlass.accentBlue.withValues(alpha: 0.50)
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                dest['icon'] as IconData,
                                color: isSelected
                                    ? LiquidGlass.accentBlue
                                    : LiquidGlass.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dest['name'] as String,
                                      style: LiquidGlass.body().copyWith(
                                        color: isSelected
                                            ? LiquidGlass.accentBlue
                                            : LiquidGlass.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      dest['desc'] as String,
                                      style: LiquidGlass.bodySecondary(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: LiquidGlass.accentBlue,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
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
