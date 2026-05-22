import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/auth/domain/models/user_model.dart';
import 'package:stepify_app/features/messaging/domain/models/messaging_models.dart';

void main() {
  group('Messaging Models', () {
    test('Message fromJson parses correctly', () {
      final json = {
        'id': 'm1',
        'conversationId': 'c1',
        'senderId': 'u1',
        'content': 'hello',
        'createdAt': '2023-01-01T10:00:00.000Z',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'm1');
      expect(message.conversationId, 'c1');
      expect(message.senderId, 'u1');
      expect(message.content, 'hello');
      expect(message.timestamp.year, 2023);
      expect(message.isRead, false);
    });

    test('Conversation fromJson parses correctly', () {
      final json = {
        'id': 'c1',
        'participants': [
          {
            'user': {
              'id': 'u1',
              'email': 'user@test.com',
              'name': 'Other User'
            }
          }
        ],
        'messages': [
          {
            'id': 'm1',
            'conversationId': 'c1',
            'senderId': 'u1',
            'content': 'latest message',
            'createdAt': '2023-01-01T10:00:00.000Z',
          }
        ]
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.id, 'c1');
      expect(conversation.otherUser.id, 'u1');
      expect(conversation.otherUser.name, 'Other User');
      expect(conversation.lastMessage?.content, 'latest message');
      expect(conversation.unreadCount, 0);
    });

    test('Message equality and hashCode', () {
      final now = DateTime.now();
      final m1 = Message(id: 'm1', conversationId: 'c1', senderId: 'u1', content: 'hello', timestamp: now, isRead: false);
      final m2 = Message(id: 'm1', conversationId: 'c1', senderId: 'u1', content: 'hello', timestamp: now, isRead: false);
      final m3 = Message(id: 'm2', conversationId: 'c1', senderId: 'u1', content: 'hello', timestamp: now, isRead: false);

      expect(m1, equals(m2));
      expect(m1.hashCode, equals(m2.hashCode));
      expect(m1, isNot(equals(m3)));
    });

    test('Conversation equality and hashCode', () {
      final u1 = User(id: 'u1', name: 'User 1');
      final u2 = User(id: 'u1', name: 'User 1'); // Same properties
      final u3 = User(id: 'u2', name: 'User 2');

      final c1 = Conversation(id: 'c1', otherUser: u1, unreadCount: 2);
      final c2 = Conversation(id: 'c1', otherUser: u2, unreadCount: 2);
      final c3 = Conversation(id: 'c1', otherUser: u3, unreadCount: 2);

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
    });
  });
}
