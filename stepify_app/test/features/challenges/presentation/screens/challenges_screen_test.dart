import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:stepify_app/features/challenges/presentation/providers/challenges_provider.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('ChallengesScreen renders tabs and challenges', (tester) async {
    final mockState = ChallengesState(
      isLoading: false,
      newChallenges: [
        Challenge(
          id: 'c1',
          title: 'Morning Walk',
          description: 'Walk in the morning',
          stepTarget: 5000,
          rewardCoins: 20,
          rewardXp: 50,
          durationDays: 1,
          challengeType: 'SOLO',
          difficulty: 'EASY',
        )
      ],
      ongoingChallenges: [],
      completedChallenges: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const ChallengesScreen(),
      overrides: [
        challengesProvider.overrideWith((ref) => MockChallengesNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Challenges'), findsWidgets);
    expect(find.text('Morning Walk'), findsOneWidget);
    expect(find.text('Ongoing (0)'), findsOneWidget);
  });
}

class MockChallengesNotifier extends StateNotifier<ChallengesState> implements ChallengesNotifier {
  MockChallengesNotifier(super.state);

  @override
  Future<void> fetchAllChallenges() async {}

  @override
  Future<bool> joinChallenge(String challengeId) async {
    return true;
  }
}
