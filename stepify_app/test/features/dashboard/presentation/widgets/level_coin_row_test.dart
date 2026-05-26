import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/level_coin_row.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/explainer_bottom_sheet.dart';

void main() {
  testWidgets('LevelCoinRow renders and handles taps', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.reset());
    
    bool levelTapped = false;
    bool coinTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelCoinRow(
            level: 3,
            currentXp: 500,
            nextLevelXp: 1000,
            coins: 1250,
            onLevelTap: () => levelTapped = true,
            onCoinTap: () => coinTapped = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1250'), findsOneWidget);

    // Tap Level section
    await tester.tap(find.text('Level 3'));
    await tester.pumpAndSettle();
    expect(levelTapped, isTrue);

    // Tap Coin section
    await tester.tap(find.text('1250'));
    await tester.pumpAndSettle();
    expect(coinTapped, isTrue);
  });

  testWidgets('LevelCoinRow info icon opens explainer', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelCoinRow(
            level: 3,
            currentXp: 500,
            nextLevelXp: 1000,
            coins: 1250,
            onLevelTap: () {},
            onCoinTap: () {},
          ),
        ),
      ),
    );

    // Tap info icon
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.byType(ExplainerBottomSheet), findsOneWidget);
  });
}
