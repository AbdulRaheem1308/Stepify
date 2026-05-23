import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/gamification/presentation/screens/xp_rules_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

void main() {
  testWidgets('XpRulesScreen renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1440, 2560);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const XpRulesScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify icons exist
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });
}
