import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/services/pedometer_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => '.',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async => {19: 1}, // ACTIVITY_RECOGNITION granted
    );
    
    // Mock the step_count event channel to emit a single value and close immediately
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMessageHandler('step_count', (ByteData? message) async {
       return const StandardMethodCodec().encodeSuccessEnvelope(100);
    });
    
    await Hive.initFlutter('.test_pedometer');
    await StorageService.init();
  });

  group('PedometerService', () {
    test('singleton instance', () {
      final s1 = PedometerService();
      final s2 = PedometerService();
      expect(identical(s1, s2), isTrue);
    });

    test('getCurrentSteps handles error safely', () async {
      final service = PedometerService();
      // Without proper mocking of pedometer channel, this should hit catch and return 0
      final steps = await service.getCurrentSteps();
      expect(steps, 0);
    });
    
    test('stopListening resets state safely', () {
      final service = PedometerService();
      expect(() => service.stopListening(), returnsNormally);
      expect(service.isListening, isFalse);
    });
  });
}
