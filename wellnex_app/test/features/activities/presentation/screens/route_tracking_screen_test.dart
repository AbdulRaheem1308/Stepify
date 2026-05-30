import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/features/activities/presentation/screens/route_tracking_screen.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RouteTrackingScreen(),
      ),
    );
  }

  group('RouteTrackingScreen Widget Tests', () {
    testWidgets('renders all initial UI elements properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Use pump instead of pumpAndSettle due to repeating animation

      expect(find.text('GPS Route Tracker'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Active Min'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      
      expect(find.text('Tap Start to begin tracking your route'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      
      // Ensure the end button is NOT visible initially
      expect(find.text('End'), findsNothing);
      expect(find.text('Stop'), findsNothing);
    });
    
    // We do not extensively test the start/stop tracking flow here
    // because it relies on the hardware Geolocator plugin via LocationService,
    // which requires native mocking plugins or dependency injection refactoring.
    // However, validating the layout builds successfully verifies L10n and syntax.
  });
}
