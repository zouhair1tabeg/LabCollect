import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/sync_queue_model.dart';

import '../services/sync_service.dart';

// ── Sync Status State ───────────────────────────────────

enum SyncUiStatus { idle, syncing, success, error }

class SyncState {
  final List<SyncQueueModel> items;
  final SyncUiStatus uiStatus;
  final String? message;
  final DateTime? lastSyncTime;

  const SyncState({
    this.items = const [],
    this.uiStatus = SyncUiStatus.idle,
    this.message,
    this.lastSyncTime,
  });

  int get pendingCount =>
      items.where((i) => i.status == SyncStatus.pending).length;
  int get syncedCount =>
      items.where((i) => i.status == SyncStatus.synced).length;
  int get failedCount =>
      items.where((i) => i.status == SyncStatus.failed).length;

  SyncState copyWith({
    List<SyncQueueModel>? items,
    SyncUiStatus? uiStatus,
    String? message,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      items: items ?? this.items,
      uiStatus: uiStatus ?? this.uiStatus,
      message: message,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

// ── Sync Notifier ───────────────────────────────────────

class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;

  SyncNotifier(this._syncService) : super(const SyncState()) {
    refresh();
    _syncService.startBackgroundSync();
  }

  /// Refresh queue items from storage
  void refresh() {
    final items = _syncService.allItems;
    state = state.copyWith(items: items);
  }

  /// Trigger manual sync
  Future<void> syncNow() async {
    state = state.copyWith(uiStatus: SyncUiStatus.syncing, message: null);

    try {
      final result = await _syncService.processQueue();
      refresh();

      if (result.failed > 0) {
        state = state.copyWith(
          uiStatus: SyncUiStatus.error,
          message:
              '${result.synced} synchronisé(s), ${result.failed} échoué(s)',
          lastSyncTime: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          uiStatus: SyncUiStatus.success,
          message: '${result.synced} élément(s) synchronisé(s)',
          lastSyncTime: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        uiStatus: SyncUiStatus.error,
        message: 'Erreur de synchronisation',
      );
    }
  }

  /// Retry all failed items
  Future<void> retryFailed() async {
    state = state.copyWith(uiStatus: SyncUiStatus.syncing);
    await _syncService.retryFailed();
    refresh();
    state = state.copyWith(
      uiStatus: SyncUiStatus.idle,
      lastSyncTime: DateTime.now(),
    );
  }

  /// Clear completed items
  Future<void> clearCompleted() async {
    await _syncService.clearCompleted();
    refresh();
  }

  @override
  void dispose() {
    _syncService.stopBackgroundSync();
    super.dispose();
  }
}

// ── Providers ───────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref.read(syncServiceProvider));
});

/// Provider for pending sync count (for badge display)
final pendingSyncCountProvider = Provider<int>((ref) {
  return ref.watch(syncProvider).pendingCount;
});
