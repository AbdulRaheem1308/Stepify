import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

void main() {
  group('Internationalization (i18n) Tests', () {
    Widget buildTestApp(Locale locale, WidgetBuilder builder) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English (US)
          Locale('en', 'GB'), // English (UK)
          Locale('en', 'IN'), // English (India)
          Locale('hi', ''), // Hindi
        ],
        locale: locale,
        home: Builder(builder: builder),
      );
    }

    testWidgets('App loads US English (en) strings correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        buildTestApp(const Locale('en', ''), (context) {
          l10n = AppLocalizations.of(context)!;
          return Text(l10n.appName);
        }),
      );

      await tester.pumpAndSettle();

      expect(l10n.appName, 'Wellnex');
      expect(find.text('Wellnex'), findsOneWidget);
    });

    testWidgets('App loads Hindi (hi) strings correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        buildTestApp(const Locale('hi', ''), (context) {
          l10n = AppLocalizations.of(context)!;
          return Text(l10n.appName);
        }),
      );

      await tester.pumpAndSettle();

      // Check Hindi translation (ensure this matches what is in app_hi.arb)
      expect(l10n.appName, 'Wellnex');
      expect(find.text('Wellnex'), findsOneWidget);
    });

    testWidgets('App loads UK English (en_GB) fallback correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        buildTestApp(const Locale('en', 'GB'), (context) {
          l10n = AppLocalizations.of(context)!;
          return Text(l10n.appName);
        }),
      );

      await tester.pumpAndSettle();

      // Should default to English 'Wellnex' or whatever en_GB override exists
      expect(l10n.appName, isNotEmpty);
    });
    
    testWidgets('App loads Indian English (en_IN) fallback correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        buildTestApp(const Locale('en', 'IN'), (context) {
          l10n = AppLocalizations.of(context)!;
          return Text(l10n.appTagline);
        }),
      );

      await tester.pumpAndSettle();

      expect(l10n.appTagline, isNotEmpty);
    });
  });
}
