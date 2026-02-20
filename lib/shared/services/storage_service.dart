import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/mission_model.dart';
import '../models/sync_queue_model.dart';

/// Hive-based local storage service for missions, sync queue, and offline data
class StorageService {
  // ── Missions ──────────────────────────────────────────

  Box get _missionsBox => Hive.box(AppConstants.missionsBox);

  Future<void> saveMission(MissionModel mission) async {
    await _missionsBox.put(mission.id, jsonEncode(mission.toJson()));
  }

  MissionModel? getMission(String id) {
    final raw = _missionsBox.get(id);
    if (raw == null) return null;
    return MissionModel.fromJson(jsonDecode(raw as String));
  }

  List<MissionModel> getAllMissions() {
    return _missionsBox.values
        .map((raw) => MissionModel.fromJson(jsonDecode(raw as String)))
        .toList();
  }

  Future<void> deleteMission(String id) async {
    await _missionsBox.delete(id);
  }

  // ── Offline Queue ─────────────────────────────────────

  Box get _offlineBox => Hive.box(AppConstants.offlineQueueBox);

  Future<void> addToOfflineQueue(MissionModel mission) async {
    await _offlineBox.put(mission.id, jsonEncode(mission.toJson()));
  }

  List<MissionModel> getOfflineQueue() {
    return _offlineBox.values
        .map((raw) => MissionModel.fromJson(jsonDecode(raw as String)))
        .toList();
  }

  Future<void> removeFromOfflineQueue(String id) async {
    await _offlineBox.delete(id);
  }

  Future<void> clearOfflineQueue() async {
    await _offlineBox.clear();
  }

  int get offlineQueueCount => _offlineBox.length;

  // ── Sync Queue ────────────────────────────────────────

  Box get _syncQueueBox => Hive.box(AppConstants.syncQueueBox);

  Future<void> addToSyncQueue(SyncQueueModel item) async {
    await _syncQueueBox.put(item.id, jsonEncode(item.toJson()));
  }

  SyncQueueModel? getSyncQueueItem(String id) {
    final raw = _syncQueueBox.get(id);
    if (raw == null) return null;
    return SyncQueueModel.fromJson(jsonDecode(raw as String));
  }

  List<SyncQueueModel> getAllSyncQueueItems() {
    return _syncQueueBox.values
        .map((raw) => SyncQueueModel.fromJson(jsonDecode(raw as String)))
        .toList();
  }

  List<SyncQueueModel> getPendingSyncItems() {
    return getAllSyncQueueItems()
        .where((item) => item.status == SyncStatus.pending)
        .toList();
  }

  Future<void> updateSyncQueueItem(SyncQueueModel item) async {
    await _syncQueueBox.put(item.id, jsonEncode(item.toJson()));
  }

  Future<void> removeSyncQueueItem(String id) async {
    await _syncQueueBox.delete(id);
  }

  Future<void> clearSyncQueue() async {
    await _syncQueueBox.clear();
  }

  int get syncQueueCount => _syncQueueBox.length;

  // ── Auth ──────────────────────────────────────────────

  Box get _authBox => Hive.box(AppConstants.authBox);

  Future<void> saveToken(String token) async {
    await _authBox.put(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _authBox.get(AppConstants.tokenKey) as String?;
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _authBox.put(AppConstants.userKey, jsonEncode(userData));
  }

  Map<String, dynamic>? getUser() {
    final raw = _authBox.get(AppConstants.userKey);
    if (raw == null) return null;
    return jsonDecode(raw as String) as Map<String, dynamic>;
  }

  Future<void> clearAuth() async {
    await _authBox.clear();
  }

  // ── Collection Data ───────────────────────────────────

  Box get _collectionBox => Hive.box(AppConstants.collectionDataBox);

  Future<void> saveCollectionDraft(
    String missionId,
    Map<String, dynamic> data,
  ) async {
    await _collectionBox.put(missionId, jsonEncode(data));
  }

  Map<String, dynamic>? getCollectionDraft(String missionId) {
    final raw = _collectionBox.get(missionId);
    if (raw == null) return null;
    return jsonDecode(raw as String) as Map<String, dynamic>;
  }

  Future<void> deleteCollectionDraft(String missionId) async {
    await _collectionBox.delete(missionId);
  }
}
