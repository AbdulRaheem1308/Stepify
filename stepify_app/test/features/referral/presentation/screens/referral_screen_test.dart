import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/referral/presentation/providers/referral_provider.dart';
import 'package:stepify_app/features/referral/presentation/screens/referral_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReferralScreen(),
      ),
    );
  }

  testWidgets('ReferralScreen shows loading state', (tester) async {
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

  testWidgets('ReferralScreen displays stats and code correctly', (tester) async {
    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));

    final stats = const ReferralStats(
      referralCode: 'TEST1234',
      invitesSent: 10,
      invitesAccepted: 4,
      coinsEarned: 200,
      milestones: [
        ReferralMilestone(target: 1, reward: 50, isUnlocked: true),
        ReferralMilestone(target: 5, reward: 100, isUnlocked: false),
      ],
    );
    final leaderboard = [
      const TopReferrer(id: '1', name: 'Alice', referrals: 10, rank: 1),
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

    // Wait for animations
    await tester.pumpAndSettle();

    expect(find.text('TEST1234', skipOffstage: false), findsWidgets);
    expect(find.text('10', skipOffstage: false), findsOneWidget); // invites sent
    expect(find.text('4', skipOffstage: false), findsWidgets); // invites accepted
    expect(find.text('200', skipOffstage: false), findsOneWidget); // coins earned

    // Check milestones
    expect(find.text('Progress', skipOffstage: false), findsOneWidget);
    expect(find.text('Completed!', skipOffstage: false), findsWidgets);
    
    // Check leaderboard
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    
    expect(find.text('Alice', skipOffstage: false), findsOneWidget);
    expect(find.text('10 invites', skipOffstage: false), findsOneWidget);
  });

  testWidgets('ReferralScreen shows error snackbar', (tester) async {
    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenThrow(Exception('API Error'));

    final container = ProviderContainer(
      overrides: [
        referralProvider.overrideWith((ref) => ReferralNotifier(mockApiService)),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('API Error'), findsOneWidget);
  });
}
