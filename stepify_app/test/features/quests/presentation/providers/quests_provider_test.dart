import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/quests/domain/models/quest_model.dart';
import 'package:stepify_app/features/quests/presentation/providers/quests_provider.dart';
import 'package:stepify_app/services/quests_service.dart' hide questsServiceProvider;
import 'package:stepify_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:stepify_app/features/auth/domain/models/user_model.dart';

class MockQuestsService implements QuestsService {
  bool shouldFailMyQuests = false;
  bool shouldFailJoin = false;
  bool joinCalled = false;

  @override
  Future<List<Quest>> getAllQuests() async {
    return [
      Quest(
        id: 'q1',
        title: 'Quest 1',
        description: 'Desc 1',
        imageUrl: '',
        difficulty: QuestDifficulty.easy,
        status: QuestStatus.available,
        stages: [],
        rewardXp: 100,
        rewardCoins: 50,
      ),
      Quest(
        id: 'q2',
        title: 'Quest 2',
        description: 'Desc 2',
        imageUrl: '',
        difficulty: QuestDifficulty.medium,
        status: QuestStatus.available,
        stages: [],
        rewardXp: 200,
        rewardCoins: 100,
      ),
    ];
  }

  @override
  Future<List<Quest>> getMyQuests() async {
    if (shouldFailMyQuests) throw Exception('myquests fail');
    return [
      Quest(
        id: 'q1',
        title: 'Quest 1',
        description: 'Desc 1',
        imageUrl: '',
        difficulty: QuestDifficulty.easy,
        status: QuestStatus.inProgress, // User specific status
        stages: [],
        currentStageIndex: 1, // User specific progress
        rewardXp: 100,
        rewardCoins: 50,
      )
    ];
  }

  @override
  Future<void> joinQuest(String questId) async {
    joinCalled = true;
    if (shouldFailJoin) throw Exception('join fail');
  }
}

Future<void> waitForLoading(ProviderContainer container) async {
  for (int i = 0; i < 50; i++) {
    if (!container.read(questsProvider).isLoading) return;
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  group('QuestsState', () {
    test('defaults and equality', () {
      final state1 = QuestsState();
      final state2 = QuestsState();
      expect(state1.quests, isEmpty);
      expect(state1.isLoading, false);
      expect(state1.error, isNull);
      
      expect(state1 == state2, true);
    });

    test('copyWith updates values', () {
      final state = QuestsState().copyWith(
        quests: [Quest(id: '1', title: 'Q', description: '', imageUrl: '', difficulty: QuestDifficulty.easy, status: QuestStatus.available, stages: [], rewardXp: 10, rewardCoins: 5)],
        isLoading: true,
        error: 'Err',
      );
      expect(state.quests.length, 1);
      expect(state.isLoading, true);
      expect(state.error, 'Err');
    });
  });

  group('QuestsNotifier _loadQuests', () {
    test('success with no userId', () async {
      final mockService = MockQuestsService();
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(null),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      
      await waitForLoading(container);
      
      final state = container.read(questsProvider);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.quests.length, 2);
      expect(state.quests[0].status, QuestStatus.available); 
      sub.close();
    });

    test('success with userId merges myQuests', () async {
      final mockService = MockQuestsService();
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(User(id: 'u1', name: 'User', email: '', photoUrl: null)),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      
      await waitForLoading(container);
      
      final state = container.read(questsProvider);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.quests.length, 2);
      expect(state.quests[0].id, 'q1');
      expect(state.quests[0].status, QuestStatus.inProgress);
      expect(state.quests[0].currentStageIndex, 1);
      expect(state.quests[1].id, 'q2');
      expect(state.quests[1].status, QuestStatus.available);
      sub.close();
    });

    test('partial failure on getMyQuests', () async {
      final mockService = MockQuestsService()..shouldFailMyQuests = true;
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(User(id: 'u1', name: 'User', email: '', photoUrl: null)),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      
      await waitForLoading(container);
      
      final state = container.read(questsProvider);
      expect(state.isLoading, false);
      expect(state.error, contains('myquests fail'));
      expect(state.quests.length, 2); 
      expect(state.quests[0].status, QuestStatus.available); 
      sub.close();
    });
  });

  group('QuestsNotifier joinQuest & clearError', () {
    test('no userId sets error', () async {
      final mockService = MockQuestsService();
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(null),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      await waitForLoading(container);
      
      final notifier = container.read(questsProvider.notifier);
      await notifier.joinQuest('q1');
      await waitForLoading(container);
      
      final state = container.read(questsProvider);
      expect(state.error, 'You must be logged in to join quests.');
      expect(mockService.joinCalled, false);
      sub.close();
    });

    test('success calls service then reloads', () async {
      final mockService = MockQuestsService();
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(User(id: 'u1', name: 'User', email: '', photoUrl: null)),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      await waitForLoading(container);
      
      final notifier = container.read(questsProvider.notifier);
      await notifier.joinQuest('q2');
      await waitForLoading(container);
      
      final state = container.read(questsProvider);
      expect(state.isLoading, false);
      expect(mockService.joinCalled, true);
      sub.close();
    });

    test('service failure reverts optimistic update', () async {
      final mockService = MockQuestsService()..shouldFailJoin = true;
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(User(id: 'u1', name: 'User', email: '', photoUrl: null)),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      await waitForLoading(container);
      
      final notifier = container.read(questsProvider.notifier);
      await notifier.joinQuest('q2');
      await waitForLoading(container);
      
      final state = container.read(questsProvider);
      expect(state.isLoading, false);
      expect(state.error, contains('join fail'));
      expect(state.quests[1].status, QuestStatus.available);
      sub.close();
    });

    test('clearError works', () async {
      final mockService = MockQuestsService()..shouldFailMyQuests = true;
      final container = ProviderContainer(
        overrides: [
          questsServiceProvider.overrideWithValue(mockService),
          currentUserProvider.overrideWithValue(User(id: 'u1', name: 'User', email: '', photoUrl: null)),
        ],
      );
      final sub = container.listen(questsProvider, (_, __) {});
      await waitForLoading(container);
      
      final notifier = container.read(questsProvider.notifier);
      expect(container.read(questsProvider).error, isNotNull);
      
      notifier.clearError();
      expect(container.read(questsProvider).error, isNull);
      sub.close();
    });
  });
}
