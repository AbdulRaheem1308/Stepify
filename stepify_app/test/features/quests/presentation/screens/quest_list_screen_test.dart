import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/quests/domain/models/quest_model.dart';
import 'package:stepify_app/features/quests/presentation/providers/quests_provider.dart';
import 'package:stepify_app/features/quests/presentation/screens/quest_list_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/services/quests_service.dart' hide questsServiceProvider;
import 'dart:io';

class _FakeHttpOverrides extends HttpOverrides {}

class MockQuestsService extends Mock implements QuestsService {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  final sampleQuests = [
    Quest(
      id: 'q1',
      title: 'Active Quest',
      description: 'Desc',
      imageUrl: 'https://example.com/1.png',
      difficulty: QuestDifficulty.easy,
      stages: [],
      rewardXp: 100,
      rewardCoins: 10,
      status: QuestStatus.inProgress,
    ),
    Quest(
      id: 'q2',
      title: 'Available Quest',
      description: 'Desc',
      imageUrl: 'https://example.com/2.png',
      difficulty: QuestDifficulty.medium,
      stages: [],
      rewardXp: 200,
      rewardCoins: 20,
      status: QuestStatus.available,
    ),
    Quest(
      id: 'q3',
      title: 'Locked Quest',
      description: 'Desc',
      imageUrl: 'https://example.com/3.png',
      difficulty: QuestDifficulty.hard,
      stages: [],
      rewardXp: 300,
      rewardCoins: 30,
      status: QuestStatus.locked,
    ),
  ];

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: QuestListScreen(),
      ),
    );
  }

  testWidgets('QuestListScreen categorizes and displays quests', (tester) async {
    final mockService = MockQuestsService();
    final notifier = QuestsNotifier(mockService, 'user1');
    notifier.state = QuestsState(quests: sampleQuests);

    final container = ProviderContainer(
      overrides: [
        questsProvider.overrideWith((ref) => notifier),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    // Check categories
    expect(find.text('In Progress', skipOffstage: false), findsWidgets); // one for header, one for card badge
    expect(find.text('Available Quests', skipOffstage: false), findsOneWidget);
    expect(find.text('Locked', skipOffstage: false), findsWidgets);

    // Check quest titles
    expect(find.text('Active Quest', skipOffstage: false), findsOneWidget);
    expect(find.text('Available Quest', skipOffstage: false), findsOneWidget);
    expect(find.text('Locked Quest', skipOffstage: false), findsOneWidget);
  });

  testWidgets('QuestListScreen shows error snackbar', (tester) async {
    final mockService = MockQuestsService();
    final notifier = QuestsNotifier(mockService, 'user1');
    notifier.state = QuestsState(quests: []);

    final container = ProviderContainer(
      overrides: [
        questsProvider.overrideWith((ref) => notifier),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    
    notifier.state = notifier.state.copyWith(error: 'List Error');
    await tester.pump();
    
    expect(find.text('List Error'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
