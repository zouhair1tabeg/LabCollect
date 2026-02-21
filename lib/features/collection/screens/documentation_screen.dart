import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_input.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/step_progress_indicator.dart';
import '../providers/collection_provider.dart';

class DocumentationScreen extends ConsumerStatefulWidget {
  final String missionId;

  const DocumentationScreen({super.key, required this.missionId});

  @override
  ConsumerState<DocumentationScreen> createState() =>
      _DocumentationScreenState();
}

class _DocumentationScreenState extends ConsumerState<DocumentationScreen> {
  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        ref
            .read(collectionProvider(widget.missionId).notifier)
            .addPhoto(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur photo: $e')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      for (final img in images) {
        if (mounted) {
          ref
              .read(collectionProvider(widget.missionId).notifier)
              .addPhoto(img.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur galerie: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionData = ref.watch(collectionProvider(widget.missionId));
    final photos = collectionData.documentation?.photos ?? [];

    return GlassScaffold(
      title: 'Documentation',
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 6),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documentation Photo',
                    style: LiquidGlass.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prenez des photos de l\'échantillon et du site',
                    style: LiquidGlass.bodySecondary(),
                  ),
                  const SizedBox(height: 24),

                  // Photo buttons
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Caméra',
                          icon: Icons.camera_alt,
                          isOutlined: true,
                          onPressed: _takePhoto,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassButton(
                          label: 'Galerie',
                          icon: Icons.photo_library,
                          isOutlined: true,
                          onPressed: _pickFromGallery,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Photo grid
                  if (photos.isEmpty)
                    GlassCard(
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune photo ajoutée',
                              style: LiquidGlass.bodySecondary(),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(photos[index]),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx1, err, stack) => Container(
                                  color: LiquidGlass.inputFill,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: LiquidGlass.textSecondary,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(
                                          collectionProvider(
                                            widget.missionId,
                                          ).notifier,
                                        )
                                        .removePhoto(index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Notes
                  GlassInput(
                    controller: TextEditingController(
                      text: collectionData.documentation?.notes ?? '',
                    ),
                    maxLines: 4,
                    labelText: 'Notes de documentation',
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
                    onPressed: () =>
                        context.push('/collection/${widget.missionId}/export'),
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
