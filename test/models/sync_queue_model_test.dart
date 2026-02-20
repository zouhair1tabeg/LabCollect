import 'package:flutter_test/flutter_test.dart';
import 'package:labocollect/core/constants/app_constants.dart';
import 'package:labocollect/shared/models/sync_queue_model.dart';

void main() {
  group('SyncQueueModel', () {
    final now = DateTime(2024, 6, 15, 10, 30);

    test('fromJson creates correct model', () {
      final json = {
        'id': 'sync-1',
        'missionId': 'mission-1',
        'data': {'key': 'value'},
        'createdAt': now.toIso8601String(),
        'attempts': 2,
        'status': 'syncing',
      };

      final item = SyncQueueModel.fromJson(json);

      expect(item.id, 'sync-1');
      expect(item.missionId, 'mission-1');
      expect(item.data, {'key': 'value'});
      expect(item.attempts, 2);
      expect(item.status, SyncStatus.syncing);
    });

    test('fromJson uses defaults for optional fields', () {
      final json = {
        'id': 'sync-1',
        'missionId': 'mission-1',
        'data': <String, dynamic>{},
        'createdAt': now.toIso8601String(),
      };

      final item = SyncQueueModel.fromJson(json);

      expect(item.attempts, 0);
      expect(item.status, SyncStatus.pending);
    });

    test('round-trip serialization preserves data', () {
      final original = SyncQueueModel(
        id: 'sync-1',
        missionId: 'mission-1',
        data: {'test': 123},
        createdAt: now,
        attempts: 3,
        status: SyncStatus.failed,
      );

      final roundTripped = SyncQueueModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.missionId, original.missionId);
      expect(roundTripped.attempts, 3);
      expect(roundTripped.status, SyncStatus.failed);
    });

    test('copyWith overrides specified fields', () {
      final item = SyncQueueModel(
        id: 'sync-1',
        missionId: 'mission-1',
        data: const {},
        createdAt: now,
      );

      final updated = item.copyWith(status: SyncStatus.synced, attempts: 1);

      expect(updated.status, SyncStatus.synced);
      expect(updated.attempts, 1);
      expect(updated.id, 'sync-1'); // unchanged
    });
  });

  group('SyncStatus', () {
    test('label returns correct French text', () {
      expect(SyncStatus.pending.label, 'En attente');
      expect(SyncStatus.syncing.label, 'Synchronisation');
      expect(SyncStatus.synced.label, 'Synchronisé');
      expect(SyncStatus.failed.label, 'Échoué');
    });
  });
}
