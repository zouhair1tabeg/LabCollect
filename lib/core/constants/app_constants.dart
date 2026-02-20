/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.labcollect.example.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Hive Box Names
  static const String authBox = 'auth';
  static const String missionsBox = 'missions';
  static const String offlineQueueBox = 'offline_queue';
  static const String collectionDataBox = 'collection_data';
  static const String syncQueueBox = 'sync_queue';

  // Auth Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Secure Storage Keys
  static const String secureTokenKey = 'secure_token';
  static const String secureUserKey = 'secure_user';
}

/// Enum representing mission statuses
enum MissionStatus {
  pending('En attente'),
  inProgress('En cours'),
  completed('Terminée');

  const MissionStatus(this.label);
  final String label;
}

/// Enum representing sync queue item statuses
enum SyncStatus {
  pending('En attente'),
  syncing('Synchronisation'),
  synced('Synchronisé'),
  failed('Échoué');

  const SyncStatus(this.label);
  final String label;
}

/// Enum representing each step in the collection flow
enum CollectionStep {
  categorySelection(0, 'Catégorie'),
  locationVerification(1, 'Localisation'),
  clientInfo(2, 'Client'),
  productInfo(3, 'Produit'),
  sampleDetails(4, 'Échantillon'),
  analysisRequirements(5, 'Analyse'),
  documentation(6, 'Documentation'),
  exportInfo(7, 'Export'),
  finalReview(8, 'Révision'),
  completion(9, 'Complétion');

  const CollectionStep(this.stepIndex, this.label);
  final int stepIndex;
  final String label;

  static CollectionStep fromStepIndex(int idx) {
    return CollectionStep.values.firstWhere((s) => s.stepIndex == idx);
  }

  static int get totalSteps => CollectionStep.values.length;
}
