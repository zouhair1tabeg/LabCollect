import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    {'name': 'PDF', 'icon': Icons.picture_as_pdf, 'color': Color(0xFFE53935)},
    {'name': 'Excel', 'icon': Icons.table_chart, 'color': Color(0xFF43A047)},
    {'name': 'CSV', 'icon': Icons.description, 'color': Color(0xFF1E88E5)},
    {'name': 'JSON', 'icon': Icons.data_object, 'color': Color(0xFFF57C00)},
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez le format et la destination',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Format selection
                  Text('Format de fichier', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: _formats.map((format) {
                      final isSelected = _selectedFormat == format['name'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  format['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.white
                                      : format['color'] as Color,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  format['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(
                                  () => _selectedFormat =
                                      format['name'] as String,
                                );
                              }
                            },
                            selectedColor: format['color'] as Color,
                            padding: const EdgeInsets.all(12),
                            showCheckmark: false,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Destination selection
                  Text('Destination', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  ...(_destinations).map((dest) {
                    final isSelected = _selectedDestination == dest['name'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: Icon(
                          dest['icon'] as IconData,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        title: Text(dest['name'] as String),
                        subtitle: Text(dest['desc'] as String),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          setState(
                            () => _selectedDestination = dest['name'] as String,
                          );
                        },
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
