import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/features/challenges/presentation/providers/challenges_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late ChallengesNotifier notifier;

  setUp(() {
    mockApiService = MockApiService();
    notifier = ChallengesNotifier(mockApiService);
  });

  group('ChallengesNotifier', () {
    test('initial state is correct', () {
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.newChallenges, isEmpty);
      expect(notifier.state.ongoingChallenges, isEmpty);
      expect(notifier.state.completedChallenges, isEmpty);
      expect(notifier.state.error, isNull);
    });

    test('fetchAllChallenges updates state on success', () async {
      // Arrange
      final newChallengeData = [
        {
          'id': 'c1',
          'title': 'Test Challenge',
          'description': 'Desc',
          'stepTarget': 1000,
          'rewardCoins': 10,
          'rewardXp': 50,
          'durationDays': 1,
          'challengeType': 'SOLO',
          'difficulty': 'EASY',
        }
      ];

      final ongoingChallengeData = [
        {
          'id': 'uc1',
          'status': 'ONGOING',
          'currentSteps': 500,
          'progress': 50,
          'joinedAt': DateTime.now().toIso8601String(),
          'challenge': newChallengeData[0],
        }
      ];

      when(() => mockApiService.get('/challenges/new'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/challenges/new'),
                data: newChallengeData,
              ));
      when(() => mockApiService.get('/challenges/ongoing'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/challenges/ongoing'),
                data: ongoingChallengeData,
              ));
      when(() => mockApiService.get('/challenges/completed'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/challenges/completed'),
                data: [],
              ));

      // Act
      await notifier.fetchAllChallenges();

      // Assert
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.newChallenges.length, 1);
      expect(notifier.state.newChallenges.first.title, 'Test Challenge');
      expect(notifier.state.ongoingChallenges.length, 1);
      expect(notifier.state.ongoingChallenges.first.progress, 50);
      expect(notifier.state.completedChallenges, isEmpty);
      expect(notifier.state.error, isNull);
    });

    test('fetchAllChallenges handles errors gracefully', () async {
      // Arrange
      when(() => mockApiService.get(any()))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act
      await notifier.fetchAllChallenges();

      // Assert
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNotNull);
    });

    test('joinChallenge calls API and refreshes challenges', () async {
      // Arrange
      when(() => mockApiService.post('/challenges/join', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/challenges/join'),
                data: {'success': true},
              ));
      
      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [],
              ));

      // Act
      final result = await notifier.joinChallenge('c1');

      // Assert
      expect(result, isTrue);
      verify(() => mockApiService.post('/challenges/join', data: {'challengeId': 'c1'})).called(1);
      verify(() => mockApiService.get('/challenges/new')).called(1);
    });
  });
}
