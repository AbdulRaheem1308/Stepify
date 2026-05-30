import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/features/messaging/presentation/screens/conversations_screen.dart';
import 'package:wellnex_app/features/messaging/presentation/providers/messaging_provider.dart';
import 'package:wellnex_app/features/messaging/domain/models/messaging_models.dart';
import 'package:wellnex_app/features/auth/domain/models/user_model.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createTestWidget(MessagingState initialState) {
    return ProviderScope(
      overrides: [
        messagingProvider.overrideWith((ref) => MockMessagingNotifier(initialState)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ConversationsScreen(),
      ),
    );
  }

  testWidgets('ConversationsScreen shows loading state correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(MessagingState(isLoading: true, conversations: [])));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ConversationsScreen shows error state and retry button', (tester) async {
    await tester.pumpWidget(createTestWidget(MessagingState(error: 'Failed to load conversations', conversations: [])));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load conversations'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('ConversationsScreen shows empty state correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(MessagingState(conversations: [])));
    await tester.pumpAndSettle();

    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('ConversationsScreen shows list of conversations', (tester) async {
    final otherUser = User(id: 'u1', name: 'Alice');
    final lastMessage = Message(
      id: 'm1',
      conversationId: 'c1',
      senderId: 'u1',
      content: 'Hello Bob',
      timestamp: DateTime.now(),
    );
    final conversations = [
      Conversation(id: 'c1', otherUser: otherUser, lastMessage: lastMessage, unreadCount: 2),
    ];

    await tester.pumpWidget(createTestWidget(MessagingState(conversations: conversations)));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Hello Bob'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // unread count badge
  });
}

class MockMessagingNotifier extends StateNotifier<MessagingState> implements MessagingNotifier {
  MockMessagingNotifier(super.state);

  @override
  Future<void> loadConversations() async {}

  @override
  Future<void> loadMessages(String conversationId) async {}

  @override
  Future<void> sendMessage(String conversationId, String content) async {}

  @override
  void clearError() {}
}
