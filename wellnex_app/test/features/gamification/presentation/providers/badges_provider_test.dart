import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/features/gamification/presentation/providers/badges_provider.dart';

class MockApiService extends ApiService {
  bool shouldFail = false;

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (shouldFail) {
      throw Exception('API failed');
    }
    if (path == '/rewards/achievements') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: [
          {
            "id": "b1",
            "name": "Step Master",
            "description": "Walk 1000 steps",
            "category": "STEPS",
            "stepsRequired": 1000,
            "unlocked": true,
            "progress": 100
          },
          {
            "id": "b2",
            "name": "Streak Hero",
            "description": "Maintain a 7-day streak",
            "category": "STREAK",
            "streakRequired": 7,
            "unlocked": false,
            "progress": 50,
            "currentValue": 3,
            "pointsReward": 50
          },
          {
            "id": "b3",
            "name": "Challenge Champ",
            "description": "Complete 1 challenge",
            "category": "CHALLENGE",
            "targetValue": 1,
            "unlocked": false,
            "progress": 0
          },
          {
            "id": "b4",
            "name": "Social Butterfly",
            "description": "Add 3 friends",
            "category": "SOCIAL",
            "targetValue": 3,
            "unlocked": false,
            "progress": 33
          },
          {
            "id": "b5",
            "name": "Coin Collector",
            "description": "Earn 1000 coins",
            "category": "COINS",
            "targetValue": 1000,
            "unlocked": true,
            "progress": 100
          },
          {
            "id": "b6",
            "name": "Community Pillar",
            "description": "Post in community",
            "category": "COMMUNITY",
            "unlocked": false,
            "progress": 0
          },
          {
            "id": "b7",
            "name": "Secret",
            "description": "Secret Badge",
            "category": "SPECIAL",
            "unlocked": false,
            "progress": 0
          }
        ],
        statusCode: 200,
      );
    }
    throw Exception('Not mocked path: $path');
  }
}

void main() {
  group('Badge.fromJson parsing & category logic', () {
    test('parses STEPS category correctly', () {
      final badge = Badge.fromJson({
        "id": "1",
        "name": "Walker",
        "category": "STEPS",
        "stepsRequired": 1500000,
        "unlocked": true,
        "progress": 100
      });
      expect(badge.id, '1');
      expect(badge.title, 'Walker');
      expect(badge.category, 'STEPS');
      expect(badge.status, BadgeStatus.unlocked);
      expect(badge.unlockCriteria, 'Walk 1.5M total lifetime steps');
      expect(badge.howToEarn, contains('1.5M'));
    });

    test('parses STREAK category correctly', () {
      final badge = Badge.fromJson({
        "category": "STREAK",
        "streakRequired": 30,
        "progress": 10
      });
      expect(badge.status, BadgeStatus.inProgress);
      expect(badge.unlockCriteria, 'Maintain a 30-day walking streak');
      expect(badge.howToEarn, contains('30 consecutive days'));
    });

    test('parses CHALLENGE category correctly', () {
      final badge = Badge.fromJson({
        "category": "CHALLENGE",
        "targetValue": 5,
        "progress": 0
      });
      expect(badge.status, BadgeStatus.locked);
      expect(badge.unlockCriteria, 'Complete 5 challenges');
      expect(badge.howToEarn, contains('5 challenges'));
    });

    test('parses SOCIAL category correctly', () {
      final badge = Badge.fromJson({
        "category": "SOCIAL",
        "targetValue": 1,
        "progress": 0
      });
      expect(badge.unlockCriteria, 'Add 1 friend on Well Nex');
      expect(badge.howToEarn, contains('1 accepted friend connection'));
    });

    test('parses COINS category correctly', () {
      final badge = Badge.fromJson({
        "category": "COINS",
        "targetValue": 5000,
      });
      expect(badge.unlockCriteria, 'Earn 5k lifetime coins');
      expect(badge.howToEarn, contains('5k total coins earned'));
    });

    test('parses COMMUNITY category correctly', () {
      final badge = Badge.fromJson({
        "category": "COMMUNITY",
      });
      expect(badge.unlockCriteria, 'Participate in the Well Nex community');
      expect(badge.howToEarn, contains('Join and post'));
    });

    test('parses default/SPECIAL category correctly', () {
      final badge = Badge.fromJson({
        "category": "MYSTERY",
        "description": "Do something cool",
      });
      expect(badge.unlockCriteria, 'Do something cool');
      expect(badge.howToEarn, 'Do something cool');
    });
  });

  group('BadgesState & copyWith', () {
    test('initial state', () {
      final state = BadgesState();
      expect(state.badges, isEmpty);
      expect(state.activeFilter, 'All');
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates values', () {
      final state = BadgesState().copyWith(
        badges: [Badge(id: '1', title: 'Test', description: '', status: BadgeStatus.locked, unlockCriteria: '', howToEarn: '', category: '')],
        activeFilter: 'Earned',
        isLoading: true,
        error: 'Failed',
      );
      expect(state.badges.length, 1);
      expect(state.activeFilter, 'Earned');
      expect(state.isLoading, true);
      expect(state.error, 'Failed');
    });
  });

  group('BadgesNotifier', () {
    late ProviderContainer container;
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading and then fetches badges', () async {
      final notifier = container.read(badgesProvider.notifier);
      await notifier.loadBadges();
      
      final state = container.read(badgesProvider);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.badges.length, 7);
      expect(state.badges.first.id, 'b1');
    });

    test('loadBadges handles errors', () async {
      mockApi.shouldFail = true;
      final notifier = container.read(badgesProvider.notifier);
      await notifier.loadBadges();
      
      final state = container.read(badgesProvider);
      expect(state.isLoading, false);
      expect(state.error, isNotNull);
      expect(state.badges, isEmpty);
    });

    test('setFilter updates activeFilter', () async {
      final notifier = container.read(badgesProvider.notifier);
      notifier.setFilter('Locked');
      
      final state = container.read(badgesProvider);
      expect(state.activeFilter, 'Locked');
    });
  });
}
