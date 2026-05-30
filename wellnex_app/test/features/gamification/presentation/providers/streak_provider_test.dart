import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/features/gamification/presentation/providers/streak_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late StreakNotifier notifier;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApi = MockApiService();
  });

  test('fetchStreakData populates state correctly', () async {
    when(() => mockApi.get('/rewards/streak')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/streak'),
      data: {
        'currentStreak': 10,
        'longestStreak': 20,
      },
    ));
    when(() => mockApi.get('/steps/history?limit=180')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/steps/history?limit=180'),
      data: <dynamic>[
        {
          'date': '2023-01-01T00:00:00Z',
          'stepCount': 5000,
        },
        {
          'date': '2023-01-02T00:00:00Z',
          'stepCount': 8000,
        }
      ],
    ));

    notifier = StreakNotifier(mockApi);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.currentStreak, 10);
    expect(notifier.state.longestStreak, 20);
    expect(notifier.state.activeDates.length, 2);
    expect(notifier.state.activeDates[0].year, 2023);
  });
}
