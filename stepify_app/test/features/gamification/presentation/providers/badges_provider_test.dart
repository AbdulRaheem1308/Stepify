import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/gamification/presentation/providers/badges_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late BadgesNotifier notifier;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApi = MockApiService();
  });

  test('loadBadges populates state correctly', () async {
    when(() => mockApi.get('/rewards/achievements')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/achievements'),
      data: <dynamic>[
        {
          'id': 'b1',
          'name': 'First Step',
          'description': 'Take 100 steps',
          'unlocked': true,
          'unlockedAt': '2023-01-01T00:00:00Z',
          'category': 'Fitness'
        },
        {
          'id': 'b2',
          'name': '10k',
          'description': 'Take 10k steps',
          'unlocked': false,
          'progress': 50,
          'category': 'Fitness'
        }
      ],
    ));

    notifier = BadgesNotifier(mockApi);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.badges.length, 2);
    expect(notifier.state.badges[0].status, BadgeStatus.unlocked);
    expect(notifier.state.badges[1].status, BadgeStatus.inProgress);
    expect(notifier.state.badges[1].progress, 0.5);
  });

  test('setFilter updates active filter', () async {
    when(() => mockApi.get('/rewards/achievements')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/achievements'),
      data: <dynamic>[],
    ));

    notifier = BadgesNotifier(mockApi);
    notifier.setFilter('Fitness');

    expect(notifier.state.activeFilter, 'Fitness');
  });
}
