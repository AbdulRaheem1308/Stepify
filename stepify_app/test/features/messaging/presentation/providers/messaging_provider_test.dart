import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/messaging/domain/models/messaging_models.dart';
import 'package:stepify_app/features/messaging/presentation/providers/messaging_provider.dart';
import 'package:stepify_app/services/messaging_service.dart';
import 'package:stepify_app/features/auth/domain/models/user_model.dart';

class MockMessagingService extends Mock implements MessagingService {}

void main() {
  late MockMessagingService mockService;
  late User mockUser;

  setUp(() {
    mockService = MockMessagingService();
    mockUser = User(id: 'u1', email: 'test@test.com', name: 'Test User');
  });

  group('MessagingNotifier', () {
    test('loads conversations successfully', () async {
      final conversations = [
        Conversation(id: 'c1', otherUser: mockUser),
      ];
      when(() => mockService.getConversations()).thenAnswer((_) async => conversations);

      final notifier = MessagingNotifier(mockService, 'myId');
      
      expect(notifier.state.isLoading, true);
      
      // Wait for future to complete
      await Future.delayed(Duration.zero);
      
      expect(notifier.state.isLoading, false);
      expect(notifier.state.conversations, conversations);
      expect(notifier.state.error, null);
    });

    test('loads conversations with error', () async {
      when(() => mockService.getConversations()).thenThrow(Exception('Network error'));

      final notifier = MessagingNotifier(mockService, 'myId');
      
      await Future.delayed(Duration.zero);
      
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Network error');
    });

    test('loadMessages successfully', () async {
      when(() => mockService.getConversations()).thenAnswer((_) async => []);
      final messages = [
        Message(id: 'm1', conversationId: 'c1', senderId: 'u1', content: 'hello', timestamp: DateTime.now())
      ];
      when(() => mockService.getMessages('c1')).thenAnswer((_) async => messages);

      final notifier = MessagingNotifier(mockService, 'myId');
      await Future.delayed(Duration.zero);

      await notifier.loadMessages('c1');
      
      expect(notifier.state.messages['c1'], messages);
      expect(notifier.state.error, null);
    });

    test('loadMessages with error', () async {
      when(() => mockService.getConversations()).thenAnswer((_) async => []);
      when(() => mockService.getMessages('c1')).thenThrow(Exception('Fail'));

      final notifier = MessagingNotifier(mockService, 'myId');
      await Future.delayed(Duration.zero);

      await notifier.loadMessages('c1');
      
      expect(notifier.state.error, 'Fail');
    });

    test('sendMessage successfully', () async {
      when(() => mockService.getConversations()).thenAnswer((_) async => []);
      final msg = Message(id: 'm1', conversationId: 'c1', senderId: 'myId', content: 'hi', timestamp: DateTime.now());
      when(() => mockService.sendMessage('c1', 'hi')).thenAnswer((_) async => msg);

      final notifier = MessagingNotifier(mockService, 'myId');
      await Future.delayed(Duration.zero);

      await notifier.sendMessage('c1', 'hi');
      
      expect(notifier.state.messages['c1'], contains(msg));
    });

    test('clearError resets error state to null', () async {
      when(() => mockService.getConversations()).thenAnswer((_) async => []);
      final notifier = MessagingNotifier(mockService, 'myId');
      await Future.delayed(Duration.zero);

      notifier.state = notifier.state.copyWith(error: 'Some error');
      expect(notifier.state.error, 'Some error');

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });

    test('loadConversations updates conversations state', () async {
      final conversations = [
        Conversation(id: 'c1', otherUser: User(id: 'u1', name: 'Other')),
      ];
      when(() => mockService.getConversations()).thenAnswer((_) async => conversations);

      final notifier = MessagingNotifier(mockService, 'myId');
      await Future.delayed(Duration.zero);

      // Call public loadConversations
      await notifier.loadConversations();
      expect(notifier.state.conversations, conversations);
    });
  });
}
