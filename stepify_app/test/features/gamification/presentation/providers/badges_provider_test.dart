// Comprehensive unit tests for:
//   - Badge.fromJson()  — every category branch + status logic + _formatNumber
//   - BadgesState       — initial values, copyWith
//   - BadgesNotifier    — initial state, loadBadges success/failure, setFilter
//
// Uses mocktail (already a dev-dependency) for the ApiService mock.
// Uses a ProviderContainer to exercise the real Riverpod wiring.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/gamification/presentation/providers/badges_provider.dart';
import 'package:stepify_app/services/api_service.dart';

// ── Manual-style mock via mocktail ────────────────────────────────────────────

class MockApiService extends Mock implements ApiService {}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Creates a minimal [Response] whose [data] is [body].
Response<dynamic> _response(dynamic body, {String path = '/rewards/achievements'}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: body,
  );
}

/// Creates a [DioException] that simulates a network-level failure.
DioException _networkError({String path = '/rewards/achievements'}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: DioExceptionType.connectionError,
    message: 'Connection refused',
  );
}

/// Builds a [ProviderContainer] with [mockApi] injected for [apiServiceProvider].
ProviderContainer _container(MockApiService mockApi) {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(mockApi),
    ],
  );
}

// ── Base JSON helpers ─────────────────────────────────────────────────────────

Map<String, dynamic> _baseJson({
  String id = 'badge-1',
  String name = 'Test Badge',
  String description = 'A test badge',
  String category = 'STEPS',
  bool unlocked = false,
  int progress = 0,
  String? unlockedAt,
  int? stepsRequired,
  int? streakRequired,
  int? targetValue,
  int? currentValue,
  int? pointsReward,
  String? icon,
}) {
  return {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'unlocked': unlocked,
    'progress': progress,
    if (unlockedAt != null) 'unlockedAt': unlockedAt,
    if (stepsRequired != null) 'stepsRequired': stepsRequired,
    if (streakRequired != null) 'streakRequired': streakRequired,
    if (targetValue != null) 'targetValue': targetValue,
    if (currentValue != null) 'currentValue': currentValue,
    if (pointsReward != null) 'pointsReward': pointsReward,
    if (icon != null) 'icon': icon,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  // ── Badge.fromJson ──────────────────────────────────────────────────────────

  group('Badge.fromJson', () {
    // ── Status logic ──────────────────────────────────────────────────────────

    group('status logic', () {
      test('unlocked=true → BadgeStatus.unlocked regardless of progress', () {
        final badge = Badge.fromJson(
          _baseJson(unlocked: true, progress: 50, stepsRequired: 1000),
        );
        expect(badge.status, BadgeStatus.unlocked);
      });

      test('unlocked=false, progress>0 → BadgeStatus.inProgress', () {
        final badge = Badge.fromJson(
          _baseJson(unlocked: false, progress: 40, stepsRequired: 1000),
        );
        expect(badge.status, BadgeStatus.inProgress);
        expect(badge.progress, closeTo(0.4, 0.001));
      });

      test('unlocked=false, progress=0 → BadgeStatus.locked', () {
        final badge = Badge.fromJson(
          _baseJson(unlocked: false, progress: 0, stepsRequired: 1000),
        );
        expect(badge.status, BadgeStatus.locked);
        expect(badge.progress, 0.0);
      });

      test('progress=100 and unlocked=false → BadgeStatus.inProgress (100%)', () {
        final badge = Badge.fromJson(
          _baseJson(unlocked: false, progress: 100, stepsRequired: 500),
        );
        expect(badge.status, BadgeStatus.inProgress);
        expect(badge.progress, closeTo(1.0, 0.001));
      });

      test('progress is clamped to [0.0, 1.0] (no over-100 values)', () {
        final badge = Badge.fromJson(
          _baseJson(unlocked: false, progress: 150, stepsRequired: 500),
        );
        expect(badge.progress, closeTo(1.0, 0.001));
      });

      test('earnedDate is parsed when unlockedAt is present', () {
        final badge = Badge.fromJson(
          _baseJson(unlocked: true, unlockedAt: '2024-03-15T12:00:00Z'),
        );
        expect(badge.earnedDate, isNotNull);
        expect(badge.earnedDate!.year, 2024);
        expect(badge.earnedDate!.month, 3);
        expect(badge.earnedDate!.day, 15);
      });

      test('earnedDate is null when unlockedAt is absent', () {
        final badge = Badge.fromJson(_baseJson(unlocked: false));
        expect(badge.earnedDate, isNull);
      });
    });

    // ── Category: STEPS ───────────────────────────────────────────────────────

    group('category STEPS', () {
      test('uses stepsRequired for targetValue and criteria', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 10000),
        );
        expect(badge.category, 'STEPS');
        expect(badge.unlockCriteria, contains('10k'));
        expect(badge.howToEarn, contains('10k'));
        expect(badge.targetValue, 10000);
      });

      test('falls back to targetValue when stepsRequired is absent', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', targetValue: 5000),
        );
        expect(badge.unlockCriteria, contains('5k'));
        expect(badge.targetValue, 5000);
      });

      test('goal=0 when neither stepsRequired nor targetValue is set', () {
        final badge = Badge.fromJson(_baseJson(category: 'STEPS'));
        expect(badge.unlockCriteria, contains('0'));
        expect(badge.targetValue, isNull);
      });

      test('category lookup is case-insensitive (lowercase "steps")', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'steps', stepsRequired: 2000),
        );
        expect(badge.unlockCriteria, contains('2k'));
      });
    });

    // ── Category: STREAK ─────────────────────────────────────────────────────

    group('category STREAK', () {
      test('uses streakRequired for days in criteria', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STREAK', streakRequired: 7),
        );
        expect(badge.category, 'STREAK');
        expect(badge.unlockCriteria, contains('7'));
        expect(badge.unlockCriteria, contains('day'));
        expect(badge.howToEarn, contains('7'));
        expect(badge.targetValue, 7);
      });

      test('falls back to targetValue when streakRequired is absent', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STREAK', targetValue: 30),
        );
        expect(badge.unlockCriteria, contains('30'));
        expect(badge.targetValue, 30);
      });

      test('defaults to 0 days when no value provided', () {
        final badge = Badge.fromJson(_baseJson(category: 'STREAK'));
        expect(badge.unlockCriteria, contains('0'));
      });
    });

    // ── Category: CHALLENGE ───────────────────────────────────────────────────

    group('category CHALLENGE', () {
      test('singular when count=1', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'CHALLENGE', targetValue: 1),
        );
        expect(badge.category, 'CHALLENGE');
        expect(badge.unlockCriteria, contains('1 challenge'));
        // Should NOT contain "challenges" (plural)
        expect(badge.unlockCriteria, isNot(contains('challenges')));
        expect(badge.targetValue, 1);
      });

      test('plural when count>1', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'CHALLENGE', targetValue: 5),
        );
        expect(badge.unlockCriteria, contains('5 challenges'));
        expect(badge.howToEarn, contains('5 challenges'));
      });

      test('defaults to 1 when targetValue is absent', () {
        final badge = Badge.fromJson(_baseJson(category: 'CHALLENGE'));
        expect(badge.unlockCriteria, contains('1 challenge'));
      });
    });

    // ── Category: SOCIAL ─────────────────────────────────────────────────────

    group('category SOCIAL', () {
      test('singular when friends=1', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'SOCIAL', targetValue: 1),
        );
        expect(badge.category, 'SOCIAL');
        expect(badge.unlockCriteria, contains('1 friend'));
        expect(badge.unlockCriteria, isNot(contains('friends')));
        expect(badge.targetValue, 1);
      });

      test('plural when friends>1', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'SOCIAL', targetValue: 10),
        );
        expect(badge.unlockCriteria, contains('10 friends'));
        expect(badge.howToEarn, contains('10 accepted friend connections'));
      });

      test('defaults to 1 when targetValue is absent', () {
        final badge = Badge.fromJson(_baseJson(category: 'SOCIAL'));
        expect(badge.unlockCriteria, contains('1 friend'));
      });
    });

    // ── Category: COINS ───────────────────────────────────────────────────────

    group('category COINS', () {
      test('uses targetValue for coin count', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'COINS', targetValue: 1000000),
        );
        expect(badge.category, 'COINS');
        expect(badge.unlockCriteria, contains('1.0M'));
        expect(badge.howToEarn, contains('1.0M'));
        expect(badge.targetValue, 1000000);
      });

      test('falls back to stepsRequired when targetValue absent', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'COINS', stepsRequired: 500),
        );
        expect(badge.unlockCriteria, contains('500'));
        expect(badge.targetValue, 500);
      });

      test('defaults to 0 when neither value present', () {
        final badge = Badge.fromJson(_baseJson(category: 'COINS'));
        expect(badge.unlockCriteria, contains('0'));
      });
    });

    // ── Category: COMMUNITY ───────────────────────────────────────────────────

    group('category COMMUNITY', () {
      test('criteria and howToEarn contain community text', () {
        final badge = Badge.fromJson(_baseJson(category: 'COMMUNITY'));
        expect(badge.category, 'COMMUNITY');
        expect(badge.unlockCriteria.toLowerCase(), contains('community'));
        expect(badge.howToEarn.toLowerCase(), contains('community'));
      });

      test('targetValue is null (not set by COMMUNITY branch)', () {
        final badge = Badge.fromJson(_baseJson(category: 'COMMUNITY'));
        expect(badge.targetValue, isNull);
      });
    });

    // ── Default / unknown category ────────────────────────────────────────────

    group('category default (unknown)', () {
      test('uses description for criteria and howToEarn', () {
        final badge = Badge.fromJson(
          _baseJson(
            category: 'SPECIAL',
            description: 'Very special badge requirement',
          ),
        );
        expect(badge.unlockCriteria, 'Very special badge requirement');
        expect(badge.howToEarn, 'Very special badge requirement');
      });

      test('falls back gracefully when description is missing', () {
        final json = _baseJson(category: 'MYSTERY')..remove('description');
        final badge = Badge.fromJson(json);
        expect(badge.unlockCriteria, 'Complete the special requirement');
        expect(badge.howToEarn, 'Follow special in-app events to earn this badge.');
      });
    });

    // ── Scalar fields ─────────────────────────────────────────────────────────

    group('scalar fields', () {
      test('id, title, description, category are mapped from JSON keys', () {
        final badge = Badge.fromJson(
          _baseJson(
            id: 'badge-99',
            name: 'Century Walker',
            description: 'Walk 100 miles',
            category: 'STEPS',
            stepsRequired: 160934,
          ),
        );
        expect(badge.id, 'badge-99');
        expect(badge.title, 'Century Walker');
        expect(badge.description, 'Walk 100 miles');
        expect(badge.category, 'STEPS');
      });

      test('defaults apply when optional fields are absent', () {
        final badge = Badge.fromJson({
          'id': 'x',
          'name': 'X',
          'description': 'desc',
          'category': 'STEPS',
        });
        expect(badge.icon, 'emoji_events');
        expect(badge.pointsReward, 0);
        expect(badge.currentValue, 0);
        expect(badge.progress, 0.0);
        expect(badge.status, BadgeStatus.locked);
      });

      test('pointsReward and currentValue are parsed correctly', () {
        final badge = Badge.fromJson(
          _baseJson(
            category: 'STEPS',
            stepsRequired: 5000,
            pointsReward: 250,
            currentValue: 3000,
          ),
        );
        expect(badge.pointsReward, 250);
        expect(badge.currentValue, 3000);
      });

      test('custom icon is used when provided', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 100, icon: 'star'),
        );
        expect(badge.icon, 'star');
      });

      test('id defaults to empty string when absent', () {
        final json = _baseJson(category: 'COMMUNITY')..remove('id');
        final badge = Badge.fromJson(json);
        expect(badge.id, '');
      });
    });

    // ── _formatNumber ─────────────────────────────────────────────────────────

    group('_formatNumber (via criteria strings)', () {
      test('numbers < 1000 are rendered as-is', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 999),
        );
        expect(badge.unlockCriteria, contains('999'));
      });

      test('exact 1000 → "1k" (no decimal)', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 1000),
        );
        expect(badge.unlockCriteria, contains('1k'));
      });

      test('1500 → "1.5k"', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 1500),
        );
        expect(badge.unlockCriteria, contains('1.5k'));
      });

      test('10000 → "10k"', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 10000),
        );
        expect(badge.unlockCriteria, contains('10k'));
      });

      test('1000000 → "1.0M"', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'COINS', targetValue: 1000000),
        );
        expect(badge.unlockCriteria, contains('1.0M'));
      });

      test('2500000 → "2.5M"', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'COINS', targetValue: 2500000),
        );
        expect(badge.unlockCriteria, contains('2.5M'));
      });

      test('0 → "0"', () {
        final badge = Badge.fromJson(_baseJson(category: 'STEPS'));
        expect(badge.unlockCriteria, contains('0'));
      });
    });
  });

  // ── BadgesState ─────────────────────────────────────────────────────────────

  group('BadgesState', () {
    test('default constructor has correct initial values', () {
      final state = BadgesState();
      expect(state.badges, isEmpty);
      expect(state.activeFilter, 'All');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    group('copyWith', () {
      test('returns new instance with updated badges', () {
        final state = BadgesState();
        final badge = Badge.fromJson(
          _baseJson(category: 'STEPS', stepsRequired: 1000, unlocked: true),
        );
        final updated = state.copyWith(badges: [badge]);
        expect(updated.badges, hasLength(1));
        expect(updated.badges.first.id, badge.id);
        // other fields unchanged
        expect(updated.activeFilter, 'All');
        expect(updated.isLoading, isFalse);
        expect(updated.error, isNull);
      });

      test('returns new instance with updated activeFilter', () {
        final state = BadgesState();
        final updated = state.copyWith(activeFilter: 'STEPS');
        expect(updated.activeFilter, 'STEPS');
        expect(updated.badges, isEmpty);
      });

      test('returns new instance with isLoading=true', () {
        final state = BadgesState();
        final updated = state.copyWith(isLoading: true);
        expect(updated.isLoading, isTrue);
        expect(updated.error, isNull);
      });

      test('copyWith always clears error when not provided (null)', () {
        // The implementation: error: error (always replaces, no ?? this.error)
        final state = BadgesState(error: 'previous error');
        final updated = state.copyWith(isLoading: false);
        expect(updated.error, isNull); // error not carried forward
      });

      test('copyWith sets error when provided', () {
        final state = BadgesState();
        final updated = state.copyWith(error: 'something went wrong');
        expect(updated.error, 'something went wrong');
      });

      test('copyWith preserves all fields when no args passed', () {
        final badge = Badge.fromJson(
          _baseJson(category: 'COMMUNITY', unlocked: true),
        );
        final state = BadgesState(
          badges: [badge],
          activeFilter: 'COMMUNITY',
          isLoading: false,
          error: 'err',
        );
        final updated = state.copyWith();
        expect(updated.badges, same(state.badges));
        expect(updated.activeFilter, 'COMMUNITY');
        expect(updated.isLoading, isFalse);
        // error is always overwritten to null in copyWith() when not supplied
        expect(updated.error, isNull);
      });
    });
  });

  // ── BadgesNotifier ───────────────────────────────────────────────────────────

  group('BadgesNotifier', () {
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
    });

    // ── Initial state (before constructor finishes async work) ─────────────────

    test('initial state has correct defaults before loadBadges resolves', () {
      // Stub to a never-resolving future so we can inspect pre-load state.
      when(() => mockApi.get('/rewards/achievements'))
          .thenAnswer((_) => Completer<Response<dynamic>>().future);

      final notifier = BadgesNotifier(mockApi);
      // isLoading should be true (set synchronously at start of loadBadges)
      expect(notifier.state.isLoading, isTrue);
      expect(notifier.state.badges, isEmpty);
      expect(notifier.state.error, isNull);
      expect(notifier.state.activeFilter, 'All');
    });

    // ── loadBadges — success ───────────────────────────────────────────────────

    group('loadBadges success', () {
      test('populates badges and sets isLoading=false', () async {
        when(() => mockApi.get('/rewards/achievements')).thenAnswer((_) async =>
            _response(<dynamic>[
              _baseJson(
                id: 'b1',
                name: 'First Step',
                category: 'STEPS',
                stepsRequired: 100,
                unlocked: true,
                unlockedAt: '2024-01-01T00:00:00Z',
              ),
              _baseJson(
                id: 'b2',
                name: '10k Club',
                category: 'STEPS',
                stepsRequired: 10000,
                unlocked: false,
                progress: 50,
              ),
            ]));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.badges, hasLength(2));

        final first = notifier.state.badges[0];
        expect(first.id, 'b1');
        expect(first.status, BadgeStatus.unlocked);
        expect(first.earnedDate, isNotNull);

        final second = notifier.state.badges[1];
        expect(second.id, 'b2');
        expect(second.status, BadgeStatus.inProgress);
        expect(second.progress, closeTo(0.5, 0.001));
      });

      test('handles empty list gracefully', () async {
        when(() => mockApi.get('/rewards/achievements'))
            .thenAnswer((_) async => _response(<dynamic>[]));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.badges, isEmpty);
        expect(notifier.state.error, isNull);
      });

      test('parses mixed categories in one response', () async {
        when(() => mockApi.get('/rewards/achievements')).thenAnswer((_) async =>
            _response(<dynamic>[
              _baseJson(id: 'c1', category: 'STEPS', stepsRequired: 5000),
              _baseJson(id: 'c2', category: 'STREAK', streakRequired: 7),
              _baseJson(id: 'c3', category: 'CHALLENGE', targetValue: 3),
              _baseJson(id: 'c4', category: 'SOCIAL', targetValue: 5),
              _baseJson(id: 'c5', category: 'COINS', targetValue: 10000),
              _baseJson(id: 'c6', category: 'COMMUNITY'),
              _baseJson(id: 'c7', category: 'UNKNOWN'),
            ]));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.badges, hasLength(7));
        expect(notifier.state.isLoading, isFalse);
      });

      test('via ProviderContainer — badgesProvider wires ApiService correctly',
          () async {
        when(() => mockApi.get('/rewards/achievements')).thenAnswer((_) async =>
            _response(<dynamic>[
              _baseJson(id: 'p1', category: 'COMMUNITY', unlocked: true),
            ]));

        final container = _container(mockApi);
        addTearDown(container.dispose);

        // Read the provider to trigger construction
        container.read(badgesProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(badgesProvider);
        expect(state.badges, hasLength(1));
        expect(state.badges.first.id, 'p1');
        expect(state.isLoading, isFalse);
      });
    });

    // ── loadBadges — failure ───────────────────────────────────────────────────

    group('loadBadges failure', () {
      test('sets error message and isLoading=false on DioException', () async {
        when(() => mockApi.get('/rewards/achievements'))
            .thenThrow(_networkError());

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.error, isNotEmpty);
        // Badges stay empty on failure
        expect(notifier.state.badges, isEmpty);
      });

      test('sets error message on generic Exception', () async {
        when(() => mockApi.get('/rewards/achievements'))
            .thenThrow(Exception('Custom network failure'));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.error, contains('Custom network failure'));
      });

      test('sets error message when data is not a List (cast failure)', () async {
        // API returns a Map instead of a List — will trigger a TypeError
        when(() => mockApi.get('/rewards/achievements'))
            .thenAnswer((_) async => _response(<String, dynamic>{'error': 'bad'}));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNotNull);
        // The generic ApiError.from handler should mark it as an app error
        expect(notifier.state.error, isNotEmpty);
      });

      test('via ProviderContainer — error state propagates through provider',
          () async {
        when(() => mockApi.get('/rewards/achievements'))
            .thenThrow(Exception('Server is down'));

        final container = _container(mockApi);
        addTearDown(container.dispose);

        container.read(badgesProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(badgesProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNotNull);
        expect(state.badges, isEmpty);
      });
    });

    // ── setFilter ─────────────────────────────────────────────────────────────

    group('setFilter', () {
      late BadgesNotifier notifier;

      setUp(() async {
        when(() => mockApi.get('/rewards/achievements'))
            .thenAnswer((_) async => _response(<dynamic>[]));

        notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('activeFilter starts as "All"', () {
        expect(notifier.state.activeFilter, 'All');
      });

      test('setFilter updates activeFilter', () {
        notifier.setFilter('STEPS');
        expect(notifier.state.activeFilter, 'STEPS');
      });

      test('setFilter can be called multiple times', () {
        notifier.setFilter('STREAK');
        expect(notifier.state.activeFilter, 'STREAK');

        notifier.setFilter('SOCIAL');
        expect(notifier.state.activeFilter, 'SOCIAL');

        notifier.setFilter('All');
        expect(notifier.state.activeFilter, 'All');
      });

      test('setFilter does not affect badges or isLoading', () async {
        // Load some badges first
        when(() => mockApi.get('/rewards/achievements')).thenAnswer((_) async =>
            _response(<dynamic>[
              _baseJson(id: 'x1', category: 'STEPS', stepsRequired: 1000),
            ]));

        await notifier.loadBadges();

        notifier.setFilter('COINS');

        expect(notifier.state.activeFilter, 'COINS');
        expect(notifier.state.badges, hasLength(1));
        expect(notifier.state.isLoading, isFalse);
      });
    });

    // ── Manual re-invocation of loadBadges ────────────────────────────────────

    group('manual loadBadges re-invocation', () {
      test('refreshes badge list on subsequent call', () async {
        // First call returns 1 badge
        when(() => mockApi.get('/rewards/achievements'))
            .thenAnswer((_) async => _response(<dynamic>[
                  _baseJson(id: 'r1', category: 'COMMUNITY'),
                ]));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.state.badges, hasLength(1));

        // Second call returns 2 badges
        when(() => mockApi.get('/rewards/achievements'))
            .thenAnswer((_) async => _response(<dynamic>[
                  _baseJson(id: 'r1', category: 'COMMUNITY'),
                  _baseJson(id: 'r2', category: 'SOCIAL', targetValue: 3),
                ]));

        await notifier.loadBadges();
        expect(notifier.state.badges, hasLength(2));
        expect(notifier.state.isLoading, isFalse);
      });

      test('recovers from error state on successful retry', () async {
        // First call fails
        when(() => mockApi.get('/rewards/achievements'))
            .thenThrow(Exception('Temporary error'));

        final notifier = BadgesNotifier(mockApi);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.state.error, isNotNull);

        // Second call succeeds
        when(() => mockApi.get('/rewards/achievements'))
            .thenAnswer((_) async => _response(<dynamic>[
                  _baseJson(id: 's1', category: 'STREAK', streakRequired: 14),
                ]));

        await notifier.loadBadges();
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.badges, hasLength(1));
        // error is cleared by copyWith on success path
      });
    });
  });
}
