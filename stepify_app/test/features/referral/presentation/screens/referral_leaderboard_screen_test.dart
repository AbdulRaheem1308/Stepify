import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/referral/presentation/providers/referral_provider.dart';
import 'package:stepify_app/features/referral/presentation/screens/referral_leaderboard_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:io';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    if (!Hive.isBoxOpen('stepify_storage')) {
      await StorageService.init();
    }
  });
  Widget createWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: ReferralLeaderboardScreen(),
      ),
    );
  }

  testWidgets('ReferralLeaderboardScreen shows loading state', (tester) async {
    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));

    final state = ReferralState(isLoading: true);
    final container = ProviderContainer(
      overrides: [
        referralProvider.overrideWith((ref) {
          final notifier = ReferralNotifier(mockApiService);
          notifier.state = state;
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createWidget(container));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ReferralLeaderboardScreen shows empty state', (tester) async {
    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));

    final state = ReferralState(isLoading: false, leaderboard: []);
    final container = ProviderContainer(
      overrides: [
        referralProvider.overrideWith((ref) {
          final notifier = ReferralNotifier(mockApiService);
          notifier.state = state;
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('No referrers yet'), findsOneWidget);
  });

  testWidgets('ReferralLeaderboardScreen shows list and stats', (tester) async {
    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));

    final stats = const ReferralStats(
      referralCode: 'TEST1',
      invitesAccepted: 5,
      coinsEarned: 250,
      rank: 4, // Make rank > 3 so it shows text
    );
    final leaderboard = [
      const TopReferrer(id: '1', name: 'Alice', referrals: 10, rank: 1),
      const TopReferrer(id: '2', name: 'Bob', referrals: 5, rank: 4),
    ];

    final state = ReferralState(isLoading: false, stats: stats, leaderboard: leaderboard);
    final container = ProviderContainer(
      overrides: [
        referralProvider.overrideWith((ref) {
          final notifier = ReferralNotifier(mockApiService);
          notifier.state = state;
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('#4'), findsWidgets); // One for user stats rank, one for Bob's rank
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('10 active', skipOffstage: false), findsOneWidget); // Alice referrals
    expect(find.text('250', skipOffstage: false), findsWidgets); // Raheem coins
    expect(find.text('5 active', skipOffstage: false), findsWidgets); // invites accepted and Bob's active

    await tester.pumpAndSettle();
  });

  testWidgets('ReferralLeaderboardScreen shows error snackbar', (tester) async {
    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenThrow(Exception('API Error'));

    final container = ProviderContainer(
      overrides: [
        referralProvider.overrideWith((ref) => ReferralNotifier(mockApiService)),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pumpAndSettle(); // Allow fetch and snackbar to run

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('API Error'), findsOneWidget);
  });
}
