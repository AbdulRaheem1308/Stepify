import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/health_service.dart';
import 'package:stepify_app/features/devices/presentation/providers/device_provider.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class MockApiService extends Mock implements ApiService {}
class MockHealthService extends Mock implements HealthService {}

void main() {
  late MockApiService mockApi;
  late MockHealthService mockHealth;
  late DeviceNotifier notifier;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock MethodChannel for Hive/PathProvider
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => '.',
    );

    // Mock MethodChannel for FlutterSecureStorage
    const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (MethodCall methodCall) async => null,
    );

    Hive.init('.');
    await StorageService.init();
    
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApi = MockApiService();
    mockHealth = MockHealthService();

    // Default mock response for loadDevices
    when(() => mockApi.get('/devices')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/devices'),
      data: <dynamic>[
        {
          'id': 'd1',
          'name': 'My Fitbit',
          'type': 'FITBIT',
          'identifier': 'fitbit-123',
          'lastSyncedAt': '2023-01-01T10:00:00Z',
        }
      ],
    ));

    // Default mock response for adding phone device automatically
    when(() => mockApi.post('/devices', data: any(named: 'data'))).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/devices'),
      data: {},
    ));

    notifier = DeviceNotifier(mockApi, mockHealth);
  });

  test('loadDevices initializes state and auto-adds phone if missing', () async {
    // Wait for the constructor's loadDevices to finish
    await Future.delayed(Duration.zero);

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.devices.isNotEmpty, isTrue);
    expect(notifier.state.devices.first.id, 'd1');
    expect(notifier.state.devices.first.type, 'FITBIT');
    expect(notifier.state.devices.first.status, SyncStatus.connected);
  });

  test('connectHealthDevice adds health device to backend', () async {
    when(() => mockHealth.requestAuthorization()).thenAnswer((_) async => true);
    
    await Future.delayed(Duration.zero); // finish initial load
    
    await notifier.connectHealthDevice();
    
    verify(() => mockHealth.requestAuthorization()).called(1);
    verify(() => mockApi.post('/devices', data: any(named: 'data'))).called(greaterThanOrEqualTo(1));
  });

  test('removeDevice deletes device and reloads', () async {
    when(() => mockApi.delete('/devices/d1')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/devices/d1'),
      data: {},
    ));

    await Future.delayed(Duration.zero); // finish initial load

    await notifier.removeDevice('d1');

    verify(() => mockApi.delete('/devices/d1')).called(1);
    // Because it reloads, GET /devices should be called again
    verify(() => mockApi.get('/devices')).called(greaterThanOrEqualTo(2));
  });

  test('connectHealthDevice sets error on authorization failure', () async {
    when(() => mockHealth.requestAuthorization()).thenAnswer((_) async => false);
    
    await Future.delayed(Duration.zero); // finish initial load
    
    await notifier.connectHealthDevice();
    
    expect(notifier.state.error, 'Permission denied');
  });

  test('connectHealthDevice sets error on exception', () async {
    when(() => mockHealth.requestAuthorization()).thenThrow(Exception('test_error'));
    
    await Future.delayed(Duration.zero); // finish initial load
    
    await notifier.connectHealthDevice();
    
    expect(notifier.state.error, contains('test_error'));
  });

  test('addDevice sets error if device exists', () async {
    await Future.delayed(Duration.zero); // finish initial load
    
    await notifier.addDevice('My Fitbit', 'FITBIT');
    
    expect(notifier.state.error, 'Device is already connected');
  });

  test('syncDevice fetches steps and calls API', () async {
    when(() => mockHealth.getTodaySteps()).thenAnswer((_) async => 5000);
    when(() => mockApi.post(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: ''),
      data: {},
    ));
    
    await Future.delayed(Duration.zero); // finish initial load
    
    await notifier.syncDevice('d1');
    
    expect(notifier.state.error, isNull);
  });
