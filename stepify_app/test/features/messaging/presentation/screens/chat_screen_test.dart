import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/messaging/presentation/screens/chat_screen.dart';
import 'package:stepify_app/features/messaging/presentation/providers/messaging_provider.dart';
import 'package:stepify_app/features/messaging/domain/models/messaging_models.dart';
import 'package:stepify_app/features/auth/domain/models/user_model.dart';
import 'package:stepify_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  late MockMessagingNotifier mockNotifier;

  Widget createTestWidget(MessagingState initialState, {User? currentUser}) {
    mockNotifier = MockMessagingNotifier(initialState);
    return ProviderScope(
      overrides: [
        messagingProvider.overrideWith((ref) => mockNotifier),
        currentUserProvider.overrideWith((ref) => currentUser),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ChatScreen(conversationId: 'c1', userName: 'Alice'),
      ),
    );
  }

  testWidgets('ChatScreen shows progress indicator when loading messages', (tester) async {
    await tester.pumpWidget(createTestWidget(MessagingState(isLoading: true, messages: {})));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ChatScreen loads messages on init', (tester) async {
    await tester.pumpWidget(createTestWidget(MessagingState(messages: {})));
    await tester.pumpAndSettle();

    expect(mockNotifier.loadedConversations, contains('c1'));
  });

  testWidgets('ChatScreen displays messages with correct alignment and text', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    
    final messages = [
      Message(id: 'm1', conversationId: 'c1', senderId: 'u_me', content: 'Hi Alice', timestamp: DateTime.now()),
      Message(id: 'm2', conversationId: 'c1', senderId: 'u_alice', content: 'Hi there', timestamp: DateTime.now()),
    ];

    await tester.pumpWidget(createTestWidget(
      MessagingState(messages: {'c1': messages}),
      currentUser: User(id: 'u_me', name: 'Bob'),
    ));
    await tester.pumpAndSettle();

    // Check message contents are rendered
    expect(find.text('Hi Alice'), findsOneWidget);
    expect(find.text('Hi there'), findsOneWidget);

    // Debug print semantics labels in the tree
    for (final element in tester.allElements) {
      if (element.widget is Semantics) {
        final semanticsWidget = element.widget as Semantics;
        if (semanticsWidget.properties.label != null && semanticsWidget.properties.label!.isNotEmpty) {
          print('DEBUG SEMANTICS LABEL: "${semanticsWidget.properties.label}"');
        }
      }
    }

    // Verify semantics labels: "You said..." and "Alice said..."
    expect(find.bySemanticsLabel('You said: Hi Alice'), findsOneWidget);
    expect(find.bySemanticsLabel('Alice said: Hi there'), findsOneWidget);
    
    semantics.dispose();
  });

  testWidgets('ChatScreen calls sendMessage notifier method when clicking Send button', (tester) async {
    await tester.pumpWidget(createTestWidget(
      MessagingState(messages: {'c1': []}),
      currentUser: User(id: 'u_me', name: 'Bob'),
    ));
    await tester.pumpAndSettle();

    // Type a message
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, 'Hello text');
    await tester.pump();

    // Press the send button
    final sendButton = find.byType(IconButton);
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);
    
    // Pump to handle the 100ms scroll delay timer and scroll animations
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify the notifier sendMessage was triggered
    expect(mockNotifier.sentMessages, contains('Hello text'));
  });
}

class MockMessagingNotifier extends StateNotifier<MessagingState> implements MessagingNotifier {
  final List<String> sentMessages = [];
  final List<String> loadedConversations = [];

  MockMessagingNotifier(super.state);

  @override
  Future<void> loadConversations() async {}

  @override
  Future<void> loadMessages(String conversationId) async {
    loadedConversations.add(conversationId);
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    sentMessages.add(content);
  }

  @override
  void clearError() {}
}
