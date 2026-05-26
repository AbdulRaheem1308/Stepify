import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/devices/presentation/providers/device_provider.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/health_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dio/dio.dart';
import 'package:health/health.dart';

class MockApiService implements ApiService {
  List<dynamic> mockDevicesResponse = [];
  bool shouldThrowError = false;
  Map<String, dynamic> lastPostData = {};
  String lastDeletedId = '';

  @override
  Future<void> Function()? onAuthFailure;

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (shouldThrowError) throw Exception('API Error');
    return Response(
      requestOptions: RequestOptions(path: path, queryParameters: queryParameters),
      data: mockDevicesResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (shouldThrowError) throw Exception('API Error');
    lastPostData = data ?? {};
    if (path == '/devices') {
      mockDevicesResponse.add({
        'id': 'new_id',
        'name': data['name'],
        'type': data['type'],
      });
    }
    return Response(
      requestOptions: RequestOptions(path: path, queryParameters: queryParameters, data: data),
      data: {},
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path, queryParameters: queryParameters, data: data),
      data: {},
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path, queryParameters: queryParameters, data: data),
      data: {},
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (shouldThrowError) throw Exception('API Error');
    lastDeletedId = path.split('/').last;
    mockDevicesResponse.removeWhere((d) => d['id'] == lastDeletedId);
    return Response(
      requestOptions: RequestOptions(path: path, queryParameters: queryParameters, data: data),
      data: {},
      statusCode: 200,
    );
  }
}

class MockHealthService implements HealthService {
  bool shouldAuthorize = true;
  bool shouldThrowError = false;
  int mockSteps = 5000;

  @override
  Future<bool> requestAuthorization() async {
    if (shouldThrowError) throw Exception('Health Error');
    return shouldAuthorize;
  }

  @override
  Future<int> getTodaySteps() async {
    if (shouldThrowError) throw Exception('Health Error');
    return mockSteps;
  }

  @override
  Future<Map<DateTime, int>> getStepHistory(int days) async {
    return {};
  }

  @override
  Future<List<HealthDataPoint>> getRecentWorkouts(int days) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockApiService mockApiService;
  late MockHealthService mockHealthService;
  late DeviceNotifier notifier;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'device_uuid': 'test-uuid'});
    mockApiService = MockApiService();
    mockHealthService = MockHealthService();
    // Prevent loadDevices from immediately triggering during test setup
  });

  DeviceNotifier createNotifier() {
    return DeviceNotifier(mockApiService, mockHealthService);
  }

  test('loadDevices populates devices list', () async {
    mockApiService.mockDevicesResponse = [
      {'id': '1', 'name': 'Test Watch', 'type': 'WATCH_APPLE', 'lastSyncedAt': '2026-05-26T10:00:00Z'}
    ];
    notifier = createNotifier();
    await Future.delayed(Duration.zero); // allow loadDevices to complete

    expect(notifier.state.devices.length, 2); // 1 mock + 1 auto-registered phone
    expect(notifier.state.devices.first.name, 'Test Watch');
    expect(notifier.state.devices.first.status, SyncStatus.connected);
  });

  test('connectHealthDevice adds a device when authorized', () async {
    notifier = createNotifier();
    await Future.delayed(Duration.zero);
    
    mockHealthService.shouldAuthorize = true;
    await notifier.connectHealthDevice();
    
    expect(notifier.state.devices.any((d) => d.type == 'WATCH_APPLE' || d.type == 'WATCH_ANDROID'), true);
    expect(notifier.state.error, isNull);
  });

  test('connectHealthDevice sets error when not authorized', () async {
    notifier = createNotifier();
    await Future.delayed(Duration.zero);
    
    mockHealthService.shouldAuthorize = false;
    await notifier.connectHealthDevice();
    
    expect(notifier.state.error, 'Permission denied');
  });

  test('syncDevice updates device sync status and steps', () async {
    mockApiService.mockDevicesResponse = [
      {'id': '1', 'name': 'Test Watch', 'type': 'WATCH_APPLE'}
    ];
    notifier = createNotifier();
    await Future.delayed(Duration.zero);

    await notifier.syncDevice('1');

    final updatedDevice = notifier.state.devices.firstWhere((d) => d.id == '1');
    expect(updatedDevice.status, SyncStatus.connected);
    expect(updatedDevice.syncedSteps, 5000);
    expect(updatedDevice.lastSyncTime, isNotNull);
  });

  test('removeDevice deletes a device and reloads list', () async {
    mockApiService.mockDevicesResponse = [
      {'id': '1', 'name': 'Test Watch', 'type': 'WATCH_APPLE'}
    ];
    notifier = createNotifier();
    await Future.delayed(Duration.zero);
    
    expect(notifier.state.devices.any((d) => d.id == '1'), true);

    await notifier.removeDevice('1');
    
    expect(notifier.state.devices.any((d) => d.id == '1'), false);
  });
}
