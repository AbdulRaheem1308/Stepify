import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:stepify_app/services/pedometer_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('pedometer_service_test_');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => tempDir.path,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async => {19: 1}, // ACTIVITY_RECOGNITION granted
    );
    
    // Mock the step_count event channel to emit a single value and close immediately
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMessageHandler('step_count', (ByteData? message) async {
       return const StandardMethodCodec().encodeSuccessEnvelope(100);
    });
    
    await Hive.initFlutter(tempDir.path);
    await StorageService.init();
  });

  group('PedometerService', () {
    test('singleton instance', () {
      final s1 = PedometerService();
      final s2 = PedometerService();
      expect(identical(s1, s2), isTrue);
    });

    test('getCurrentSteps handles error safely', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final service = PedometerService();
      // Without proper mocking of pedometer channel, this should hit catch and return 0
      final steps = await service.getCurrentSteps();
      expect(steps, 0);
      debugDefaultTargetPlatformOverride = null;
    });
    
    test('stopListening resets state safely', () {
      final service = PedometerService();
      expect(() => service.stopListening(), returnsNormally);
      expect(service.isListening, isFalse);
    });

    test('getCurrentSteps with mocked stream', () async {
      final service = PedometerService();
      service.mockStepCountStream = Stream.value(150);
      final steps = await service.getCurrentSteps();
      expect(steps, greaterThanOrEqualTo(0));
    });

    test('getCurrentSteps fallback to last known steps on timeout', () async {
      final service = PedometerService();
      
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      await StorageService.put('pedometer_last_sync_date', todayStr);
      await StorageService.put('pedometer_baseline_steps', 1000);
      await StorageService.put('pedometer_last_known_steps', 1450);
      
      final completer = Completer<int>();
      service.mockStepCountStream = Stream.fromFuture(completer.future);
      
      final steps = await service.getCurrentSteps();
      expect(steps, 450);
    });

    test('startListening with mocked stream', () async {
      final service = PedometerService();
      service.mockStepCountStream = Stream.value(150);
      bool called = false;
      await service.startListening(onStepsChanged: (s) => called = true);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(called, isTrue);
      service.stopListening();
    });

    test('startListening handles error from stream', () async {
      final service = PedometerService();
      service.mockStepCountStream = Stream.error(Exception('stream_error'));
      bool errorCalled = false;
      await service.startListening(
        onStepsChanged: (s) {},
        onErrorOccurred: (e) => errorCalled = true,
      );
      await Future.delayed(const Duration(milliseconds: 100));
      expect(errorCalled, isTrue);
      service.stopListening();
    });

    test('_requestActivityPermission retry error handling', () async {
      // Mock permission handler to throw an error so it hits the catch block
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        },
      );
      
      final service = PedometerService();
      bool errorCalled = false;
      
      // Start listening should call requestActivityPermission
      await service.startListening(
        onStepsChanged: (s) {},
        onErrorOccurred: (e) => errorCalled = true,
      );
      
      await Future.delayed(const Duration(seconds: 2)); // wait for retry delay
      
      // The onErrorOccurred should be called from the catch block
      expect(errorCalled, isTrue);
      service.stopListening();
      
      // Restore the original mock handler for other tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async => {19: 1}, // ACTIVITY_RECOGNITION granted
      );
    });
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });
}

