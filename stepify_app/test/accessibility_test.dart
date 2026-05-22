import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:stepify_app/features/activities/presentation/screens/activity_history_screen.dart';
import 'package:stepify_app/features/activities/presentation/screens/activity_logging_screen.dart';
import 'package:stepify_app/features/settings/presentation/screens/settings_screen.dart';

void main() {
  group('WCAG Accessibility Tests', () {
    // ─── Batch 1 ─────────────────────────────────────────────────────────────
    testWidgets('QuickActionCard meets tap target and contrast guidelines', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 120,
                child: QuickActionCard(
                  icon: Icons.directions_run,
                  title: 'Start Run',
                  subtitle: 'GPS Tracking',
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      final SemanticsNode semantics = tester.getSemantics(find.byType(QuickActionCard));
      expect(semantics.label, 'Start Run. GPS Tracking');
      expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    // ─── Batch 3: Analytics & Workouts UI ────────────────────────────────────

    testWidgets('ActivityHistoryScreen empty state meets tap target guideline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ActivityHistoryScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('ActivityHistoryScreen meets text contrast guideline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ActivityHistoryScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('ActivityLoggingScreen meets tap target guideline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ActivityLoggingScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('ActivityLoggingScreen meets text contrast guideline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ActivityLoggingScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('ActivityLoggingScreen has labeled tap targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ActivityLoggingScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    // ─── Batch 4: Profile & Settings UI ──────────────────────────────────────

    testWidgets('SettingsScreen meets tap target guideline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      // Toggle tiles onTap + Reset button must satisfy >= 48px
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('SettingsScreen meets text contrast guideline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('SettingsScreen has labeled tap targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}

