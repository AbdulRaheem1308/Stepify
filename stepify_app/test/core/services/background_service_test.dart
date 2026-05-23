import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/core/services/background_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => '.',
    );
    const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (MethodCall methodCall) async => null,
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

    test('runBackgroundSyncTask executes cleanly', () async {
      // Mocking preferences to avoid crashes
      SharedPreferences.setMockInitialValues({});
      
      final res = await BackgroundService.runBackgroundSyncTask(kBackgroundSyncTask);
      expect(res, isTrue); // Will return true because token is null
    });
  });
}
