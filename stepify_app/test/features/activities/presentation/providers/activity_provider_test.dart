import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/activities/domain/models/activity_model.dart';
import 'package:stepify_app/features/activities/presentation/providers/activity_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late ProviderContainer container;

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

  group('ActivityNotifier.fetchActivities', () {
    test('fetches activities successfully', () async {
      when(() => mockApi.get('/activities')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [
            {
              'id': '1',
              'type': 'walking',
              'startTime': '2024-01-01T10:00:00Z',
              'durationMinutes': 30,
              'caloriesBurned': 150,
              'distanceKm': 2.0,
              'pointsEarned': 30,
            }
          ],
        ),
      );

      final notifier = container.read(activityProvider.notifier);
      await notifier.fetchActivities();

      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities.length, 1);
      expect(state.recentActivities.first.id, '1');
      expect(state.recentActivities.first.type, ActivityType.walking);
    });

    test('handles API error without crashing', () async {
      when(() => mockApi.get('/activities')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final notifier = container.read(activityProvider.notifier);
      await notifier.fetchActivities();

      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities, isEmpty);
    });
  });

  group('ActivityNotifier.logActivity', () {
    test('validates minimum duration', () async {
      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.walking,
        duration: const Duration(seconds: 30), // < 1 min
      );
      expect(error, contains('must be at least 1 minute'));
      
      final state = container.read(activityProvider);
      expect(state.recentActivities, isEmpty);
    });

    test('validates maximum duration', () async {
      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.walking,
        duration: const Duration(hours: 6), // > 5 hours
      );
      expect(error, contains('cannot exceed 300 minutes'));
    });

    test('validates max realistic distance', () async {
      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 60),
        distanceKm: 20.0, // unrealistic for walking
      );
      expect(error, contains('unrealistic'));
    });

    test('logs activity successfully with backend ID', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'id': 'backend_id',
            'type': 'running',
            'startTime': '2024-01-01T10:00:00Z',
            'durationMinutes': 30,
            'caloriesBurned': 300,
            'distanceKm': 5.0,
            'pointsEarned': 90,
          },
        ),
      );

      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
        distanceKm: 5.0,
      );

      expect(error, isNull);
      
      final state = container.read(activityProvider);
      expect(state.recentActivities.length, 1);
      expect(state.recentActivities.first.id, 'backend_id');
      expect(state.recentActivities.first.pointsEarned, 90);
    });

    test('logs activity locally when offline but POST succeeds with null data', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: null, // empty response
        ),
      );

      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
      );

      expect(error, isNull);
      
      final state = container.read(activityProvider);
      expect(state.recentActivities.length, 1);
      expect(state.recentActivities.first.id, isNotEmpty); // generated local id
    });

    test('returns ApiError message when backend fails', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: 'Server exploded',
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
      );

      expect(error, contains('Server exploded'));
      
      final state = container.read(activityProvider);
      expect(state.recentActivities, isEmpty);
    });
  });
}
