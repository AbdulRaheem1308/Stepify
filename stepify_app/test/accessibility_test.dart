import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/quick_action_card.dart';

void main() {
  group('WCAG Accessibility Tests', () {
    testWidgets('QuickActionCard meets tap target and contrast guidelines', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 120, // Ensure it's larger than 48x48
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

      // Verify Semantics exist
      final SemanticsNode semantics = tester.getSemantics(find.byType(QuickActionCard));
      expect(semantics.label, 'Start Run. GPS Tracking');
      expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      // Verify WCAG Tap Target Size (48x48)
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      
      // Verify WCAG Text Contrast (4.5:1 for AA)
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      
      // Verify generic labeled tap targets
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
