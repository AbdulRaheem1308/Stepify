import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/activities/domain/models/activity_model.dart';
import 'package:stepify_app/features/activities/presentation/providers/activity_provider.dart';
import 'package:stepify_app/features/activities/presentation/screens/activity_logging_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  late _MockActivityNotifier mockNotifier;

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        activityProvider.overrideWith((ref) => mockNotifier),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ActivityLoggingScreen(),
      ),
    );
  }

  setUp(() {
    mockNotifier = _MockActivityNotifier();
  });

  group('ActivityLoggingScreen Widget Tests', () {
    testWidgets('renders all UI elements properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Log Workout'), findsOneWidget);
      expect(find.text('Activity Type'), findsOneWidget);
      expect(find.text('Duration (minutes)'), findsOneWidget);
      expect(find.text('Distance (km)'), findsOneWidget);
      expect(find.text('Running'), findsWidgets);
      expect(find.text('Walking'), findsWidgets);
      
      // Submit button
      expect(find.text('Log Workout & Earn Points'), findsOneWidget);
    });

    testWidgets('shows snackbar error on empty duration', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1)); // allow initial animations

      final btn = find.text('Log Workout & Earn Points');
      await tester.ensureVisible(btn);
      // Tap submit with empty duration
      await tester.tap(btn);
      await tester.pump(const Duration(seconds: 1)); // Allow snackbar animation

      expect(find.text('Something went wrong'), findsOneWidget); // l10n.error
      expect(mockNotifier.logCalled, isFalse);
    });

    testWidgets('shows snackbar error on invalid duration text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).first, 'abc');
      final btn = find.text('Log Workout & Earn Points');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Invalid duration entered.'), findsOneWidget);
      expect(mockNotifier.logCalled, isFalse);
    });

    testWidgets('submits activity and pops screen on success', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      // Duration field
      await tester.enterText(find.byType(TextField).first, '30');
      // Distance field (since 'Running' is default and has distance)
      await tester.enterText(find.byType(TextField).last, '5');

      final btn = find.text('Log Workout & Earn Points');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump(const Duration(seconds: 1)); // SnackBar pops up, and navigator pops

      expect(mockNotifier.logCalled, isTrue);
      expect(mockNotifier.lastLoggedType, ActivityType.running);
      expect(mockNotifier.lastLoggedDuration, const Duration(minutes: 30));
      expect(mockNotifier.lastLoggedDistance, 5.0);
    });

    testWidgets('handles backend error gracefully', (tester) async {
      mockNotifier.shouldReturnError = 'Server is down';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).first, '30');
      final btn = find.text('Log Workout & Earn Points');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump(const Duration(seconds: 1));

      expect(mockNotifier.logCalled, isTrue);
      expect(find.text('Server is down'), findsOneWidget);
      // Ensure screen wasn't popped
      expect(find.text('Log Workout'), findsOneWidget);
    });
  });
}

class _MockActivityNotifier extends StateNotifier<ActivityState> implements ActivityNotifier {
  _MockActivityNotifier() : super(const ActivityState());

  bool logCalled = false;
  ActivityType? lastLoggedType;
  Duration? lastLoggedDuration;
  double? lastLoggedDistance;
  String? shouldReturnError;

  @override
  Future<void> fetchActivities() async {}

  @override
  Future<String?> logActivity({required ActivityType type, required Duration duration, double? distanceKm, String? source}) async {
    logCalled = true;
    lastLoggedType = type;
    lastLoggedDuration = duration;
    lastLoggedDistance = distanceKm;
    return shouldReturnError;
  }
}
