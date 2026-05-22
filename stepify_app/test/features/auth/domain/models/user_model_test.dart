import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/auth/domain/models/user_model.dart';

void main() {
  group('UserModel', () {
    final Map<String, dynamic> validJson = {
      'id': '123',
      'name': 'Test User',
      'email': 'test@test.com',
      'avatarUrl': 'https://example.com/avatar.png',
    };

    test('fromJson parses correctly with valid data', () {
      final user = User.fromJson(validJson);
      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@test.com');
      expect(user.photoUrl, 'https://example.com/avatar.png');
    });

    test('fromJson handles nulls gracefully', () {
      final user = User.fromJson({'id': '456'});
      expect(user.id, '456');
      expect(user.name, null);
      expect(user.email, null);
      expect(user.photoUrl, null);
    });

    test('toJson serializes correctly', () {
      final user = User(
        id: '789',
        name: 'Jane',
        email: 'jane@test.com',
        photoUrl: 'http://pic.com',
      );
      final json = user.toJson();
      expect(json['id'], '789');
      expect(json['name'], 'Jane');
      expect(json['email'], 'jane@test.com');
      expect(json['photoUrl'], 'http://pic.com');
    });

    test('equality and hashCode work properly', () {
      final user1 = User(id: '1', name: 'A', email: 'a@a.com', photoUrl: 'url');
      final user2 = User(id: '1', name: 'A', email: 'a@a.com', photoUrl: 'url');
      final user3 = User(id: '2');

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, isNot(equals(user3.hashCode)));
    });
  });
}
