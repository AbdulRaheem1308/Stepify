import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/quests/domain/models/quest_model.dart';
import 'package:stepify_app/features/quests/presentation/providers/quests_provider.dart';
import 'package:stepify_app/features/quests/presentation/screens/quest_detail_screen.dart';

void main() {
  late Quest mockQuest;

  setUp(() {
    mockQuest = Quest(
      id: 'q1',
      title: 'Beginner Walker',
      description: 'Start your walking journey.',
      imageUrl: 'https://example.com/quest.png',
      difficulty: QuestDifficulty.easy,
      rewardCoins: 50,
      rewardXp: 100,
      status: QuestStatus.available,
      stages: [
        QuestStage(
          id: 's1',
          title: 'Stage 1',
          description: 'Walk 1000 steps',
          targetSteps: 1000,
        ),
      ],
      currentStageIndex: 0,
    );
  });

  testWidgets('QuestDetailScreen renders quest details correctly', (tester) async {
    mockQuest = Quest(
      id: 'q1',
      title: 'Beginner Walker',
      description: 'Start your walking journey.',
      imageUrl: 'https://example.com/quest.png',
      difficulty: QuestDifficulty.easy,
      rewardCoins: 50,
      rewardXp: 100,
      status: QuestStatus.available,
      stages: [
        QuestStage(
          id: 's1',
          title: 'Stage 1',
          description: 'Walk 1000 steps',
          targetSteps: 1000,
        ),
      ],
      currentStageIndex: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questsProvider.overrideWith((ref) => MockQuestsNotifier(
                QuestsState(quests: [mockQuest]),
              )),
        ],
        child: MaterialApp(
          home: QuestDetailScreen(questId: 'q1', initialQuest: mockQuest),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Beginner Walker'), findsOneWidget);
    expect(find.text('Start your walking journey.'), findsOneWidget);
    expect(find.text('50 Coins'), findsOneWidget); // reward coins
    expect(find.text('100 XP'), findsOneWidget); // reward XP
    expect(find.text('Stage 1'), findsOneWidget);
  });
}

class MockQuestsNotifier extends StateNotifier<QuestsState> implements QuestsNotifier {
  MockQuestsNotifier(super.state);

  @override
  Future<void> fetchQuests() async {}

  @override
  Future<void> joinQuest(String questId) async {}

  @override
  void clearError() {}
}
