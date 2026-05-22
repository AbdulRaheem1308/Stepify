import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: OnboardingScreen(),
    );
  }

  testWidgets('OnboardingScreen navigates pages and finishes', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Track Your Steps'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to go to page 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Earn Rewards'), findsOneWidget);

    // Tap Next to go to page 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Watch & Earn More'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Skip button is always present
    expect(find.text('Skip'), findsOneWidget);
  });
}
