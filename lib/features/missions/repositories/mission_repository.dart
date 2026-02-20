import '../../../core/constants/app_constants.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/storage_service.dart';

/// Repository handling mission data from API and local cache
class MissionRepository {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  /// Fetch missions from API and cache locally
  Future<List<MissionModel>> fetchMissions() async {
    try {
      final response = await _api.get('/missions');
      final List<dynamic> data = response.data as List<dynamic>;
      final missions = data.map((json) => MissionModel.fromJson(json)).toList();

      // Cache locally
      for (final mission in missions) {
        await _storage.saveMission(mission);
      }

      return missions;
    } catch (_) {
      // Fallback to local cache
      return _storage.getAllMissions();
    }
  }

  /// Get a single mission by ID
  Future<MissionModel?> getMission(String id) async {
    try {
      final response = await _api.get('/missions/$id');
      final mission = MissionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _storage.saveMission(mission);
      return mission;
    } catch (_) {
      return _storage.getMission(id);
    }
  }

  /// Update mission on server + local cache
  Future<void> updateMission(MissionModel mission) async {
    await _storage.saveMission(mission);
    try {
      await _api.put('/missions/${mission.id}', data: mission.toJson());
    } catch (_) {
      // Will sync later
    }
  }

  /// Get locally cached missions
  List<MissionModel> getCachedMissions() {
    return _storage.getAllMissions();
  }

  /// Generate demo missions for development
  List<MissionModel> getDemoMissions() {
    return [
      MissionModel(
        id: 'mission_001',
        title: 'Analyse Eau - Station Nord',
        description: 'Prélèvement et analyse des échantillons d\'eau potable',
        status: MissionStatus.pending,
        assignedTo: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MissionModel(
        id: 'mission_002',
        title: 'Contrôle Sol - Parcelle A12',
        description: 'Analyse de la composition du sol agricole',
        status: MissionStatus.inProgress,
        assignedTo: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        currentStepIndex: 3,
      ),
      MissionModel(
        id: 'mission_003',
        title: 'Analyse Air - Zone Industrielle',
        description: 'Mesure de la qualité de l\'air ambiant',
        status: MissionStatus.completed,
        assignedTo: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      MissionModel(
        id: 'mission_004',
        title: 'Analyse Alimentaire - Lot 2024-B',
        description: 'Contrôle qualité des produits alimentaires',
        status: MissionStatus.pending,
        assignedTo: '1',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
}
