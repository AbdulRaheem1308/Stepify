import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/hero_progress_card.dart';

void main() {
  testWidgets('HeroProgressCard renders and triggers adjust goal', (tester) async {
    bool adjustTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroProgressCard(
            steps: 5000,
            goal: 10000,
            onAdjustGoal: () {
              adjustTapped = true;
            },
          ),
        ),
      ),
    );

    // Allow animations to finish
    await tester.pumpAndSettle();

    // Verify steps and percentage
    expect(find.text('50%'), findsOneWidget);
    // Number format for 5000 is 5,000
    expect(find.text('5,000'), findsOneWidget);
    // Goal format
    expect(find.text('10,000'), findsOneWidget);

    // Tap edit icon for goal
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(adjustTapped, isTrue);
  });

  testWidgets('HeroProgressCard info icon opens explainer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroProgressCard(
            steps: 5000,
            goal: 10000,
            onAdjustGoal: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the info icon
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    // Verify ExplainerBottomSheet is shown
    expect(find.text('Step Syncing'), findsOneWidget);
    expect(find.text('Secure Background Sync'), findsOneWidget);
  });
}
