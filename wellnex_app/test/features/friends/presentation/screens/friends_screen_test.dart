import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/features/friends/presentation/screens/friends_screen.dart';
import 'package:wellnex_app/features/friends/presentation/providers/friends_provider.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createTestWidget(FriendsState initialState) {
    return ProviderScope(
      overrides: [
        friendsProvider.overrideWith((ref) => MockFriendsNotifier(initialState)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FriendsScreen(),
      ),
    );
  }

  testWidgets('FriendsScreen shows empty state correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(FriendsState(friends: [], leaderboard: [])));
    await tester.pumpAndSettle();

    expect(find.text('No friends yet'), findsOneWidget);
    expect(find.text('Invite Friends'), findsOneWidget);
  });

  testWidgets('FriendsScreen shows friends list and leaderboard', (tester) async {
    final friends = [
      Friend(
        id: 'f1',
        name: 'Alice',
        dailyStepCount: 8000,
      ),
    ];
    final leaderboard = [
      Friend(
        id: 'f2',
        name: 'Bob',
        dailyStepCount: 12000,
        rank: 1,
        isTopFriend: true,
      ),
    ];

    await tester.pumpWidget(createTestWidget(FriendsState(
      friends: friends,
      leaderboard: leaderboard,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('8.0k steps today'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('12.0k steps today'), findsOneWidget);
    expect(find.text('🏆 Friend Leaderboard'), findsOneWidget);
    expect(find.text('All Friends'), findsOneWidget);
  });
}

class MockFriendsNotifier extends StateNotifier<FriendsState> implements FriendsNotifier {
  MockFriendsNotifier(super.state);

  @override
  void clearSearch() {}

  @override
  Future<void> fetchFriendsData() async {}

  @override
  Future<void> searchUsers(String query) async {}

  @override
  Future<bool> sendBoost(String friendId) async {
    return true;
  }

  @override
  Future<bool> sendFriendRequest(String friendId) async {
    return true;
  }
}
