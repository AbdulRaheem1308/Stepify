import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/services/health_service.dart';
import 'package:health/health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthService', () {
    late HealthService healthService;
    
    setUp(() {
      healthService = HealthService();
      
      // Mock the method channel for flutter_health
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_health'), (MethodCall methodCall) async {
        if (methodCall.method == 'requestAuthorization') {
          return true;
        } else if (methodCall.method == 'getTotalStepsInInterval') {
          return 5000;
        } else if (methodCall.method == 'getHealthDataFromTypes') {
          return [];
        }
        return null;
      });
      
      // Mock permission_handler channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'), (MethodCall methodCall) async {
        if (methodCall.method == 'requestPermissions') {
          return {29: 1}; // 29 is activityRecognition, 1 is granted
        }
        return null;
      });
    });
    
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_health'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'), null);
    });

    test('requestAuthorization succeeds', () async {
      final result = await healthService.requestAuthorization();
      expect(result, isTrue);
    });

    test('getTodaySteps returns mocked steps', () async {
      final steps = await healthService.getTodaySteps();
      expect(steps, 5000);
    });

    test('getStepHistory returns map of mocked steps', () async {
      final history = await healthService.getStepHistory(3);
      expect(history.length, 3);
      expect(history.values.first, 5000);
    });

    test('getRecentWorkouts returns mocked workouts', () async {
      final workouts = await healthService.getRecentWorkouts(3);
      expect(workouts, isEmpty);
    });
    
    test('requestAuthorization handles exceptions gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_health'), (MethodCall methodCall) async {
        throw Exception('Mock Error');
      });
      final result = await healthService.requestAuthorization();
      expect(result, isFalse);
    });

    test('getTodaySteps handles exceptions gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_health'), (MethodCall methodCall) async {
        throw Exception('Mock Error');
      });
      final steps = await healthService.getTodaySteps();
      expect(steps, 0);
    });

    test('getRecentWorkouts handles exceptions gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_health'), (MethodCall methodCall) async {
        throw Exception('Mock Error');
      });
      final workouts = await healthService.getRecentWorkouts(3);
      expect(workouts, isEmpty);
    });
  });
}
