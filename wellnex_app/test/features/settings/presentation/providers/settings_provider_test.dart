import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:wellnex_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('be.tramckrijte.workmanager/workmanager'), (MethodCall methodCall) async {
      return null;
    });

    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    if (!Hive.isBoxOpen('wellnex_storage')) {
      await StorageService.init();
    }
  });

  setUp(() {
    mockApiService = MockApiService();
  });

  group('AppSettings Model', () {
    test('equality and copyWith work', () {
      const settings = AppSettings(
        themeMode: 'dark',
        language: 'hi',
      );

      final settingsCopy = settings.copyWith(themeMode: 'light');

      expect(settingsCopy.themeMode, 'light');
      expect(settingsCopy.language, 'hi');
      expect(settings == settingsCopy, isFalse);

      final settingsIdentical = settings.copyWith();
      expect(settings == settingsIdentical, isTrue);
    });
  });

  group('SettingsNotifier', () {
    testWidgets('loads settings successfully', (tester) async {
      when(() => mockApiService.get('/users/me/settings')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'themeMode': 'dark',
            'language': 'es',
            'pushNotifications': false,
            'dailyReminders': true,
            'dataSyncOverCellular': false,
            'soundEnabled': true,
            'isPublic': false,
            'showOnLeaderboard': false,
            'showMilestones': true,
            'distanceUnit': 'mi',
          },
        ),
      );

      final notifier = SettingsNotifier(mockApiService);

      // Wait for async constructor load
      await tester.pump(const Duration(milliseconds: 100));

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
      expect(notifier.state.themeMode, 'dark');
      expect(notifier.state.language, 'es');
      expect(notifier.state.pushNotificationsEnabled, false);
      expect(notifier.state.distanceUnit, 'mi');
    });

    testWidgets('handles load error', (tester) async {
      when(() => mockApiService.get('/users/me/settings')).thenThrow(Exception('Network Error'));

      final notifier = SettingsNotifier(mockApiService);

      // Wait for async constructor load
      await tester.pump(const Duration(milliseconds: 100));

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, contains('Network Error'));
    });

    testWidgets('updates theme mode and saves', (tester) async {
      when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));
      when(() => mockApiService.put(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200));

      final notifier = SettingsNotifier(mockApiService);
      await tester.pump(const Duration(milliseconds: 100));

      notifier.setThemeMode('dark');
      
      expect(notifier.state.themeMode, 'dark');
      verify(() => mockApiService.put('/users/me/settings', data: any(named: 'data'))).called(1);
    });
  });
}
