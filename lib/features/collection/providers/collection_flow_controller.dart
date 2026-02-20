import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../missions/providers/mission_provider.dart';
import 'collection_provider.dart';

// ── Flow State ──────────────────────────────────────────

class CollectionFlowState {
  final int currentStep;
  final int totalSteps;
  final bool isAutosaving;
  final DateTime? lastSaved;
  final String? validationError;

  const CollectionFlowState({
    this.currentStep = 0,
    this.totalSteps = 10,
    this.isAutosaving = false,
    this.lastSaved,
    this.validationError,
  });

  double get progress => (currentStep + 1) / totalSteps;
  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;

  CollectionFlowState copyWith({
    int? currentStep,
    int? totalSteps,
    bool? isAutosaving,
    DateTime? lastSaved,
    String? validationError,
  }) {
    return CollectionFlowState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isAutosaving: isAutosaving ?? this.isAutosaving,
      lastSaved: lastSaved ?? this.lastSaved,
      validationError: validationError,
    );
  }
}

// ── Flow Controller ─────────────────────────────────────

class CollectionFlowController extends StateNotifier<CollectionFlowState> {
  final String missionId;
  final Ref ref;
  Timer? _autosaveTimer;

  CollectionFlowController({
    required this.missionId,
    required this.ref,
    int initialStep = 0,
  }) : super(CollectionFlowState(currentStep: initialStep)) {
    _startAutosave();
  }

  // ── Autosave ────────────────────────────────────────

  void _startAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performAutosave(),
    );
  }

  Future<void> _performAutosave() async {
    state = state.copyWith(isAutosaving: true);
    try {
      await ref.read(collectionProvider(missionId).notifier).saveDraftPublic();
      state = state.copyWith(isAutosaving: false, lastSaved: DateTime.now());
    } catch (_) {
      state = state.copyWith(isAutosaving: false);
    }
  }

  // ── Navigation ──────────────────────────────────────

  /// Validate current step and advance to the next one
  bool goToNextStep() {
    final error = validateStep(state.currentStep);
    if (error != null) {
      state = state.copyWith(validationError: error);
      return false;
    }

    if (state.isLastStep) return false;

    final nextStep = state.currentStep + 1;
    state = state.copyWith(currentStep: nextStep, validationError: null);

    // Update mission progress
    ref.read(missionProvider.notifier).updateMissionStep(missionId, nextStep);

    // Save draft on step change
    _performAutosave();

    return true;
  }

  /// Go back to previous step
  bool goToPreviousStep() {
    if (state.isFirstStep) return false;

    state = state.copyWith(
      currentStep: state.currentStep - 1,
      validationError: null,
    );
    return true;
  }

  /// Jump directly to a step (for resuming)
  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step, validationError: null);
    }
  }

  // ── Validation ──────────────────────────────────────

  /// Validate a specific step. Returns null if valid, error message otherwise.
  String? validateStep(int step) {
    final data = ref.read(collectionProvider(missionId));

    switch (step) {
      case 0: // Category
        if (data.category == null || data.category!.isEmpty) {
          return 'Veuillez sélectionner une catégorie';
        }
        return null;

      case 1: // Location
        if (data.location == null) {
          return 'Veuillez vérifier votre position GPS';
        }
        if (data.location!.accuracy != null && data.location!.accuracy! > 50) {
          return 'La précision GPS doit être inférieure à 50m';
        }
        return null;

      case 2: // Client
        final nom = data.clientInfo?.nom;
        if (nom == null || nom.isEmpty) {
          return 'Le nom du client est requis';
        }
        return null;

      case 3: // Product
        final nom = data.productInfo?.nom;
        if (nom == null || nom.isEmpty) {
          return 'Le nom du produit est requis';
        }
        return null;

      case 4: // Sample
        return null; // Optional fields

      case 5: // Analysis
        if (data.analysisRequirements == null ||
            data.analysisRequirements!.tests.isEmpty) {
          return 'Sélectionnez au moins un type d\'analyse';
        }
        return null;

      case 6: // Documentation
        return null; // Optional

      case 7: // Export
        return null; // Has defaults

      case 8: // Review
        return null; // Read-only

      default:
        return null;
    }
  }

  /// Check if all steps up to a given step are valid
  bool areStepsValidUpTo(int step) {
    for (int i = 0; i <= step; i++) {
      if (validateStep(i) != null) return false;
    }
    return true;
  }

  /// Manual save trigger
  Future<void> saveNow() async {
    await _performAutosave();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ────────────────────────────────────────────

final collectionFlowProvider =
    StateNotifierProvider.family<
      CollectionFlowController,
      CollectionFlowState,
      String
    >((ref, missionId) {
      // Determine initial step from mission's lastCompletedStep
      final missionState = ref.read(missionProvider);
      final mission = missionState.missions
          .where((m) => m.id == missionId)
          .firstOrNull;
      final initialStep = mission != null
          ? (mission.lastCompletedStep + 1).clamp(
              0,
              CollectionStep.totalSteps - 1,
            )
          : 0;

      return CollectionFlowController(
        missionId: missionId,
        ref: ref,
        initialStep: initialStep,
      );
    });
