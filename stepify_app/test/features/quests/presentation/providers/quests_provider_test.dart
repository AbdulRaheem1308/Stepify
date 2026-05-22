import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/quests/domain/models/quest_model.dart';
import 'package:stepify_app/features/quests/presentation/providers/quests_provider.dart';
import 'package:stepify_app/services/quests_service.dart' hide questsServiceProvider;

class MockQuestsService extends Mock implements QuestsService {}

void main() {
  late MockQuestsService mockService;
  late ProviderContainer container;

  final sampleQuest = Quest(
    id: 'q1',
    title: 'Quest 1',
    description: 'Desc',
    imageUrl: '',
    difficulty: QuestDifficulty.easy,
    stages: [],
    rewardXp: 100,
    rewardCoins: 50,
    status: QuestStatus.available,
  );

  setUp(() {
    mockService = MockQuestsService();
    
    // We mock the service in the provider override.
    container = ProviderContainer(
      overrides: [
        // We override questsServiceProvider to return our mock
        questsServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('QuestsState', () {
    test('equality and copyWith work', () {
      final state1 = QuestsState(quests: [sampleQuest], isLoading: true, error: 'Err');
      final state2 = QuestsState(quests: [sampleQuest], isLoading: true, error: 'Err');
      final state3 = state1.copyWith(error: null);

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('QuestsNotifier Tests', () {
    test('initial state loads quests successfully without user', () async {
      when(() => mockService.getAllQuests()).thenAnswer((_) async => [sampleQuest]);

      final notifier = QuestsNotifier(mockService, null); // No user ID

      expect(notifier.state.isLoading, true); // initial state

      // Wait for load to finish
      await Future.delayed(Duration.zero);

      expect(notifier.state.isLoading, false);
      expect(notifier.state.quests.length, 1);
      expect(notifier.state.error, isNull);
      expect(notifier.state.quests.first.title, 'Quest 1');
      verify(() => mockService.getAllQuests()).called(1);
      verifyNever(() => mockService.getMyQuests());
    });

    test('loads quests with user and merges status', () async {
      when(() => mockService.getAllQuests()).thenAnswer((_) async => [sampleQuest]);
      final myQuest = sampleQuest.copyWith(status: QuestStatus.inProgress, currentStageIndex: 1);
      when(() => mockService.getMyQuests()).thenAnswer((_) async => [myQuest]);

      final notifier = QuestsNotifier(mockService, 'user1');

      await Future.delayed(Duration.zero);

      expect(notifier.state.quests.first.status, QuestStatus.inProgress);
      expect(notifier.state.quests.first.currentStageIndex, 1);
      verify(() => mockService.getAllQuests()).called(1);
      verify(() => mockService.getMyQuests()).called(1);
    });

    test('handles error when loading quests', () async {
      when(() => mockService.getAllQuests()).thenThrow(Exception('Network Error'));

      final notifier = QuestsNotifier(mockService, 'user1');

      await Future.delayed(Duration.zero);

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, contains('Network Error'));
      expect(notifier.state.quests, isEmpty);
    });

    test('joinQuest updates state if successful', () async {
      when(() => mockService.getAllQuests()).thenAnswer((_) async => [sampleQuest]);
      when(() => mockService.getMyQuests()).thenAnswer((_) async => []);
      
      final notifier = QuestsNotifier(mockService, 'user1');
      await Future.delayed(Duration.zero); // finish initial load

      // Stub joinQuest to succeed and next getMyQuests to return the quest in progress
      when(() => mockService.joinQuest('q1')).thenAnswer((_) async => {});
      final myQuest = sampleQuest.copyWith(status: QuestStatus.inProgress);
      when(() => mockService.getMyQuests()).thenAnswer((_) async => [myQuest]);

      await notifier.joinQuest('q1');

      verify(() => mockService.joinQuest('q1')).called(1);
      // It calls loadQuests again
      expect(notifier.state.quests.first.status, QuestStatus.inProgress);
    });

    test('joinQuest sets error on failure', () async {
      when(() => mockService.getAllQuests()).thenAnswer((_) async => [sampleQuest]);
      when(() => mockService.getMyQuests()).thenAnswer((_) async => []);

      final notifier = QuestsNotifier(mockService, 'user1');
      await Future.delayed(Duration.zero);

      when(() => mockService.joinQuest('q1')).thenThrow(Exception('Join Error'));

      await notifier.joinQuest('q1');

      expect(notifier.state.error, contains('Join Error'));
    });

    test('joinQuest fails if no user', () async {
      final notifier = QuestsNotifier(mockService, null);
      
      await notifier.joinQuest('q1');

      expect(notifier.state.error, contains('logged in'));
      verifyNever(() => mockService.joinQuest('q1'));
    });
  });
}
