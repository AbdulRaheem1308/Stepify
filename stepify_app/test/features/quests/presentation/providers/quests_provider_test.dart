// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/auth/domain/models/user_model.dart';
import 'package:stepify_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:stepify_app/features/quests/domain/models/quest_model.dart';
import 'package:stepify_app/features/quests/presentation/providers/quests_provider.dart';

// ---------------------------------------------------------------------------
// Manual mock for QuestsService
// ---------------------------------------------------------------------------

// We import QuestsService directly to avoid touching the real service.
import 'package:stepify_app/services/quests_service.dart' hide questsServiceProvider;

class _FakeQuestsService implements QuestsService {
  // Configurable responses / errors
  Future<List<Quest>> Function()? getAllQuestsImpl;
  Future<List<Quest>> Function()? getMyQuestsImpl;
  Future<void> Function(String)? joinQuestImpl;

  // Call counters
  int getAllQuestsCalled = 0;
  int getMyQuestsCalled = 0;
  final List<String> joinQuestCalledWith = [];

  @override
  Future<List<Quest>> getAllQuests() async {
    getAllQuestsCalled++;
    if (getAllQuestsImpl != null) return getAllQuestsImpl!();
    return [];
  }

  @override
  Future<List<Quest>> getMyQuests() async {
    getMyQuestsCalled++;
    if (getMyQuestsImpl != null) return getMyQuestsImpl!();
    return [];
  }

  @override
  Future<void> joinQuest(String questId) async {
    joinQuestCalledWith.add(questId);
    if (joinQuestImpl != null) return joinQuestImpl!(questId);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal [Quest] fixture.
Quest makeQuest({
  String id = 'q1',
  String title = 'Quest 1',
  QuestStatus status = QuestStatus.available,
  int currentStageIndex = 0,
}) =>
    Quest(
      id: id,
      title: title,
      description: 'Desc',
      imageUrl: '',
      difficulty: QuestDifficulty.easy,
      stages: const [],
      rewardXp: 100,
      rewardCoins: 50,
      status: status,
      currentStageIndex: currentStageIndex,
    );

/// Builds a [ProviderContainer] that wires [fakeService] into
/// [questsServiceProvider] and optionally sets [currentUserProvider] to a
/// [User] with [userId].
ProviderContainer buildContainer(
  _FakeQuestsService fakeService, {
  String? userId,
}) {
  return ProviderContainer(
    overrides: [
      questsServiceProvider.overrideWithValue(fakeService),
      // currentUserProvider is a plain Provider<User?>, so we can override it
      // with a fixed value without touching the authProvider chain.
      currentUserProvider.overrideWith(
        (_) => userId == null ? null : User(id: userId, name: 'Test User'),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // QuestsState unit tests
  // ──────────────────────────────────────────────────────────────────────────
  group('QuestsState', () {
    final quest = makeQuest();

    test('default constructor has correct defaults', () {
      final state = QuestsState();
      expect(state.quests, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith overrides individual fields', () {
      final original = QuestsState(quests: [quest], isLoading: false, error: null);

      final withLoading = original.copyWith(isLoading: true);
      expect(withLoading.isLoading, isTrue);
      expect(withLoading.quests, same(original.quests)); // same list reference

      final withError = original.copyWith(error: 'oops');
      expect(withError.error, 'oops');

      final withNull = original.copyWith(error: null);
      expect(withNull.error, isNull);
    });

    test('operator == and hashCode are consistent for equal states', () {
      final a = QuestsState(quests: [quest], isLoading: true, error: 'e');
      final b = QuestsState(quests: [quest], isLoading: true, error: 'e');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('operator == returns false for different states', () {
      final base = QuestsState(quests: [quest], isLoading: false, error: null);

      expect(base, isNot(equals(QuestsState(quests: [], isLoading: false, error: null))));
      expect(base, isNot(equals(QuestsState(quests: [quest], isLoading: true, error: null))));
      expect(base, isNot(equals(QuestsState(quests: [quest], isLoading: false, error: 'x'))));
    });

    test('identical objects are equal', () {
      final state = QuestsState();
      // ignore: unrelated_type_equality_checks
      expect(state == state, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // QuestsNotifier._loadQuests on init
  // ──────────────────────────────────────────────────────────────────────────
  group('QuestsNotifier init – _loadQuests()', () {
    test('unauthenticated: success, only getAllQuests called', () async {
      final quest = makeQuest();
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [quest];

      final container = buildContainer(fakeService, userId: null);
      addTearDown(container.dispose);

      // Give the async _loadQuests a microtask to complete.
      await Future<void>.delayed(Duration.zero);

      final state = container.read(questsProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.quests, hasLength(1));
      expect(state.quests.first.title, 'Quest 1');
      expect(fakeService.getAllQuestsCalled, 1);
      expect(fakeService.getMyQuestsCalled, 0);
    });

    test('authenticated: merges myQuests status into allQuests', () async {
      final allQuest = makeQuest(id: 'q1', status: QuestStatus.available);
      final myQuest = makeQuest(
        id: 'q1',
        status: QuestStatus.inProgress,
        currentStageIndex: 2,
      );

      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [allQuest]
        ..getMyQuestsImpl = () async => [myQuest];

      final container = buildContainer(fakeService, userId: 'user-42');
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(questsProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.quests, hasLength(1));
      expect(state.quests.first.status, QuestStatus.inProgress);
      expect(state.quests.first.currentStageIndex, 2);
      expect(fakeService.getAllQuestsCalled, 1);
      expect(fakeService.getMyQuestsCalled, 1);
    });

    test('authenticated + allQuests contains quest not in myQuests – keeps original status', () async {
      final q1 = makeQuest(id: 'q1', status: QuestStatus.available);
      final q2 = makeQuest(id: 'q2', status: QuestStatus.locked);
      final myQ1 = makeQuest(id: 'q1', status: QuestStatus.inProgress);

      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [q1, q2]
        ..getMyQuestsImpl = () async => [myQ1];

      final container = buildContainer(fakeService, userId: 'user-1');
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);

      final quests = container.read(questsProvider).quests;
      expect(quests.firstWhere((q) => q.id == 'q1').status, QuestStatus.inProgress);
      expect(quests.firstWhere((q) => q.id == 'q2').status, QuestStatus.locked);
    });

    test('partial failure: getMyQuests throws → allQuests returned + error set', () async {
      final allQuest = makeQuest();
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [allQuest]
        ..getMyQuestsImpl = () async => throw Exception('My quests unavailable');

      final container = buildContainer(fakeService, userId: 'user-99');
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(questsProvider);
      expect(state.isLoading, isFalse);
      // All-quests still returned even though myQuests failed.
      expect(state.quests, hasLength(1));
      expect(state.quests.first.status, QuestStatus.available);
      // Error message set to describe the partial failure.
      expect(state.error, isNotNull);
      expect(state.error, contains('Failed to load joined quests'));
    });

    test('getAllQuests throws → isLoading false, error set, quests unchanged', () async {
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => throw Exception('Network Error');

      final container = buildContainer(fakeService, userId: null);
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(questsProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, contains('Network Error'));
      expect(state.quests, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // QuestsNotifier.joinQuest()
  // ──────────────────────────────────────────────────────────────────────────
  group('QuestsNotifier.joinQuest()', () {
    test('no userId → sets login-required error, service never called', () async {
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [makeQuest()];

      // Build notifier directly (no container needed for this case).
      final notifier = QuestsNotifier(fakeService, null);
      await Future<void>.delayed(Duration.zero);

      await notifier.joinQuest('q1');

      expect(notifier.state.error, contains('logged in'));
      expect(fakeService.joinQuestCalledWith, isEmpty);

      notifier.dispose();
    });

    test('success → service called, state reloaded with merged status', () async {
      final quest = makeQuest(id: 'q1', status: QuestStatus.available);

      int getAllCount = 0;
      int getMyCount = 0;

      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async {
          getAllCount++;
          return [quest];
        }
        ..getMyQuestsImpl = () async {
          getMyCount++;
          if (getMyCount == 1) return []; // first load: not joined yet
          // after join: server now reports inProgress
          return [quest.copyWith(status: QuestStatus.inProgress)];
        }
        ..joinQuestImpl = (_) async {};

      final notifier = QuestsNotifier(fakeService, 'user-1');
      await Future<void>.delayed(Duration.zero); // initial load done

      await notifier.joinQuest('q1');

      expect(fakeService.joinQuestCalledWith, contains('q1'));
      // _loadQuests is called again after a successful join.
      expect(getAllCount, greaterThan(1));
      expect(notifier.state.quests.first.status, QuestStatus.inProgress);
      expect(notifier.state.error, isNull);

      notifier.dispose();
    });

    test('service failure → reverts optimistic update, sets error', () async {
      final quest = makeQuest(id: 'q1', status: QuestStatus.available);

      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [quest]
        ..getMyQuestsImpl = () async => []
        ..joinQuestImpl = (_) async => throw Exception('Server unavailable');

      final notifier = QuestsNotifier(fakeService, 'user-1');
      await Future<void>.delayed(Duration.zero);

      // Capture original state before join attempt.
      final originalStatus = notifier.state.quests.first.status;
      expect(originalStatus, QuestStatus.available);

      await notifier.joinQuest('q1');

      // Optimistic update reverted.
      expect(notifier.state.quests.first.status, QuestStatus.available);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('Failed to join quest'));
      expect(notifier.state.error, contains('Server unavailable'));

      notifier.dispose();
    });

    test('optimistic update applied before service resolves', () async {
      final quest = makeQuest(id: 'q1', status: QuestStatus.available);

      // Completer-based joinQuestImpl so we can inspect state mid-flight.
      QuestStatus? statusDuringJoin;
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [quest]
        ..getMyQuestsImpl = () async => []
        ..joinQuestImpl = (id) async {
          // At this point the optimistic update should already be applied.
          statusDuringJoin = notifier.state.quests.first.status;
        };

      final notifier = QuestsNotifier(fakeService, 'user-1');
      await Future<void>.delayed(Duration.zero);

      // Re-stub so getMyQuests returns inProgress after join.
      fakeService.getMyQuestsImpl = () async =>
          [quest.copyWith(status: QuestStatus.inProgress)];

      await notifier.joinQuest('q1');

      expect(statusDuringJoin, QuestStatus.inProgress);

      notifier.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // QuestsNotifier.clearError()
  // ──────────────────────────────────────────────────────────────────────────
  group('QuestsNotifier.clearError()', () {
    test('clears an existing error while preserving quests and isLoading', () async {
      final quest = makeQuest();
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [quest]
        ..getMyQuestsImpl = () async => throw Exception('Partial failure');

      final notifier = QuestsNotifier(fakeService, 'user-1');
      await Future<void>.delayed(Duration.zero);

      // Verify an error is set first.
      expect(notifier.state.error, isNotNull);

      notifier.clearError();

      expect(notifier.state.error, isNull);
      // Quests and loading flag should be preserved.
      expect(notifier.state.quests, hasLength(1));
      expect(notifier.state.isLoading, isFalse);

      notifier.dispose();
    });

    test('clearError on a state with no error is a no-op', () async {
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [makeQuest()]
        ..getMyQuestsImpl = () async => [];

      final notifier = QuestsNotifier(fakeService, 'user-1');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.error, isNull);
      notifier.clearError();
      expect(notifier.state.error, isNull);

      notifier.dispose();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // ProviderContainer wiring
  // ──────────────────────────────────────────────────────────────────────────
  group('ProviderContainer overrides', () {
    test('questsProvider uses overridden questsServiceProvider', () async {
      final quest = makeQuest(title: 'Override Quest');
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [quest];

      final container = buildContainer(fakeService);
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(container.read(questsProvider).quests.first.title, 'Override Quest');
      expect(fakeService.getAllQuestsCalled, 1);
    });

    test('questsProvider with authenticated user calls getMyQuests', () async {
      final fakeService = _FakeQuestsService()
        ..getAllQuestsImpl = () async => [makeQuest()]
        ..getMyQuestsImpl = () async => [];

      final container = buildContainer(fakeService, userId: 'authenticated-user');
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(fakeService.getMyQuestsCalled, 1);
    });
  });
}
