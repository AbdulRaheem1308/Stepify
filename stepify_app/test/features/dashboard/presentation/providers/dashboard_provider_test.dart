import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/health_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

class MockApiService extends Mock implements ApiService {}
class MockHealthService extends Mock implements HealthService {}

void main() {
  late MockApiService mockApi;
  late MockHealthService mockHealth;
  late DashboardNotifier notifier;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => '.',
    );
    const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (MethodCall methodCall) async => null,
    );
    const safeDeviceChannel = MethodChannel('safe_device');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      safeDeviceChannel,
      (MethodCall methodCall) async => false,
    );
    await Hive.initFlutter('.');
    await StorageService.init();
  });

  setUp(() {
    mockApi = MockApiService();
    mockHealth = MockHealthService();

    // HealthService setup
    when(() => mockHealth.requestAuthorization()).thenAnswer((_) async => true);
    when(() => mockHealth.getStepHistory(any())).thenAnswer((_) async => {});

    // API Service setup
    when(() => mockApi.get('/steps/today')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/steps/today'),
      data: <String, dynamic>{'stepCount': 5000, 'caloriesBurned': 200, 'distanceKm': 3.5, 'activeMinutes': 45, 'goal': 10000},
    ));
    when(() => mockApi.get('/rewards/streak')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/streak'),
      data: <String, dynamic>{'currentStreak': 5, 'longestStreak': 10},
    ));
    when(() => mockApi.get('/rewards/wallet')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/rewards/wallet'),
      data: <String, dynamic>{'balance': 100, 'lifetimePoints': 500, 'monthlyXp': 1500},
    ));
    when(() => mockApi.get('/steps/weekly')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/steps/weekly'),
      data: <String, dynamic>{'dailyBreakdown': []},
    ));
    when(() => mockApi.get('/users/me')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/users/me'),
      data: <String, dynamic>{'id': '123', 'name': 'John'},
    ));
    when(() => mockApi.get('/users/me/stats')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/users/me/stats'),
      data: <String, dynamic>{},
    ));

    notifier = DashboardNotifier(mockApi, mockHealth);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('DashboardNotifier', () {
    test('initialization sets healthAuthorized', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.healthAuthorized, isTrue);
    });

    test('fetchTodayData populates state correctly', () async {
      await notifier.fetchTodayData();

      expect(notifier.state.isLoading, isFalse);
      print('Error in state: ${notifier.state.error}');
      expect(notifier.state.syncStatus, SyncStatus.synced);
      expect(notifier.state.todaySteps?.stepCount, 5000);
      expect(notifier.state.streak?.currentStreak, 5);
      expect(notifier.state.wallet?.balance, 100);
      expect(notifier.state.xpLevel, 2); // 1500 points should mean level 2
      expect(notifier.state.user?['name'], 'John');
    });

    test('updateDailyGoal updates local state and calls API', () async {
      await notifier.fetchTodayData();

      when(() => mockApi.put('/users/me', data: any(named: 'data'))).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/users/me'),
        data: {},
      ));

      await notifier.updateDailyGoal(12000);

      print('Error in update: ${notifier.state.error}');
      expect(notifier.state.todaySteps?.goal, 12000);
      verify(() => mockApi.put('/users/me', data: {'dailyStepGoal': 12000})).called(1);
    });
  });
}
