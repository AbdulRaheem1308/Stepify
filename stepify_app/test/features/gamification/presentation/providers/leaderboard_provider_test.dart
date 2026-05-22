import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/gamification/presentation/providers/leaderboard_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late LeaderboardNotifier notifier;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApi = MockApiService();
  });

  test('fetchLeaderboard parses and sorts entries correctly', () async {
    when(() => mockApi.get(any())).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends/leaderboard?type=global&timeFrame=weekly'),
      data: <dynamic>[
        {
          'id': 'u2',
          'name': 'Bob',
          'lifetimeSteps': 20000,
          'isCurrentUser': false
        },
        {
          'id': 'u1',
          'name': 'Alice',
          'lifetimeSteps': 50000,
          'isCurrentUser': true
        }
      ],
    ));

    notifier = LeaderboardNotifier(mockApi);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.entries.length, 2);
    // Alice should be first because 50000 > 20000
    expect(notifier.state.entries[0].username, 'Alice');
    expect(notifier.state.entries[0].rank, 1);
    expect(notifier.state.entries[1].username, 'Bob');
    expect(notifier.state.entries[1].rank, 2);
    expect(notifier.state.currentUserEntry?.username, 'Alice');
  });

  test('setType updates type and re-fetches', () async {
    when(() => mockApi.get(any())).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/'),
      data: <dynamic>[],
    ));

    notifier = LeaderboardNotifier(mockApi);
    await notifier.setType(LeaderboardType.friends);

    expect(notifier.state.type, LeaderboardType.friends);
    verify(() => mockApi.get('/friends/leaderboard?type=friends&timeFrame=weekly')).called(1);
  });
}
