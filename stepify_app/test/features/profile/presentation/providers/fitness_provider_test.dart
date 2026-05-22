import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/profile/presentation/providers/fitness_provider.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final temp = Directory.systemTemp.createTempSync();
    Hive.init(temp.path);
    await StorageService.init();
    mockApiService = MockApiService();
  });

  test('FitnessState equality works', () {
    const state1 = FitnessState(bmi: 22.0, fitnessLevel: 'active', activityPreferences: ['running', 'yoga']);
    const state2 = FitnessState(bmi: 22.0, fitnessLevel: 'active', activityPreferences: ['running', 'yoga']);
    const state3 = FitnessState(bmi: 23.0, fitnessLevel: 'active', activityPreferences: ['running', 'yoga']);

    expect(state1, equals(state2));
    expect(state1, isNot(equals(state3)));
    expect(state1.hashCode, equals(state2.hashCode));
  });

  test('FitnessNotifier loads from StorageService correctly', () async {
    await StorageService.saveUser({
      'name': 'Test User',
      'heightCm': 175,
      'weightKg': 70,
      'fitnessLevel': 'active',
      'dailyStepGoal': 8000,
      'activityPreferences': ['walking', 'cycling'],
    });

    final notifier = FitnessNotifier(mockApiService);
    final state = notifier.state;

    expect(state.fitnessLevel, 'active');
    expect(state.dailyStepGoal, 8000);
    expect(state.activityPreferences, ['walking', 'cycling']);
    expect(state.bmi, closeTo(22.85, 0.01));
    expect(state.bmiCategory, 'Normal');
  });

  test('toggleActivity adds and removes preferences', () async {
    await StorageService.saveUser({
      'name': 'Test User',
      'activityPreferences': ['walking'],
    });

    when(() => mockApiService.put('/users/me', data: any(named: 'data'))).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/users/me'), statusCode: 200),
    );

    final notifier = FitnessNotifier(mockApiService);
    
    await notifier.toggleActivity('cycling');
    expect(notifier.state.activityPreferences, ['walking', 'cycling']);
    
    await notifier.toggleActivity('walking');
    expect(notifier.state.activityPreferences, ['cycling']);
  });

  test('updateActivityPreferences handles error', () async {
    when(() => mockApiService.put('/users/me', data: any(named: 'data'))).thenThrow(Exception('API Error'));

    final notifier = FitnessNotifier(mockApiService);
    await notifier.updateActivityPreferences(['yoga']);

    expect(notifier.state.error, contains('API Error'));
    expect(notifier.state.isUpdating, false);
    
    notifier.clearError();
    expect(notifier.state.error, isNull);
  });
}
