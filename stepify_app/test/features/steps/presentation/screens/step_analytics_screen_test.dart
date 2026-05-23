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

    // Mock path_provider so Hive can resolve a directory
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => '.');

    // Mock FlutterSecureStorage so token reads/writes are no-ops
    const secureStorageChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (_) async => null);

    // Mock SafeDevice so integrity checks never crash
    const safeDeviceChannel = MethodChannel('safe_device');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safeDeviceChannel, (_) async => false);

    // Initialise Hive + StorageService so DashboardNotifier._loadUser() succeeds
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

    // Stub every DashboardNotifier startup call to return empty success
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'dailyBreakdown': [], 'stepCount': 0, 'balance': 0,
                 'lifetimePoints': 0, 'currentStreak': 0, 'longestStreak': 0},
        ));
    when(() => mockApiService.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 200,
              data: {},
            ));

    // Override /steps/weekly and /steps/monthly with test data
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
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    // IMPORTANT: cancel the DashboardNotifier's 5-second periodic timer at
    // the end of the test. Without this, pumpAndSettle never settles and the
    // framework throws "A Timer is still pending".
    addTearDown(container.dispose);

    // Pump the widget — should show a loading indicator immediately
    await tester.pumpWidget(createWidget(container));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let microtasks and short futures complete (API mocks resolve instantly)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Process the widget rebuild after state change
    await tester.pump(const Duration(milliseconds: 100));

    // Verify weekly data is rendered
    expect(find.text('45,000', skipOffstage: false), findsOneWidget);
    expect(find.byType(WeeklyStepsChart), findsOneWidget);
    expect(find.byType(CalorieTrendChart), findsOneWidget);
  });

  testWidgets('StepAnalyticsScreen shows error snackbar on failure',
      (tester) async {
    final mockApiService = MockApiService();

    // All API calls fail after a short delay
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
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );

    // Cancel the periodic timer when the test ends
    addTearDown(container.dispose);

    await tester.pumpWidget(createWidget(container));
    await tester.pump(); // Start async load
    await tester.pump(const Duration(milliseconds: 200)); // Futures reject
    await tester.pump(); // SnackBar starts animating

    // Verify error snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to load analytics:'), findsOneWidget);

    // Verify fallback shows 0s
    expect(find.text('0'), findsWidgets);
  });
}
