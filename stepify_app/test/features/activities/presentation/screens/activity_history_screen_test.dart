import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/activities/domain/models/activity_model.dart';
import 'package:stepify_app/features/activities/presentation/providers/activity_provider.dart';
import 'package:stepify_app/features/activities/presentation/screens/activity_history_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createWidgetUnderTest(List<Activity> mockActivities) {
    return ProviderScope(
      overrides: [
        activityProvider.overrideWith(
          (ref) => _MockActivityNotifier(mockActivities),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ActivityHistoryScreen(),
      ),
    );
  }

  group('ActivityHistoryScreen Widget Tests', () {
    testWidgets('shows empty state when there are no activities', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest([]));
      await tester.pumpAndSettle();

      expect(find.text('Activity History'), findsOneWidget);
      expect(find.text('No activities yet'), findsOneWidget);
      expect(find.text('Log your first workout to see it here!'), findsOneWidget);
      expect(find.byIcon(Icons.history_toggle_off_rounded), findsOneWidget);
    });

    testWidgets('shows list of activities when available', (tester) async {
      final mockActivities = [
        Activity(
          id: '1',
          type: ActivityType.running,
          startTime: DateTime(2024, 1, 1, 10, 0),
          duration: const Duration(minutes: 30),
          caloriesBurned: 300,
          pointsEarned: 90,
          distanceKm: 5.0,
        ),
        Activity(
          id: '2',
          type: ActivityType.walking,
          startTime: DateTime(2024, 1, 2, 14, 0),
          duration: const Duration(minutes: 60),
          caloriesBurned: 200,
          pointsEarned: 60,
          distanceKm: 3.0,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(mockActivities));
      await tester.pumpAndSettle();

      expect(find.text('Activity History'), findsOneWidget);
      expect(find.text('No activities yet'), findsNothing);
      
      // Check first item
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('+90 pts'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      
      // Check second item
      expect(find.text('Walking'), findsOneWidget);
      expect(find.text('+60 pts'), findsOneWidget);
      expect(find.text('60 min'), findsOneWidget);

      expect(find.byIcon(Icons.directions_run_rounded), findsOneWidget);
      expect(find.byIcon(Icons.directions_walk_rounded), findsOneWidget);
    });
  });
}

class _MockActivityNotifier extends StateNotifier<ActivityState> implements ActivityNotifier {
  _MockActivityNotifier(List<Activity> mockActivities) 
      : super(ActivityState(recentActivities: mockActivities));

  @override
  Future<void> fetchActivities() async {}

  @override
  Future<String?> logActivity({required ActivityType type, required Duration duration, double? distanceKm, String? source}) async {
    return null;
  }
}
