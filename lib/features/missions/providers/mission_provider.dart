import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/mission_model.dart';
import '../repositories/mission_repository.dart';

// ── Mission Filter ──────────────────────────────────────

enum MissionFilter { all, pending, inProgress, completed }

// ── Mission List State ──────────────────────────────────

class MissionListState {
  final List<MissionModel> missions;
  final bool isLoading;
  final String? error;
  final MissionFilter filter;

  const MissionListState({
    this.missions = const [],
    this.isLoading = false,
    this.error,
    this.filter = MissionFilter.all,
  });

  /// Filtered missions based on current filter
  List<MissionModel> get filteredMissions {
    switch (filter) {
      case MissionFilter.all:
        return missions;
      case MissionFilter.pending:
        return missions
            .where((m) => m.status == MissionStatus.pending)
            .toList();
      case MissionFilter.inProgress:
        return missions
            .where((m) => m.status == MissionStatus.inProgress)
            .toList();
      case MissionFilter.completed:
        return missions
            .where((m) => m.status == MissionStatus.completed)
            .toList();
    }
  }

  /// Badge counts per status
  int get pendingCount =>
      missions.where((m) => m.status == MissionStatus.pending).length;
  int get inProgressCount =>
      missions.where((m) => m.status == MissionStatus.inProgress).length;
  int get completedCount =>
      missions.where((m) => m.status == MissionStatus.completed).length;

  MissionListState copyWith({
    List<MissionModel>? missions,
    bool? isLoading,
    String? error,
    MissionFilter? filter,
  }) {
    return MissionListState(
      missions: missions ?? this.missions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

// ── Mission Notifier ────────────────────────────────────

class MissionNotifier extends StateNotifier<MissionListState> {
  final MissionRepository _repository;

  MissionNotifier(this._repository) : super(const MissionListState()) {
    loadMissions();
  }

  Future<void> loadMissions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final missions = await _repository.fetchMissions();
      if (missions.isEmpty) {
        state = MissionListState(
          missions: _repository.getDemoMissions(),
          filter: state.filter,
        );
      } else {
        state = MissionListState(missions: missions, filter: state.filter);
      }
    } catch (e) {
      state = MissionListState(
        missions: _repository.getDemoMissions(),
        filter: state.filter,
      );
    }
  }

  void setFilter(MissionFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> updateMission(MissionModel mission) async {
    await _repository.updateMission(mission);
    final updated = state.missions.map((m) {
      return m.id == mission.id ? mission : m;
    }).toList();
    state = state.copyWith(missions: updated);
  }

  Future<void> startMission(String missionId) async {
    final mission = state.missions.firstWhere((m) => m.id == missionId);
    final updated = mission.copyWith(
      status: MissionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
    await updateMission(updated);
  }

  Future<void> completeMission(String missionId) async {
    final mission = state.missions.firstWhere((m) => m.id == missionId);
    final updated = mission.copyWith(
      status: MissionStatus.completed,
      updatedAt: DateTime.now(),
    );
    await updateMission(updated);
  }

  void updateMissionStep(String missionId, int stepIndex) {
    final updated = state.missions.map((m) {
      if (m.id == missionId) {
        return m.copyWith(
          currentStepIndex: stepIndex,
          lastCompletedStep: stepIndex - 1,
          updatedAt: DateTime.now(),
        );
      }
      return m;
    }).toList();
    state = state.copyWith(missions: updated);
  }
}

// ── Providers ───────────────────────────────────────────

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository();
});

final missionProvider =
    StateNotifierProvider<MissionNotifier, MissionListState>((ref) {
      return MissionNotifier(ref.read(missionRepositoryProvider));
    });
