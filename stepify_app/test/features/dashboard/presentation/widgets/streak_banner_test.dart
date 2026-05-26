import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/streak_banner.dart';

void main() {
  testWidgets('StreakBanner renders and handles taps', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreakBanner(
            streakDays: 5,
            bestStreak: 12,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('5 days'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // Tap the banner
    await tester.tap(find.text('5 days'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('StreakBanner info icon opens explainer', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreakBanner(
            streakDays: 5,
            bestStreak: 12,
            onTap: () {},
          ),
        ),
      ),
    );

    // Tap info icon
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text('Daily Streaks'), findsOneWidget);
    expect(find.text('Keep the Flame Alive'), findsOneWidget);
  });
}
