import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/quests/domain/models/quest_model.dart';
import 'package:stepify_app/features/quests/presentation/providers/quests_provider.dart';
import 'package:stepify_app/features/quests/presentation/screens/quest_detail_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/services/quests_service.dart' hide questsServiceProvider;
import 'dart:io';

class _FakeHttpOverrides extends HttpOverrides {}

class MockQuestsService extends Mock implements QuestsService {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  final sampleQuest = Quest(
    id: 'q1',
    title: 'Test Quest',
    description: 'Test Description',
    imageUrl: 'https://example.com/image.png',
    difficulty: QuestDifficulty.easy,
    stages: [
      QuestStage(id: 's1', title: 'Stage 1', description: 'Desc 1', targetSteps: 1000, isCompleted: true),
      QuestStage(id: 's2', title: 'Stage 2', description: 'Desc 2', targetSteps: 2000),
      QuestStage(id: 's3', title: 'Stage 3', description: 'Desc 3', targetSteps: 3000),
    ],
    currentStageIndex: 1,
    rewardXp: 500,
    rewardCoins: 100,
    status: QuestStatus.inProgress,
  );

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: QuestDetailScreen(questId: 'q1', initialQuest: sampleQuest),
      ),
    );
  }

  testWidgets('QuestDetailScreen displays quest details and stages', (tester) async {
    final mockService = MockQuestsService();
    when(() => mockService.getAllQuests()).thenAnswer((_) async => [sampleQuest]);
    when(() => mockService.getMyQuests()).thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [
        questsServiceProvider.overrideWithValue(mockService),
        // Pre-populate state to avoid waiting for async load
        questsProvider.overrideWith((ref) {
          final notifier = QuestsNotifier(mockService, 'user1');
          notifier.state = QuestsState(quests: [sampleQuest]);
          return notifier;
        }),
      ],
    );

    // Load images quickly by overriding http requests if needed, but network image in test returns 400 without mock, it shouldn't crash
    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('Test Quest'), findsWidgets);
    expect(find.text('Test Description'), findsWidgets);
    expect(find.text('500 XP'), findsWidgets);
    expect(find.text('100 Coins'), findsWidgets);

    // Stages
    expect(find.text('Stage 1', skipOffstage: false), findsOneWidget);
    expect(find.text('Stage 2', skipOffstage: false), findsOneWidget);
    expect(find.text('Stage 3', skipOffstage: false), findsOneWidget);
    expect(find.text('Target: 1000 Steps', skipOffstage: false), findsOneWidget);

    // Button state for IN_PROGRESS
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Continue Journey (Go Walk!)', skipOffstage: false), findsOneWidget);
  });
  
  testWidgets('QuestDetailScreen shows snackbar on error', (tester) async {
    final mockService = MockQuestsService();
    final notifier = QuestsNotifier(mockService, 'user1');
    notifier.state = QuestsState(quests: [sampleQuest]);

    final container = ProviderContainer(
      overrides: [
        questsServiceProvider.overrideWithValue(mockService),
        questsProvider.overrideWith((ref) => notifier),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    
    // Simulate error
    notifier.state = notifier.state.copyWith(error: 'Test Error Message');
    await tester.pump(); // Pump to process listener
    
    expect(find.text('Test Error Message'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
