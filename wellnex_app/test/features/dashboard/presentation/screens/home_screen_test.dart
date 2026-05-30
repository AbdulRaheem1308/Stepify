import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/features/dashboard/presentation/screens/home_screen.dart';
import 'package:wellnex_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('renders loading state', (tester) async {
    final mockState = DashboardState(isLoading: true);

    await tester.pumpWidget(createWidgetUnderTest(
      const HomeScreen(),
      overrides: [
        dashboardProvider.overrideWith((ref) => MockDashboardNotifier(mockState)),
      ],
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state', (tester) async {
    final mockState = DashboardState(isLoading: false, error: 'Network Error');

    await tester.pumpWidget(createWidgetUnderTest(
      const HomeScreen(),
      overrides: [
        dashboardProvider.overrideWith((ref) => MockDashboardNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders dashboard when data is present', (tester) async {
    final mockState = DashboardState(
      isLoading: false,
      todaySteps: TodaySteps(
        stepCount: 5000,
        caloriesBurned: 200,
        distanceKm: 3.5,
        activeMinutes: 45,
        goal: 10000,
        progress: 50,
        goalReached: false,
      ),
      streak: StreakInfo(currentStreak: 5, longestStreak: 10),
      wallet: WalletInfo(balance: 100, lifetimePoints: 500),
      user: {'name': 'Alice'},
      xpLevel: 2,
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const HomeScreen(),
      overrides: [
        dashboardProvider.overrideWith((ref) => MockDashboardNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    // Just check for presence of main components indirectly
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}

class MockDashboardNotifier extends StateNotifier<DashboardState> implements DashboardNotifier {
  MockDashboardNotifier(super.state);

  @override
  Future<void> fetchTodayData() async {}

  @override
  Future<void> updateDailyGoal(int newGoal) async {}

  @override
  Future<void> syncSteps(int rawStepCount) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
