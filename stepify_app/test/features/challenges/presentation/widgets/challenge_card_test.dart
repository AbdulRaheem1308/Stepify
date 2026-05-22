import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/challenges/presentation/widgets/challenge_card.dart';
import 'package:stepify_app/features/challenges/presentation/providers/challenges_provider.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('ChallengeCard renders correctly when not joined', (tester) async {
    final challenge = Challenge(
      id: 'c1',
      title: 'Weekend Warrior',
      description: 'Walk 10k steps this weekend.',
      stepTarget: 10000,
      rewardCoins: 50,
      rewardXp: 100,
      durationDays: 2,
      challengeType: 'SOLO',
      difficulty: 'MEDIUM',
    );

    await tester.pumpWidget(createWidgetUnderTest(
      ChallengeCard(challenge: challenge, isJoined: false),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Warrior'), findsOneWidget);
    expect(find.text('medium'), findsOneWidget); // tag
    expect(find.text('solo'), findsOneWidget); // tag
    expect(find.text('10k'), findsOneWidget); // formatNumber
    expect(find.text('50'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Join Challenge'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('ChallengeCard renders progress bar when joined', (tester) async {
    final challenge = Challenge(
      id: 'c2',
      title: 'Marathon Month',
      description: 'Walk 100k steps this month.',
      stepTarget: 100000,
      rewardCoins: 500,
      rewardXp: 1000,
      durationDays: 30,
      challengeType: 'GROUP',
      difficulty: 'HARD',
    );

    await tester.pumpWidget(createWidgetUnderTest(
      ChallengeCard(
        challenge: challenge,
        isJoined: true,
        currentSteps: 50000,
        progress: 50,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Marathon Month'), findsOneWidget);
    expect(find.text('hard'), findsOneWidget);
    expect(find.text('group'), findsOneWidget);
    expect(find.text('100k'), findsOneWidget);
    expect(find.text('Join Challenge'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('ChallengeCard triggers onJoin callback', (tester) async {
    bool joined = false;
    final challenge = Challenge(
      id: 'c1',
      title: 'Test',
      description: 'Test desc',
      stepTarget: 100,
      rewardCoins: 10,
      rewardXp: 10,
      durationDays: 1,
      challengeType: 'SOLO',
      difficulty: 'EASY',
    );

    await tester.pumpWidget(createWidgetUnderTest(
      ChallengeCard(
        challenge: challenge,
        isJoined: false,
        onJoin: () {
          joined = true;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Join Challenge'));
    await tester.pumpAndSettle();

    expect(joined, isTrue);
  });
}
