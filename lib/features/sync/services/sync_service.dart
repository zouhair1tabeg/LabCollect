import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/sync_queue_model.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/connectivity_service.dart';

/// Service managing data synchronization with exponential backoff retry
class SyncService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final ConnectivityService _connectivity = ConnectivityService();

  StreamSubscription? _connectivitySub;
  Timer? _retryTimer;
  bool _isSyncing = false;

  /// Start listening for connectivity changes to auto-sync
  void startBackgroundSync() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final online = !results.any((r) => r == ConnectivityResult.none);
      if (online && !_isSyncing) {
        processQueue();
      }
    });
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _connectivitySub?.cancel();
    _retryTimer?.cancel();
  }

  /// Attempt to sync a completed mission
  Future<bool> syncMission(String missionId) async {
    final mission = _storage.getMission(missionId);
    if (mission == null) return false;

    final isOnline = await _connectivity.isOnline;
    if (!isOnline) {
      await queueForSync(missionId, mission.toJson());
      return false;
    }

    try {
      await _api.post('/missions/$missionId/complete', data: mission.toJson());
      return true;
    } catch (e) {
      await queueForSync(missionId, mission.toJson());
      return false;
    }
  }

  /// Add to sync queue
  Future<void> queueForSync(String missionId, Map<String, dynamic> data) async {
    final item = SyncQueueModel(
      id: '${missionId}_${DateTime.now().millisecondsSinceEpoch}',
      missionId: missionId,
      data: data,
      createdAt: DateTime.now(),
    );
    await _storage.addToSyncQueue(item);
  }

  /// Process all pending items in the queue with exponential backoff
  Future<SyncResult> processQueue() async {
    if (_isSyncing) return SyncResult(total: 0, synced: 0, failed: 0);

    final isOnline = await _connectivity.isOnline;
    if (!isOnline) {
      return SyncResult(total: _storage.syncQueueCount, synced: 0, failed: 0);
    }

    _isSyncing = true;
    final pending = _storage.getPendingSyncItems();
    int synced = 0;
    int failed = 0;

    for (final item in pending) {
      // Update status to syncing
      final syncing = item.copyWith(status: SyncStatus.syncing);
      await _storage.updateSyncQueueItem(syncing);

      try {
        await _api.post(
          '/sync/upload',
          data: {'missionId': item.missionId, 'data': item.data},
        );

        // Success — mark as synced
        final completed = item.copyWith(status: SyncStatus.synced);
        await _storage.updateSyncQueueItem(completed);
        synced++;
      } catch (e) {
        // Fail — increment attempts and calculate backoff
        final newAttempts = item.attempts + 1;

        if (newAttempts >= 5) {
          // Max attempts reached — mark as failed
          final failedItem = item.copyWith(
            status: SyncStatus.failed,
            attempts: newAttempts,
          );
          await _storage.updateSyncQueueItem(failedItem);
        } else {
          // Set back to pending with incremented attempts
          final retry = item.copyWith(
            status: SyncStatus.pending,
            attempts: newAttempts,
          );
          await _storage.updateSyncQueueItem(retry);

          // Schedule retry with exponential backoff
          final delaySeconds = min(pow(2, newAttempts).toInt(), 60);
          _retryTimer?.cancel();
          _retryTimer = Timer(
            Duration(seconds: delaySeconds),
            () => processQueue(),
          );
        }
        failed++;
      }
    }

    _isSyncing = false;

    return SyncResult(total: pending.length, synced: synced, failed: failed);
  }

  /// Retry all failed items
  Future<void> retryFailed() async {
    final allItems = _storage.getAllSyncQueueItems();
    for (final item in allItems) {
      if (item.status == SyncStatus.failed) {
        final reset = item.copyWith(status: SyncStatus.pending, attempts: 0);
        await _storage.updateSyncQueueItem(reset);
      }
    }
    await processQueue();
  }

  /// Clear completed items
  Future<void> clearCompleted() async {
    final allItems = _storage.getAllSyncQueueItems();
    for (final item in allItems) {
      if (item.status == SyncStatus.synced) {
        await _storage.removeSyncQueueItem(item.id);
      }
    }
  }

  /// Get count of items awaiting sync
  int get pendingCount => _storage.syncQueueCount;

  /// Get all queue items
  List<SyncQueueModel> get allItems => _storage.getAllSyncQueueItems();
}

/// Result of a sync operation
class SyncResult {
  final int total;
  final int synced;
  final int failed;

  const SyncResult({
    required this.total,
    required this.synced,
    required this.failed,
  });
}
