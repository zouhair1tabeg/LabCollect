import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/collection_data_model.dart';
import '../../../shared/services/storage_service.dart';

/// Manages the state of an active data collection flow
class CollectionNotifier extends StateNotifier<CollectionDataModel> {
  final StorageService _storage = StorageService();
  final String missionId;

  CollectionNotifier(this.missionId) : super(const CollectionDataModel()) {
    _loadDraft();
  }

  void _loadDraft() {
    final draft = _storage.getCollectionDraft(missionId);
    if (draft != null) {
      state = CollectionDataModel.fromJson(draft);
    }
  }

  Future<void> _saveDraft() async {
    await _storage.saveCollectionDraft(missionId, state.toJson());
  }

  // Step 1: Category
  void setCategory(String category) {
    state = state.copyWith(category: category);
    _saveDraft();
  }

  // Step 2: Location
  void setLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) {
    state = state.copyWith(
      location: LocationData(
        lat: latitude,
        lng: longitude,
        accuracy: accuracy,
        timestamp: DateTime.now(),
      ),
    );
    _saveDraft();
  }

  // Step 3: Client Info
  void setClientInfo({
    required String nom,
    String? contact,
    String? adresse,
    String? reference,
  }) {
    state = state.copyWith(
      clientInfo: ClientInfo(
        nom: nom,
        contact: contact,
        adresse: adresse,
        reference: reference,
      ),
    );
    _saveDraft();
  }

  // Step 4: Product Info
  void setProductInfo({
    required String nom,
    String? code,
    String? lot,
    DateTime? dateExpiration,
    String? fabricant,
  }) {
    state = state.copyWith(
      productInfo: ProductInfo(
        nom: nom,
        code: code,
        lot: lot,
        dateExpiration: dateExpiration,
        fabricant: fabricant,
      ),
    );
    _saveDraft();
  }

  // Step 5: Sample Details
  void setSampleDetails({
    double? quantite,
    String? unite,
    String? conditionnement,
    double? temperature,
    String? observations,
  }) {
    state = state.copyWith(
      sampleDetails: SampleDetails(
        quantite: quantite,
        unite: unite,
        conditionnement: conditionnement,
        temperature: temperature,
        observations: observations,
      ),
    );
    _saveDraft();
  }

  // Step 6: Analysis Requirements
  void setAnalysisRequirements({
    required List<String> tests,
    String? priorite,
    String? delai,
    String? labDestination,
  }) {
    state = state.copyWith(
      analysisRequirements: AnalysisRequirements(
        tests: tests,
        priorite: priorite,
        delai: delai,
        labDestination: labDestination,
      ),
    );
    _saveDraft();
  }

  // Step 7: Documentation
  void addPhoto(String path) {
    final current = state.documentation ?? const Documentation();
    state = state.copyWith(
      documentation: current.copyWith(photos: [...current.photos, path]),
    );
    _saveDraft();
  }

  void removePhoto(int index) {
    final current = state.documentation ?? const Documentation();
    final photos = List<String>.from(current.photos);
    photos.removeAt(index);
    state = state.copyWith(documentation: current.copyWith(photos: photos));
    _saveDraft();
  }

  void addDocument(String path) {
    final current = state.documentation ?? const Documentation();
    state = state.copyWith(
      documentation: current.copyWith(documents: [...current.documents, path]),
    );
    _saveDraft();
  }

  void setDocumentationNotes(String notes) {
    final current = state.documentation ?? const Documentation();
    state = state.copyWith(documentation: current.copyWith(notes: notes));
    _saveDraft();
  }

  // Step 8: Export
  void setExportInfo({String? format, String? destination}) {
    state = state.copyWith(
      exportInfo: ExportInfo(
        format: format,
        destination: destination,
        timestamp: DateTime.now(),
      ),
    );
    _saveDraft();
  }

  // Public save draft for external callers (e.g., autosave)
  Future<void> saveDraftPublic() async {
    await _saveDraft();
  }

  // Clear draft after completion
  Future<void> clearDraft() async {
    await _storage.deleteCollectionDraft(missionId);
  }
}

// ── Provider ────────────────────────────────────────────

/// Family provider keyed by missionId
final collectionProvider =
    StateNotifierProvider.family<
      CollectionNotifier,
      CollectionDataModel,
      String
    >((ref, missionId) => CollectionNotifier(missionId));
