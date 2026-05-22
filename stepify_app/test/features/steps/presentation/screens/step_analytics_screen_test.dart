import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/steps/presentation/screens/step_analytics_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/weekly_steps_chart.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/calorie_trend_chart.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
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
    
    // Mock the responses for /steps/weekly and /steps/monthly
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
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    // Initial load state
    await tester.pumpWidget(createWidget(container));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for Futures to complete and animations to finish
    await tester.pumpAndSettle();

    // Verify weekly data renders
    expect(find.text('45,000', skipOffstage: false), findsOneWidget); // formatted total steps
    expect(find.byType(WeeklyStepsChart), findsOneWidget);
    expect(find.byType(CalorieTrendChart), findsOneWidget);
  });

  testWidgets('StepAnalyticsScreen shows error snackbar on failure', (tester) async {
    final mockApiService = MockApiService();
    
    when(() => mockApiService.get(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('API Error');
    });

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pump(); // Start load
    await tester.pump(const Duration(milliseconds: 100)); // Future completes, SnackBar is triggered
    await tester.pump(); // SnackBar starts animating
    // Do not use pumpAndSettle here because it will wait for the SnackBar to disappear!

    // Check error snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to load analytics:'), findsOneWidget);
    
    // Check fallback data renders 0s
    expect(find.text('0'), findsWidgets);

    // Let the SnackBar dismiss so we don't leave pending timers
    await tester.pumpAndSettle();
  });
}
