import 'package:flutter_test/flutter_test.dart';
import 'package:labocollect/shared/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 'user-1',
        'name': 'Test User',
        'email': 'test@example.com',
        'token': 'jwt-token-123',
        'role': 'admin',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.token, 'jwt-token-123');
      expect(user.role, 'admin');
    });

    test('fromJson uses default role when missing', () {
      final json = {
        'id': 'user-1',
        'name': 'Test User',
        'email': 'test@example.com',
        'token': 'jwt-token-123',
      };

      final user = UserModel.fromJson(json);
      expect(user.role, 'collector');
    });

    test('toJson produces correct map', () {
      const user = UserModel(
        id: 'user-1',
        name: 'Test User',
        email: 'test@example.com',
        token: 'jwt-token-123',
        role: 'collector',
      );

      final json = user.toJson();

      expect(json['id'], 'user-1');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['token'], 'jwt-token-123');
      expect(json['role'], 'collector');
    });

    test('round-trip serialization preserves data', () {
      const original = UserModel(
        id: 'u1',
        name: 'Alice',
        email: 'alice@lab.com',
        token: 'tok',
        role: 'admin',
      );

      final roundTripped = UserModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.name, original.name);
      expect(roundTripped.email, original.email);
      expect(roundTripped.token, original.token);
      expect(roundTripped.role, original.role);
    });

    test('copyWith overrides specified fields', () {
      const user = UserModel(
        id: 'u1',
        name: 'Alice',
        email: 'alice@lab.com',
        token: 'tok',
      );

      final updated = user.copyWith(name: 'Bob', role: 'admin');

      expect(updated.name, 'Bob');
      expect(updated.role, 'admin');
      expect(updated.id, 'u1'); // unchanged
      expect(updated.email, 'alice@lab.com'); // unchanged
    });
  });
}
