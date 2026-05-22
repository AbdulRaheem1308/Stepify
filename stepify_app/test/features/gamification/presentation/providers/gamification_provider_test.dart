import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/gamification/presentation/providers/gamification_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late GamificationNotifier notifier;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApi = MockApiService();
    
    when(() => mockApi.get('/rewards/levels')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/levels'),
      data: <dynamic>[],
    ));
    when(() => mockApi.get('/users/me/stats')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/users/me/stats'),
      data: {},
    ));
    when(() => mockApi.get('/rewards/transactions?limit=5')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/transactions'),
      data: {'data': []},
    ));
    when(() => mockApi.get('/rewards/streak')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/streak'),
      data: {'currentStreak': 5},
    ));
    when(() => mockApi.get('/rewards/wallet')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/wallet'),
      data: {'monthlyXp': 1200},
    ));

    notifier = GamificationNotifier(mockApi);
  });

  test('fetchGamificationData computes level and xp correctly', () async {
    // Wait for the initial load
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.level, 2); // 1200 XP -> level 2 (requires 1000 for level 2, then has 200/1500)
    expect(notifier.state.currentXp, 200);
    expect(notifier.state.nextLevelXp, 1500);
    expect(notifier.state.currentStreak, 5);
  });
}
