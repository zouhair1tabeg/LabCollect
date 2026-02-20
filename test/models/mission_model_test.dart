import 'package:flutter_test/flutter_test.dart';
import 'package:labocollect/core/constants/app_constants.dart';
import 'package:labocollect/shared/models/mission_model.dart';

void main() {
  group('MissionModel', () {
    final now = DateTime(2024, 6, 15, 10, 30);

    test('fromJson creates correct model', () {
      final json = {
        'id': 'mission-1',
        'title': 'Analyse Eau',
        'description': 'Test description',
        'status': 'inProgress',
        'lastCompletedStep': 3,
        'categoryId': 'cat-1',
        'assignedTo': 'user-1',
        'createdAt': now.toIso8601String(),
        'currentStepIndex': 4,
      };

      final mission = MissionModel.fromJson(json);

      expect(mission.id, 'mission-1');
      expect(mission.title, 'Analyse Eau');
      expect(mission.status, MissionStatus.inProgress);
      expect(mission.lastCompletedStep, 3);
      expect(mission.categoryId, 'cat-1');
      expect(mission.currentStepIndex, 4);
    });

    test('fromJson uses defaults for optional fields', () {
      final json = {
        'id': 'mission-1',
        'title': 'Analyse',
        'assignedTo': 'user-1',
        'createdAt': now.toIso8601String(),
      };

      final mission = MissionModel.fromJson(json);

      expect(mission.description, '');
      expect(mission.status, MissionStatus.pending);
      expect(mission.lastCompletedStep, -1);
      expect(mission.currentStepIndex, 0);
      expect(mission.updatedAt, isNull);
      expect(mission.collectionData, isNull);
    });

    test('toJson produces correct map', () {
      final mission = MissionModel(
        id: 'm1',
        title: 'Test',
        status: MissionStatus.completed,
        assignedTo: 'u1',
        createdAt: now,
        lastCompletedStep: 8,
      );

      final json = mission.toJson();

      expect(json['id'], 'm1');
      expect(json['status'], 'completed');
      expect(json['lastCompletedStep'], 8);
    });

    test('round-trip serialization preserves data', () {
      final original = MissionModel(
        id: 'm1',
        title: 'Round Trip',
        description: 'Desc',
        status: MissionStatus.inProgress,
        lastCompletedStep: 5,
        assignedTo: 'u1',
        createdAt: now,
        updatedAt: now,
        currentStepIndex: 6,
      );

      final roundTripped = MissionModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.title, original.title);
      expect(roundTripped.status, original.status);
      expect(roundTripped.lastCompletedStep, original.lastCompletedStep);
      expect(roundTripped.currentStepIndex, original.currentStepIndex);
    });

    test('copyWith overrides specified fields', () {
      final mission = MissionModel(
        id: 'm1',
        title: 'Original',
        assignedTo: 'u1',
        createdAt: now,
      );

      final updated = mission.copyWith(
        status: MissionStatus.completed,
        lastCompletedStep: 9,
      );

      expect(updated.status, MissionStatus.completed);
      expect(updated.lastCompletedStep, 9);
      expect(updated.title, 'Original'); // unchanged
    });
  });

  group('MissionStatus', () {
    test('label returns correct French text', () {
      expect(MissionStatus.pending.label, 'En attente');
      expect(MissionStatus.inProgress.label, 'En cours');
      expect(MissionStatus.completed.label, 'Terminée');
    });
  });
}
