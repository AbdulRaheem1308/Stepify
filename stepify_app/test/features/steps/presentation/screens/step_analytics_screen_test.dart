import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/steps/presentation/screens/step_analytics_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/weekly_steps_chart.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/calorie_trend_chart.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider so Hive can resolve a temp directory
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => '.');

    // Mock FlutterSecureStorage so token reads/writes are no-ops
    const secureStorageChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (_) async => null);

    // Mock Pedometer so it never throws in tests
    const pedometerChannel =
        MethodChannel('com.example.pedometer/stepCount');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pedometerChannel, (_) async => 0);

    // Mock SafeDevice so integrity checks are safe no-ops
    const safeDeviceChannel = MethodChannel('safe_device');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safeDeviceChannel, (_) async => false);

    // Initialise Hive + StorageService so DashboardNotifier doesn't crash
    Hive.init('.');
    await StorageService.init();

    registerFallbackValue(RequestOptions(path: ''));
  });

  Widget createWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: StepAnalyticsScreen(),
      ),
    );
  }

  testWidgets('StepAnalyticsScreen shows loading then data', (tester) async {
    final mockApiService = MockApiService();

    // Stub every API call the DashboardNotifier makes on startup
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {},
        ));
    when(() => mockApiService.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 200,
              data: {},
            ));

    // Override /steps/weekly with real test data
    when(() => mockApiService.get('/steps/weekly')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'totalSteps': 45000,
          'totalCalories': 1200,
          'totalDistanceKm': 35.5,
          'averageSteps': 6500,
          'activeDays': 5,
          'dailyBreakdown': [],
        },
      ),
    );

    // Override /steps/monthly with real test data
    when(() => mockApiService.get('/steps/monthly')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'monthName': 'October',
          'totalSteps': 150000,
          'averageSteps': 5000,
          'activeDays': 20,
          'totalDaysInMonth': 31,
          'bestDay': null,
        },
      ),
    );

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    // Initial load state
    await tester.pumpWidget(createWidget(container));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for Futures to complete and animations to settle
    await tester.pumpAndSettle();

    // Verify weekly data renders
    expect(find.text('45,000', skipOffstage: false), findsOneWidget);
    expect(find.byType(WeeklyStepsChart), findsOneWidget);
    expect(find.byType(CalorieTrendChart), findsOneWidget);
  });

  testWidgets('StepAnalyticsScreen shows error snackbar on failure',
      (tester) async {
    final mockApiService = MockApiService();

    // Stub startup calls made by DashboardNotifier
    when(() => mockApiService.get(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('API Error');
    });
    when(() => mockApiService.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 200,
              data: {},
            ));

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pump(); // Start load
    await tester.pump(const Duration(milliseconds: 200)); // Futures complete
    await tester.pump(); // SnackBar starts animating

    // Check error snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to load analytics:'), findsOneWidget);

    // Check fallback data renders 0s
    expect(find.text('0'), findsWidgets);

    // Let the SnackBar dismiss so we don't leave pending timers
    await tester.pumpAndSettle();
  });
}
