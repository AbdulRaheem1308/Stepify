import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/challenges/presentation/providers/challenges_provider.dart';
import 'package:stepify_app/features/challenges/presentation/widgets/challenge_card.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

void main() {
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
  }

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  final mockChallenge = Challenge(
    id: 'c1',
    title: 'Weekend Warrior',
    description: 'Walk 20k steps this weekend',
    stepTarget: 20000,
    rewardCoins: 500,
    rewardXp: 100,
    durationDays: 2,
    difficulty: 'EASY',
    challengeType: 'SOLO',
    participantCount: 150,
  );

  testWidgets('ChallengeCard displays unjoined state correctly', (tester) async {
    setScreenSize(tester);
    addTearDown(() => tester.view.reset());

    bool joined = false;

    await tester.pumpWidget(createTestWidget(
      ChallengeCard(
        challenge: mockChallenge,
        isJoined: false,
        onJoin: () {
          joined = true;
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Warrior'), findsOneWidget);
    expect(find.text('EASY'.toLowerCase()), findsOneWidget);
    expect(find.text('SOLO'.toLowerCase()), findsOneWidget);
    expect(find.text('20k'), findsOneWidget); // 20000 format
    
    // Tap Join button
    await tester.tap(find.byType(ElevatedButton));
    expect(joined, isTrue);
  });

  testWidgets('ChallengeCard displays joined state correctly and opens bottom sheet', (tester) async {
    setScreenSize(tester);
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(createTestWidget(
      ChallengeCard(
        challenge: mockChallenge,
        isJoined: true,
        currentSteps: 10000,
        progress: 50,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('50%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Tap card to open bottom sheet
    await tester.tap(find.byType(ChallengeCard));
    await tester.pumpAndSettle();

    expect(find.text('Your Progress'), findsOneWidget);
    expect(find.text('10k / 20k'), findsOneWidget);
    expect(find.text('Keep Walking! 50% done'), findsOneWidget);
    
    // Close sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
  });

  testWidgets('ChallengeCard displays completed state correctly in bottom sheet', (tester) async {
    setScreenSize(tester);
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(createTestWidget(
      ChallengeCard(
        challenge: mockChallenge,
        isJoined: true,
        currentSteps: 20000,
        progress: 100,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap card to open bottom sheet
    await tester.tap(find.byType(ChallengeCard));
    await tester.pumpAndSettle();

    expect(find.text('How You Completed It'), findsOneWidget);
    expect(find.text('Challenge Completed! 🎉'), findsOneWidget);
  });
}
