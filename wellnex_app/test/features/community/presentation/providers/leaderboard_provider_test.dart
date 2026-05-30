import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/features/community/presentation/providers/leaderboard_provider.dart';

void main() {
  group('LeaderboardNotifier', () {
    test('initial state is empty list', () {
      final notifier = LeaderboardNotifier();
      expect(notifier.state, isEmpty);
      notifier.dispose();
    });

    test('LeaderboardUser.fromJson parses correctly', () {
      final json = {
        'rank': 1,
        'userId': 'u1',
        'name': 'John',
        'avatarUrl': 'http://example.com/a.png',
        'fitnessLevel': 'Advanced',
        'stepCount': 10000,
        'calories': 500,
      };

      final user = LeaderboardUser.fromJson(json);

      expect(user.rank, 1);
      expect(user.userId, 'u1');
      expect(user.name, 'John');
      expect(user.avatarUrl, 'http://example.com/a.png');
      expect(user.fitnessLevel, 'Advanced');
      expect(user.stepCount, 10000);
      expect(user.calories, 500);
    });
  });
}
