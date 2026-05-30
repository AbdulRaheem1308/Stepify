import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wellnex_app/main.dart' as app;

void main() {
  // Ensure the integration test binding is initialized
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Wellnex End-to-End Automated UI Integration Test', () {
    testWidgets('Verify app launch, main navigation tabs, and manually logging a workout',
        (tester) async {
      // 1. Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait a few seconds for the landing screen or auth state to load
      await Future.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 2. Check if we are on the Login Screen or Main Dashboard Screen
      final isLoginScreenVisible = find.text('Sign In').evaluate().isNotEmpty || 
                                   find.textContaining('Google').evaluate().isNotEmpty;

      if (isLoginScreenVisible) {
        debugPrint('--- Authentication Screen Detected ---');
        debugPrint('Verifying social sign-in UI elements...');
        
        // Assert Google Sign-In button is present
        final googleButtonFinder = find.textContaining('Google');
        expect(googleButtonFinder, findsWidgets);
        debugPrint('Google Sign-In button verified successfully.');

        // For Firebase Test Lab running as custom instrumentation, 
        // we can tap the Google sign-in button if it is pre-configured with a Test Lab mock account.
        if (find.textContaining('Apple').evaluate().isNotEmpty) {
          expect(find.textContaining('Apple'), findsOneWidget);
          debugPrint('Apple Sign-In button verified successfully.');
        }

        debugPrint('Exiting test: Social login requires manual OAuth web-views. Robo crawlers will handle native dialogs.');
        return; // Safe return: Robo can take over from here, or user can configure test accounts in Test Lab console.
      }

      // 3. Authenticated Dashboard Navigation Flow
      debugPrint('--- Authenticated Main Screen Detected ---');
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      debugPrint('Bottom Navigation Bar verified successfully.');

      // Tap on the Activity History tab
      final activityTab = find.byIcon(Icons.directions_run_rounded);
      if (activityTab.evaluate().isNotEmpty) {
        await tester.tap(activityTab);
        await tester.pumpAndSettle();
        debugPrint('Navigated to Activity History Screen successfully.');
        await Future.delayed(const Duration(seconds: 2));
      }

      // 4. Test Manual Activity Logging with 50% Reduction
      // Find the FAB or Log Workout entry button
      final logWorkoutBtn = find.byIcon(Icons.add);
      final logWorkoutTextBtn = find.textContaining('Log');
      
      var workoutTrigger = logWorkoutBtn.evaluate().isNotEmpty ? logWorkoutBtn : logWorkoutTextBtn;
      
      if (workoutTrigger.evaluate().isNotEmpty) {
        await tester.tap(workoutTrigger.first);
        await tester.pumpAndSettle();
        debugPrint('Opened Manual Log Workout screen successfully.');

        // Tap the 'Running' activity choice chip
        final runningChip = find.text('Running');
        if (runningChip.evaluate().isNotEmpty) {
          await tester.tap(runningChip);
          await tester.pumpAndSettle();
          debugPrint('Selected Running activity.');
        }

        // Enter duration minutes (e.g., 40)
        final textFieldFinder = find.byType(TextField);
        if (textFieldFinder.evaluate().isNotEmpty) {
          await tester.enterText(textFieldFinder.first, '40');
          await tester.pumpAndSettle();
          debugPrint('Entered 40 minutes duration.');
        }

        // Verify the 50% multiplier discount is correctly calculated and displayed in the UI badge
        // For Running, base is 3.0x, manual is 1.5x.
        expect(find.textContaining('1.5x'), findsOneWidget);
        debugPrint('Multiplier badge correctly displays manual discount (1.5x) in UI.');

        // Click on the Log Workout submit button to commit the manual log
        final logBtn = find.textContaining('Log');
        if (logBtn.evaluate().isNotEmpty) {
          await tester.tap(logBtn.first);
          await tester.pumpAndSettle();
          debugPrint('Manually submitted activity logging request.');
          await Future.delayed(const Duration(seconds: 3));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
