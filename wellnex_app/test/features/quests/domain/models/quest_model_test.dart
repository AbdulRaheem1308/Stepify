import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/features/quests/domain/models/quest_model.dart';

void main() {
  group('QuestStage Model Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'stage1',
        'title': 'Walk 5000 Steps',
        'description': 'Take 5000 steps today.',
        'targetSteps': 5000,
        'isCompleted': true,
      };

      final stage = QuestStage.fromJson(json);

      expect(stage.id, 'stage1');
      expect(stage.title, 'Walk 5000 Steps');
      expect(stage.targetSteps, 5000);
      expect(stage.isCompleted, true);
    });

    test('equality and hashCode work', () {
      final stage1 = QuestStage(
        id: '1',
        title: 'Title',
        description: 'Desc',
        targetSteps: 100,
      );
      final stage2 = QuestStage(
        id: '1',
        title: 'Title',
        description: 'Desc',
        targetSteps: 100,
      );
      final stage3 = QuestStage(
        id: '2',
        title: 'Title',
        description: 'Desc',
        targetSteps: 100,
      );

      expect(stage1, equals(stage2));
      expect(stage1.hashCode, equals(stage2.hashCode));
      expect(stage1, isNot(equals(stage3)));
    });
  });

  group('Quest Model Tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'quest1',
        'title': 'Forest Adventure',
        'description': 'A nice walk in the forest.',
        'difficulty': 'MEDIUM',
        'status': 'IN_PROGRESS',
        'stages': [
          {
            'id': 'stage1',
            'title': 'Walk 1',
            'description': 'Desc',
            'targetSteps': 100,
          }
        ],
        'currentStageIndex': 1,
        'rewardXp': 200,
        'rewardCoins': 50,
      };

      final quest = Quest.fromJson(json);

      expect(quest.id, 'quest1');
      expect(quest.title, 'Forest Adventure');
      expect(quest.difficulty, QuestDifficulty.medium);
      expect(quest.status, QuestStatus.inProgress);
      expect(quest.stages.length, 1);
      expect(quest.currentStageIndex, 1);
      expect(quest.rewardXp, 200);
    });

    test('progress calculates correctly', () {
      final quest = Quest(
        id: '1',
        title: 'T',
        description: 'D',
        imageUrl: '',
        difficulty: QuestDifficulty.easy,
        stages: [
          QuestStage(id: '1', title: '1', description: '1', targetSteps: 10),
          QuestStage(id: '2', title: '2', description: '2', targetSteps: 20),
        ],
        currentStageIndex: 1,
        rewardXp: 10,
        rewardCoins: 10,
      );

      expect(quest.progress, 0.5); // 1 / 2
    });

    test('equality and hashCode work', () {
      final quest1 = Quest(
        id: '1',
        title: 'T',
        description: 'D',
        imageUrl: '',
        difficulty: QuestDifficulty.easy,
        stages: [],
        rewardXp: 10,
        rewardCoins: 10,
      );
      final quest2 = Quest(
        id: '1',
        title: 'T',
        description: 'D',
        imageUrl: '',
        difficulty: QuestDifficulty.easy,
        stages: [],
        rewardXp: 10,
        rewardCoins: 10,
      );
      final quest3 = quest1.copyWith(title: 'Other Title');

      expect(quest1, equals(quest2));
      expect(quest1.hashCode, equals(quest2.hashCode));
      expect(quest1, isNot(equals(quest3)));
    });
  });
}
