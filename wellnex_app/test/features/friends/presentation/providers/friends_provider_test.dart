import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/features/friends/presentation/providers/friends_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late FriendsNotifier notifier;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApi = MockApiService();
    notifier = FriendsNotifier(mockApi);
  });

  test('fetchFriendsData populates state correctly', () async {
    when(() => mockApi.get('/friends')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends'),
      data: <dynamic>[
        {
          'id': 'f1',
          'name': 'Alice',
          'dailyStepCount': 5000,
          'boostSentToday': false,
        }
      ],
    ));
    when(() => mockApi.get('/friends/leaderboard')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends/leaderboard'),
      data: <dynamic>[
        {
          'id': 'f1',
          'name': 'Alice',
          'dailyStepCount': 5000,
          'rank': 1,
          'isTopFriend': true,
        }
      ],
    ));

    await notifier.fetchFriendsData();

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.friends.length, 1);
    expect(notifier.state.friends.first.name, 'Alice');
    expect(notifier.state.leaderboard.length, 1);
    expect(notifier.state.leaderboard.first.rank, 1);
  });

  test('searchUsers updates searchResults when query >= 2 chars', () async {
    when(() => mockApi.get('/friends/search?q=Bob')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends/search?q=Bob'),
      data: <dynamic>[
        {
          'id': 'u1',
          'name': 'Bob',
          'friendshipStatus': null,
        }
      ],
    ));

    await notifier.searchUsers('Bob');

    expect(notifier.state.searchResults.length, 1);
    expect(notifier.state.searchResults.first.name, 'Bob');
  });

  test('searchUsers clears results when query < 2 chars', () async {
    notifier = FriendsNotifier(mockApi)..searchUsers('a'); // Sets state synchronously

    expect(notifier.state.searchResults, isEmpty);
    verifyNever(() => mockApi.get(any()));
  });

  test('sendFriendRequest returns true on success', () async {
    when(() => mockApi.post('/friends/request', data: any(named: 'data'))).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends/request'),
      data: {},
    ));

    final result = await notifier.sendFriendRequest('u1');
    expect(result, isTrue);
    verify(() => mockApi.post('/friends/request', data: {'friendId': 'u1'})).called(1);
  });

  test('sendBoost returns true on success and reloads friends data', () async {
    when(() => mockApi.post('/friends/boost', data: any(named: 'data'))).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends/boost'),
      data: {},
    ));
    when(() => mockApi.get('/friends')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends'),
      data: <dynamic>[],
    ));
    when(() => mockApi.get('/friends/leaderboard')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/friends/leaderboard'),
      data: <dynamic>[],
    ));

    final result = await notifier.sendBoost('f1');
    expect(result, isTrue);
    verify(() => mockApi.post('/friends/boost', data: {'friendId': 'f1'})).called(1);
    verify(() => mockApi.get('/friends')).called(1); // from fetchFriendsData
  });
}
