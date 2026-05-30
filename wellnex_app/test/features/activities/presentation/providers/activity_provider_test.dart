import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/features/activities/domain/models/activity_model.dart';
import 'package:wellnex_app/features/activities/presentation/providers/activity_provider.dart';

class MockApiService extends ApiService {
  bool shouldFail = false;
  Map<String, dynamic>? lastPostData;

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (shouldFail) throw Exception('API GET failed');
    if (path == '/activities') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: [
          {
            "id": "act1",
            "type": "RUNNING",
            "startTime": "2023-10-01T10:00:00Z",
            "durationMinutes": 30,
            "caloriesBurned": 300,
            "distanceKm": 5.0,
            "pointsEarned": 90,
            "source": "manual"
          }
        ],
        statusCode: 200,
      );
    }
    throw Exception('Not mocked path: $path');
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (shouldFail) throw Exception('API POST failed');
    if (path == '/activities') {
      lastPostData = data;
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {
          "id": "act-new",
          "type": data['type'],
          "startTime": data['startTime'],
          "durationMinutes": data['durationMinutes'],
          "caloriesBurned": data['caloriesBurned'],
          "distanceKm": data['distanceKm'],
          "pointsEarned": 50, // mock
          "source": data['source']
        },
        statusCode: 201,
      );
    }
    throw Exception('Not mocked path: $path');
  }
}

void main() {
  group('ActivityState & copyWith', () {
    test('initial state defaults', () {
      final state = ActivityState();
      expect(state.recentActivities, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates values', () {
      final activity = Activity(
        id: '1',
        type: ActivityType.walking,
        startTime: DateTime.now(),
        duration: Duration(minutes: 10),
        caloriesBurned: 50,
        pointsEarned: 10,
      );
      final state = ActivityState().copyWith(
        recentActivities: [activity],
        isLoading: true,
        error: 'Oops',
      );
      expect(state.recentActivities.length, 1);
      expect(state.isLoading, true);
      expect(state.error, 'Oops');
    });

    test('copyWith error empty string maps to null', () {
      final state = ActivityState(error: 'Prev').copyWith(error: '');
      expect(state.error, isNull);
    });
  });

  group('ActivityNotifier fetchActivities', () {
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

    test('success sets list and clears loading', () async {
      final notifier = container.read(activityProvider.notifier);
      await notifier.fetchActivities();
      
      final state = container.read(activityProvider);
      expect(state.isLoading, false);
      expect(state.recentActivities.length, 1);
      expect(state.recentActivities.first.id, 'act1');
      expect(state.recentActivities.first.type, ActivityType.running);
    });

    test('failure keeps previous list and clears loading', () async {
      final notifier = container.read(activityProvider.notifier);
      await notifier.fetchActivities(); // load first one
      
      mockApi.shouldFail = true;
      await notifier.fetchActivities();
      
      final state = container.read(activityProvider);
      expect(state.isLoading, false);
      expect(state.recentActivities.length, 1); // still has previous data
    });
  });

  group('ActivityNotifier logActivity validations', () {
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

    test('duration too short', () async {
      final notifier = container.read(activityProvider.notifier);
      final err = await notifier.logActivity(
        type: ActivityType.walking,
        duration: Duration(seconds: 30),
      );
      expect(err, contains('must be at least 1 minute'));
    });

    test('duration too long', () async {
      final notifier = container.read(activityProvider.notifier);
      final err = await notifier.logActivity(
        type: ActivityType.walking,
        duration: Duration(minutes: 301),
      );
      expect(err, contains('cannot exceed 300 minutes'));
    });

    test('distance unrealistic', () async {
      final notifier = container.read(activityProvider.notifier);
      final err = await notifier.logActivity(
        type: ActivityType.walking,
        duration: Duration(minutes: 30),
        distanceKm: 10.0, // max is 30 * 0.12 = 3.6
      );
      expect(err, contains('unrealistic'));
    });

    test('API failure returns error message', () async {
      mockApi.shouldFail = true;
      final notifier = container.read(activityProvider.notifier);
      final err = await notifier.logActivity(
        type: ActivityType.walking,
        duration: Duration(minutes: 30),
        distanceKm: 2.0,
      );
      expect(err, contains('API POST failed'));
      expect(err, isNotNull);
    });

    test('success path adds activity', () async {
      final notifier = container.read(activityProvider.notifier);
      final err = await notifier.logActivity(
        type: ActivityType.cycling,
        duration: Duration(minutes: 60),
        distanceKm: 15.0,
        source: 'manual',
      );
      expect(err, isNull);
      
      final state = container.read(activityProvider);
      expect(state.recentActivities.first.id, 'act-new');
      expect(state.recentActivities.first.type, ActivityType.cycling);
      
      // Verify calorie calculation
      // cycling: 60 mins * 7 cals = 420
      expect(mockApi.lastPostData?['caloriesBurned'], 420);
    });

    test('calorie calculation variations', () async {
      final notifier = container.read(activityProvider.notifier);
      
      // Running: 30 * 10 = 300
      await notifier.logActivity(type: ActivityType.running, duration: Duration(minutes: 30));
      expect(mockApi.lastPostData?['caloriesBurned'], 300);
      
      // Yoga: 30 * 3 = 90
      await notifier.logActivity(type: ActivityType.yoga, duration: Duration(minutes: 30));
      expect(mockApi.lastPostData?['caloriesBurned'], 90);
      
      // Hiking: 30 * 5 = 150
      await notifier.logActivity(type: ActivityType.hiking, duration: Duration(minutes: 30));
      expect(mockApi.lastPostData?['caloriesBurned'], 150);
    });
  });
}
