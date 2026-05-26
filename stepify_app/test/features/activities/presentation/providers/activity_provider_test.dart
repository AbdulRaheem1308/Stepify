import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/activities/domain/models/activity_model.dart';
import 'package:stepify_app/features/activities/presentation/providers/activity_provider.dart';

// ---------------------------------------------------------------------------
// Manual mock for ApiService using mocktail
// ---------------------------------------------------------------------------
class MockApiService extends Mock implements ApiService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal valid Activity JSON map.
Map<String, dynamic> _activityJson({
  String id = 'test-id',
  String type = 'walking',
  String startTime = '2024-01-01T10:00:00Z',
  int durationMinutes = 30,
  double caloriesBurned = 150,
  double distanceKm = 2.0,
  int pointsEarned = 30,
  String source = 'manual',
}) =>
    {
      'id': id,
      'type': type,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'distanceKm': distanceKm,
      'pointsEarned': pointsEarned,
      'source': source,
    };

/// Creates a Dio [Response] wrapping [data].
Response<dynamic> _dioResponse(dynamic data, {int statusCode = 200}) =>
    Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );

/// Creates a [DioException] that simulates a backend error response.
DioException _dioError(
  dynamic responseData, {
  int statusCode = 500,
  DioExceptionType type = DioExceptionType.badResponse,
}) =>
    DioException(
      requestOptions: RequestOptions(path: ''),
      response: _dioResponse(responseData, statusCode: statusCode),
      type: type,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockApiService mockApi;
  late ProviderContainer container;

  setUp(() {
    mockApi = MockApiService();
    container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApi)],
    );
  });

  tearDown(() => container.dispose());

  // ─────────────────────────────────────────────────────────────────────────
  // 1. ActivityState – default values and copyWith
  // ─────────────────────────────────────────────────────────────────────────
  group('ActivityState', () {
    test('has correct default values', () {
      const s = ActivityState();
      expect(s.recentActivities, isEmpty);
      expect(s.isLoading, isFalse);
      expect(s.error, isNull);
    });

    test('copyWith updates isLoading and preserves the rest', () {
      const s = ActivityState();
      final updated = s.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
      expect(updated.recentActivities, isEmpty);
      expect(updated.error, isNull);
    });

    test('copyWith updates recentActivities and preserves the rest', () {
      final activity = Activity(
        id: 'a1',
        type: ActivityType.running,
        startTime: DateTime(2024),
        duration: const Duration(minutes: 30),
        caloriesBurned: 300,
        distanceKm: 5,
        pointsEarned: 90,
      );
      const s = ActivityState();
      final updated = s.copyWith(recentActivities: [activity]);
      expect(updated.recentActivities.length, 1);
      expect(updated.recentActivities.first.id, 'a1');
      expect(updated.isLoading, isFalse);
      expect(updated.error, isNull);
    });

    test('copyWith with non-empty error string stores it', () {
      const s = ActivityState();
      final updated = s.copyWith(error: 'Something went wrong');
      expect(updated.error, 'Something went wrong');
    });

    test('copyWith with empty string clears error to null', () {
      const s = ActivityState(error: 'old error');
      // The implementation treats empty string as "clear"
      final updated = s.copyWith(error: '');
      expect(updated.error, isNull);
    });

    test('copyWith without error argument preserves existing error', () {
      const s = ActivityState(error: 'existing error');
      final updated = s.copyWith(isLoading: true);
      expect(updated.error, 'existing error');
    });

    test('copyWith can chain multiple fields', () {
      const s = ActivityState();
      final updated = s.copyWith(isLoading: true, error: 'err');
      expect(updated.isLoading, isTrue);
      expect(updated.error, 'err');
      expect(updated.recentActivities, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 2. ActivityNotifier.fetchActivities
  // ─────────────────────────────────────────────────────────────────────────
  group('ActivityNotifier.fetchActivities', () {
    test('initial state is empty with no loading', () {
      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities, isEmpty);
      expect(state.error, isNull);
    });

    test('success path: populates list and clears isLoading', () async {
      when(() => mockApi.get('/activities')).thenAnswer(
        (_) async => _dioResponse([
          _activityJson(id: '1', type: 'walking'),
          _activityJson(id: '2', type: 'running', durationMinutes: 45),
        ]),
      );

      final notifier = container.read(activityProvider.notifier);
      await notifier.fetchActivities();

      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities.length, 2);
      expect(state.recentActivities[0].id, '1');
      expect(state.recentActivities[0].type, ActivityType.walking);
      expect(state.recentActivities[1].id, '2');
      expect(state.recentActivities[1].type, ActivityType.running);
    });

    test('success path: parses all activity types correctly', () async {
      final types = ['walking', 'running', 'cycling', 'yoga', 'swimming', 'gym', 'hiking'];
      when(() => mockApi.get('/activities')).thenAnswer(
        (_) async => _dioResponse(
          types.asMap().entries.map((e) => _activityJson(id: '${e.key}', type: e.value)).toList(),
        ),
      );

      await container.read(activityProvider.notifier).fetchActivities();
      final state = container.read(activityProvider);

      expect(state.recentActivities.length, types.length);
      expect(state.recentActivities[0].type, ActivityType.walking);
      expect(state.recentActivities[1].type, ActivityType.running);
      expect(state.recentActivities[2].type, ActivityType.cycling);
      expect(state.recentActivities[3].type, ActivityType.yoga);
      expect(state.recentActivities[4].type, ActivityType.swimming);
      expect(state.recentActivities[5].type, ActivityType.gym);
      expect(state.recentActivities[6].type, ActivityType.hiking);
    });

    test('success path: empty list response is valid', () async {
      when(() => mockApi.get('/activities')).thenAnswer(
        (_) async => _dioResponse([]),
      );

      await container.read(activityProvider.notifier).fetchActivities();
      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities, isEmpty);
    });

    test('failure path: keeps previous list, clears isLoading, no error field set', () async {
      // Seed the state with one existing activity
      when(() => mockApi.get('/activities')).thenAnswer(
        (_) async => _dioResponse([_activityJson(id: 'existing')]),
      );
      await container.read(activityProvider.notifier).fetchActivities();
      expect(container.read(activityProvider).recentActivities.length, 1);

      // Now simulate an error on the second fetch
      when(() => mockApi.get('/activities')).thenThrow(
        _dioError('Server error'),
      );
      await container.read(activityProvider.notifier).fetchActivities();

      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      // Previous list is preserved
      expect(state.recentActivities.length, 1);
      expect(state.recentActivities.first.id, 'existing');
    });

    test('failure path (network error): isLoading=false, list unchanged', () async {
      when(() => mockApi.get('/activities')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final notifier = container.read(activityProvider.notifier);
      await notifier.fetchActivities();

      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities, isEmpty);
    });

    test('failure path (generic exception): isLoading=false, list unchanged', () async {
      when(() => mockApi.get('/activities')).thenThrow(Exception('unexpected'));

      await container.read(activityProvider.notifier).fetchActivities();

      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 3. ActivityNotifier.logActivity – validation
  // ─────────────────────────────────────────────────────────────────────────
  group('ActivityNotifier.logActivity – validation', () {
    test('duration < 1 minute returns error without touching state', () async {
      final notifier = container.read(activityProvider.notifier);
      final error = await notifier.logActivity(
        type: ActivityType.walking,
        duration: const Duration(seconds: 30), // 0 minutes
      );

      expect(error, contains('at least 1 minute'));
      expect(container.read(activityProvider).recentActivities, isEmpty);
      expect(container.read(activityProvider).isLoading, isFalse);
    });

    test('duration of exactly 0 seconds returns error', () async {
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: Duration.zero,
      );
      expect(error, isNotNull);
      expect(error, contains('at least 1 minute'));
    });

    test('duration > 300 minutes returns error without touching state', () async {
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(hours: 6), // 360 min
      );

      expect(error, contains('cannot exceed 300 minutes'));
      expect(container.read(activityProvider).recentActivities, isEmpty);
    });

    test('duration of exactly 301 minutes returns error', () async {
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 301),
      );
      expect(error, isNotNull);
      expect(error, contains('cannot exceed 300 minutes'));
    });

    test('duration of exactly 1 minute passes duration validation', () async {
      // Mock successful POST so we only test validation boundary
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 1),
      );
      // Should not be a duration validation error
      expect(error, isNull);
    });

    test('duration of exactly 300 minutes passes duration validation', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 300),
      );
      expect(error, isNull);
    });

    // ── Distance validation ─────────────────────────────────────────────────

    test('walking: unrealistic distance returns error', () async {
      // 60 min * 0.12 km/min = 7.2 km max; 20 km is unrealistic
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 60),
        distanceKm: 20.0,
      );
      expect(error, contains('unrealistic'));
      expect(error, contains('walking'));
    });

    test('running: unrealistic distance returns error', () async {
      // 30 min * 0.35 = 10.5 km max; 15 km is unrealistic
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
        distanceKm: 15.0,
      );
      expect(error, contains('unrealistic'));
    });

    test('cycling: unrealistic distance returns error', () async {
      // 30 min * 0.9 = 27 km max; 50 km is unrealistic
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.cycling,
        duration: const Duration(minutes: 30),
        distanceKm: 50.0,
      );
      expect(error, contains('unrealistic'));
    });

    test('swimming: unrealistic distance returns error', () async {
      // 60 min * 0.05 = 3 km max; 5 km is unrealistic
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.swimming,
        duration: const Duration(minutes: 60),
        distanceKm: 5.0,
      );
      expect(error, contains('unrealistic'));
    });

    test('hiking: unrealistic distance returns error', () async {
      // 60 min * 0.1 = 6 km max; 10 km is unrealistic
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.hiking,
        duration: const Duration(minutes: 60),
        distanceKm: 10.0,
      );
      expect(error, contains('unrealistic'));
    });

    test('walking: realistic distance passes distance validation', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // 60 min * 0.12 = 7.2 km max; 5 km is realistic
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 60),
        distanceKm: 5.0,
      );
      expect(error, isNull);
    });

    test('gym: no distance cap (infinity) so any km is valid', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // gym hits the default branch in _maxDistanceKm → double.infinity
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.gym,
        duration: const Duration(minutes: 60),
        distanceKm: 999.0, // won't be rejected
      );
      expect(error, isNull);
    });

    test('yoga: no distance cap so any km is valid', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.yoga,
        duration: const Duration(minutes: 60),
        distanceKm: 999.0,
      );
      expect(error, isNull);
    });

    test('null distanceKm skips distance validation entirely', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 30),
        // no distanceKm provided
      );
      expect(error, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 4. ActivityNotifier.logActivity – success paths
  // ─────────────────────────────────────────────────────────────────────────
  group('ActivityNotifier.logActivity – success paths', () {
    test('adds activity to front of list using backend response', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(_activityJson(
          id: 'backend-id',
          type: 'running',
          durationMinutes: 30,
          caloriesBurned: 300,
          distanceKm: 5.0,
          pointsEarned: 90,
          source: 'manual',
        )),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
        distanceKm: 5.0,
      );

      expect(error, isNull);
      final state = container.read(activityProvider);
      expect(state.isLoading, isFalse);
      expect(state.recentActivities.length, 1);
      expect(state.recentActivities.first.id, 'backend-id');
      expect(state.recentActivities.first.pointsEarned, 90);
      expect(state.recentActivities.first.caloriesBurned, 300);
    });

    test('falls back to local activity when backend returns null data', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.cycling,
        duration: const Duration(minutes: 45),
        distanceKm: 10.0,
      );

      expect(error, isNull);
      final state = container.read(activityProvider);
      expect(state.recentActivities.length, 1);
      // local fallback: id is a non-empty ISO8601 timestamp
      expect(state.recentActivities.first.id, isNotEmpty);
      expect(state.recentActivities.first.type, ActivityType.cycling);
      expect(state.recentActivities.first.distanceKm, 10.0);
    });

    test('new activity is prepended (most-recent first)', () async {
      // First activity
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(_activityJson(id: 'first', type: 'walking')),
      );
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 30),
      );

      // Second activity
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(_activityJson(id: 'second', type: 'running')),
      );
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 20),
      );

      final state = container.read(activityProvider);
      expect(state.recentActivities.length, 2);
      expect(state.recentActivities.first.id, 'second'); // newest first
      expect(state.recentActivities.last.id, 'first');
    });

    test('isLoading is false after successful log', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );

      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.yoga,
        duration: const Duration(minutes: 30),
      );

      expect(container.read(activityProvider).isLoading, isFalse);
    });

    test('manual source uses 0.5× multiplier (verified source uses 1.0×)', () async {
      // Running multiplier = 3.0, manual → 3.0 * 0.5 = 1.5 pts/min
      // 30 min * 1.5 = 45 points (local calc)
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null), // force local fallback
      );

      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
        source: 'manual',
      );

      final state = container.read(activityProvider);
      expect(state.recentActivities.first.pointsEarned, 45);
    });

    test('verified source (google_fit) uses 1.0× multiplier', () async {
      // Running multiplier = 3.0 * 1.0 = 3.0 pts/min
      // 30 min * 3.0 = 90 points (local calc)
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );

      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
        source: 'google_fit',
      );

      final state = container.read(activityProvider);
      expect(state.recentActivities.first.pointsEarned, 90);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 5. _calculateCalories (via logActivity side-effects using local fallback)
  // ─────────────────────────────────────────────────────────────────────────
  group('_calculateCalories (via local fallback)', () {
    setUp(() {
      // All tests in this group use null response → local Activity is created
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
    });

    test('running: 10 cals/min → 30 min = 300 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 300.0);
    });

    test('swimming: 10 cals/min → 20 min = 200 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.swimming,
        duration: const Duration(minutes: 20),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 200.0);
    });

    test('cycling: 7 cals/min → 30 min = 210 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.cycling,
        duration: const Duration(minutes: 30),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 210.0);
    });

    test('gym: 7 cals/min → 60 min = 420 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.gym,
        duration: const Duration(minutes: 60),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 420.0);
    });

    test('yoga: 3 cals/min → 45 min = 135 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.yoga,
        duration: const Duration(minutes: 45),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 135.0);
    });

    test('walking: 5 cals/min (default) → 60 min = 300 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 60),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 300.0);
    });

    test('hiking: 5 cals/min (default) → 90 min = 450 cals', () async {
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.hiking,
        duration: const Duration(minutes: 90),
      );
      expect(container.read(activityProvider).recentActivities.first.caloriesBurned, 450.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 6. ActivityNotifier.logActivity – API failure paths
  // ─────────────────────────────────────────────────────────────────────────
  group('ActivityNotifier.logActivity – API failure', () {
    test('returns error message from DioException with response body', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        _dioError('Server exploded', statusCode: 500),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
      );

      expect(error, isNotNull);
      expect(error, contains('Server exploded'));
      expect(container.read(activityProvider).recentActivities, isEmpty);
      expect(container.read(activityProvider).isLoading, isFalse);
    });

    test('returns error message from DioException with Map response body', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Activity limit exceeded'},
            statusCode: 422,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 30),
      );

      expect(error, contains('Activity limit exceeded'));
      expect(container.read(activityProvider).recentActivities, isEmpty);
    });

    test('returns timeout message on connection timeout', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.cycling,
        duration: const Duration(minutes: 30),
      );

      expect(error, isNotNull);
      expect(error, contains('timed out'));
      expect(container.read(activityProvider).isLoading, isFalse);
    });

    test('returns connection error message on network failure', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.yoga,
        duration: const Duration(minutes: 30),
      );

      expect(error, isNotNull);
      expect(error, contains('Connection error'));
    });

    test('returns generic error message for unexpected exceptions', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        Exception('Something totally unexpected'),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.gym,
        duration: const Duration(minutes: 30),
      );

      expect(error, isNotNull);
      expect(container.read(activityProvider).recentActivities, isEmpty);
      expect(container.read(activityProvider).isLoading, isFalse);
    });

    test('returns ApiError message when ApiError is thrown directly', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        const ApiError(message: 'Quota exceeded'),
      );

      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
      );

      expect(error, 'Quota exceeded');
      expect(container.read(activityProvider).recentActivities, isEmpty);
    });

    test('on API error, pre-existing activities are preserved', () async {
      // Log one successfully first
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(_activityJson(id: 'kept')),
      );
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 30),
      );
      expect(container.read(activityProvider).recentActivities.length, 1);

      // Second log fails
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenThrow(
        _dioError('error'),
      );
      await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 30),
      );

      final state = container.read(activityProvider);
      expect(state.recentActivities.length, 1); // unchanged
      expect(state.recentActivities.first.id, 'kept');
      expect(state.isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 7. _maxDistanceKm boundary tests via logActivity rejection
  // ─────────────────────────────────────────────────────────────────────────
  group('_maxDistanceKm boundary via logActivity', () {
    // running: max = minutes * 0.35
    test('running at exactly max distance is accepted', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // 60 min * 0.35 = 21 km exactly
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 60),
        distanceKm: 21.0,
      );
      expect(error, isNull);
    });

    test('running just over max distance is rejected', () async {
      // 60 min * 0.35 = 21 km → 21.1 km should be rejected
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.running,
        duration: const Duration(minutes: 60),
        distanceKm: 21.1,
      );
      expect(error, contains('unrealistic'));
    });

    // cycling: max = minutes * 0.9
    test('cycling at exactly max distance is accepted', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // 30 min * 0.9 = 27 km exactly
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.cycling,
        duration: const Duration(minutes: 30),
        distanceKm: 27.0,
      );
      expect(error, isNull);
    });

    test('cycling just over max distance is rejected', () async {
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.cycling,
        duration: const Duration(minutes: 30),
        distanceKm: 27.1,
      );
      expect(error, contains('unrealistic'));
    });

    // walking: max = minutes * 0.12
    test('walking at exactly max distance is accepted', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // 60 min * 0.12 = 7.2 km exactly
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.walking,
        duration: const Duration(minutes: 60),
        distanceKm: 7.2,
      );
      expect(error, isNull);
    });

    // swimming: max = minutes * 0.05
    test('swimming at exactly max distance is accepted', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // 60 min * 0.05 = 3.0 km exactly
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.swimming,
        duration: const Duration(minutes: 60),
        distanceKm: 3.0,
      );
      expect(error, isNull);
    });

    // hiking: max = minutes * 0.1
    test('hiking at exactly max distance is accepted', () async {
      when(() => mockApi.post('/activities', data: any(named: 'data'))).thenAnswer(
        (_) async => _dioResponse(null),
      );
      // 60 min * 0.1 = 6.0 km exactly
      final error = await container.read(activityProvider.notifier).logActivity(
        type: ActivityType.hiking,
        duration: const Duration(minutes: 60),
        distanceKm: 6.0,
      );
      expect(error, isNull);
    });
  });
}
