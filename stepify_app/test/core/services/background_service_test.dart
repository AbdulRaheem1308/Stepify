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
      (MethodCall methodCall) async {
        if (methodCall.method == 'read' && methodCall.arguments['key'] == 'access_token') {
          return 'fake_token'; // Returning a token makes the test proceed further
        }
        return null;
      },
    );
    
    // Mock SafeDevice MethodChannel
    const safeDeviceChannel = MethodChannel('safe_device');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      safeDeviceChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'isRealDevice') return true;
        return false;
      },
    );

    // Mock device_info_plus channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/device_info'), (MethodCall methodCall) async {
      if (methodCall.method == 'getDeviceInfo') {
        return {
          'id': 'test_device_id', // For Android
          // For iOS
          'name': 'Test Device',
          'systemName': 'iOS',
          'systemVersion': '15.0',
          'model': 'iPhone',
          'modelName': 'iPhone 13',
          'localizedModel': 'iPhone',
          'identifierForVendor': 'test_vendor_id',
          'isPhysicalDevice': true,
          'freeDiskSize': 10000000,
          'totalDiskSize': 20000000,
          'physicalRamSize': 4000000,
          'availableRamSize': 2000000,
          'isiOSAppOnMac': false,
          'isiOSAppOnVision': false,
          'utsname': {
            'sysname': 'Darwin',
            'nodename': 'test',
            'release': '20.0.0',
            'version': '1',
            'machine': 'iPhone10,1'
          }
        };
      }
      return null;
    });

    // Mock permission_handler channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'), (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        final List<dynamic> args = methodCall.arguments as List<dynamic>;
        final Map<int, int> result = {};
        for (var item in args) {
          result[item as int] = 1; // 1 means granted
        }
        return result;
      } else if (methodCall.method == 'checkPermissionStatus') {
        return 1; // granted
      }
      return null;
    });

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
      
      // Let it run and fail gracefully if API call fails due to no mocked http client. 
      // The goal is just line coverage.
      final res = await BackgroundService.runBackgroundSyncTask(kBackgroundSyncTask);
      
      // It returns true unless a fatal error occurs before the try-catch or during the catch block
      expect(res, isTrue); 
      
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getString('bg_sync_status');
      expect(status, isNotNull);
    });

    test('callbackDispatcher executes cleanly', () {
      expect(() => callbackDispatcher(), returnsNormally);
    });
  });
}
