import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/gamification/presentation/providers/badges_provider.dart';
import 'package:stepify_app/features/gamification/presentation/screens/badges_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:stepify_app/services/api_service.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
  }

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: BadgesScreen()),
      ),
    );
  }

  final mockBadges = [
    Badge(
      id: 'b1',
      title: 'First Step',
      description: 'First test badge',
      category: 'Steps',
      status: BadgeStatus.unlocked,
      unlockCriteria: 'Do something',
      howToEarn: '1. Step\n2. Walk',
      pointsReward: 50,
      earnedDate: DateTime(2023, 1, 1),
    ),
    Badge(
      id: 'b2',
      title: 'Streak Fire',
      description: 'In progress streak',
      category: 'Streak',
      status: BadgeStatus.inProgress,
      progress: 0.5,
      currentValue: 5,
      targetValue: 10,
      unlockCriteria: 'Do something else',
      howToEarn: '1. Fire\n2. Run',
      pointsReward: 0,
    ),
    Badge(
      id: 'b3',
      title: 'Locked Legend',
      description: 'Locked badge',
      category: 'Social',
      status: BadgeStatus.locked,
      unlockCriteria: 'Socialize',
      howToEarn: 'Just talk',
      pointsReward: 100,
    ),
  ];

  testWidgets('BadgesScreen displays empty state when no badges', (tester) async {
    setScreenSize(tester);
    addTearDown(() => tester.view.reset());
    final container = ProviderContainer(
      overrides: [
        badgesProvider.overrideWith((ref) {
          final notifier = BadgesNotifier(ApiService());
          notifier.state = BadgesState(badges: [], isLoading: false);
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.stars), findsWidgets); // Empty state icon
  });

  testWidgets('BadgesScreen filters and displays badges correctly', (tester) async {
    setScreenSize(tester);
    addTearDown(() => tester.view.reset());
    final container = ProviderContainer(
      overrides: [
        badgesProvider.overrideWith((ref) {
          final notifier = BadgesNotifier(ApiService());
          notifier.state = BadgesState(badges: mockBadges, isLoading: false, activeFilter: 'All');
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('First Step'), findsOneWidget);
    expect(find.text('Streak Fire'), findsOneWidget);
    expect(find.text('Locked Legend'), findsOneWidget);

    // Test tapping a filter tab (e.g. Unlocked) - requires tapping the ChoiceChip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Unlocked').first);
    await tester.pumpAndSettle();
    
    // Test tapping a badge to show bottom sheet
    await tester.tap(find.text('First Step'));
    await tester.pumpAndSettle();
    
    expect(find.text('How You Earned It'), findsOneWidget);
    expect(find.text('+50 coins on unlock'), findsOneWidget);
    
    // Close the bottom sheet reliably
    Navigator.pop(tester.element(find.byType(BadgesScreen)));
    await tester.pumpAndSettle();

    // Set filter back to All so we can find the in-progress badge
    await tester.tap(find.widgetWithText(ChoiceChip, 'All').first);
    await tester.pumpAndSettle();

    // Tap in-progress badge
    await tester.tap(find.text('Streak Fire'));
    await tester.pumpAndSettle();
    expect(find.text('Your Progress'), findsOneWidget);
    expect(find.text('5 / 10'), findsOneWidget);
  });
  
  testWidgets('BadgesScreen bottom sheet edge cases', (tester) async {
    setScreenSize(tester);
    addTearDown(() => tester.view.reset());
    final lockedBadge = Badge(
      id: 'b3',
      title: 'Locked Legend',
      description: 'Locked badge',
      category: 'Social',
      status: BadgeStatus.locked,
      unlockCriteria: 'Socialize',
      howToEarn: 'Just talk',
      pointsReward: 100,
    );

    final container = ProviderContainer(
      overrides: [
        badgesProvider.overrideWith((ref) {
          final notifier = BadgesNotifier(ApiService());
          notifier.state = BadgesState(badges: [lockedBadge], isLoading: false, activeFilter: 'All');
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    // Ensure badge is visible
    await tester.ensureVisible(find.text('Locked Legend'));
    await tester.tap(find.text('Locked Legend'));
    await tester.pumpAndSettle();
    expect(find.text('Start Walking!'), findsOneWidget); // Locked button
    
    // Click Start Walking
    await tester.tap(find.text('Start Walking!'));
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsNothing); // Should pop
  });
}
