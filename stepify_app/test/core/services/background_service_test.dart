import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/core/services/background_service.dart';
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
    await Hive.initFlutter('.test_bg');
    await StorageService.init();
  });

  group('BackgroundService', () {
    test('init executes cleanly', () async {
      await expectLater(BackgroundService.init(), completes);
    });

    test('registerPeriodicTask executes cleanly', () async {
      await expectLater(BackgroundService.registerPeriodicTask(), completes);
    });

    test('cancelTask executes cleanly', () async {
      await expectLater(BackgroundService.cancelTask(), completes);
    });
  });
}
