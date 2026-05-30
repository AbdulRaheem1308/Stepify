import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:wellnex_app/features/ads/presentation/screens/ads_reward_screen.dart';
import 'package:wellnex_app/services/ad_service.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/services/storage_service.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockAdService extends Mock implements AdService {}
class MockApiService extends Mock implements ApiService {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Response<dynamic> _dioResp(Map<String, dynamic> data, {int statusCode = 200}) =>
    Response(requestOptions: RequestOptions(path: ''), data: data, statusCode: statusCode);

Widget _buildTestable({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdsRewardScreen(),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockAdService mockAdService;
  late MockApiService mockApiService;

  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    await StorageService.init();
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    mockAdService = MockAdService();
    mockApiService = MockApiService();

    // Stub onAuthFailure setter/getter (required by AuthNotifier construction)
    when(() => mockApiService.onAuthFailure).thenReturn(null);
    // ignore setter
    when(() => mockApiService.onAuthFailure = any()).thenReturn(null);

    // Default: canWatch=true, 3 views today, no cooldown
    when(() => mockApiService.get('/ads/can-watch')).thenAnswer(
      (_) async => _dioResp({'canWatch': true, 'cooldownRemaining': 0, 'todayViews': 3}),
    );

    // Rewarded ad not ready → triggers fallback
    when(() => mockAdService.isRewardedAdReady).thenReturn(false);
    when(() => mockAdService.rewardedAdUnitId).thenReturn('test-ad-unit');
    when(() => mockAdService.showRewardedAd(
          onUserEarnedReward: any(named: 'onUserEarnedReward'),
          onAdFailedToShow: any(named: 'onAdFailedToShow'),
        )).thenReturn(null);
  });

  // ── Unit: _formatTime helper ─────────────────────────────────────────────

  group('_formatTime helper', () {
    test('formats 0s as 00:00', () => expect(_fmt(0), '00:00'));
    test('formats 90s as 01:30', () => expect(_fmt(90), '01:30'));
    test('formats 3600s as 60:00', () => expect(_fmt(3600), '60:00'));
    test('formats 65s as 01:05', () => expect(_fmt(65), '01:05'));
  });

  // ── Widget tests ─────────────────────────────────────────────────────────

  group('AdsRewardScreen', () {
    testWidgets('renders AdsRewardScreen widget correctly', (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      // Just first frame — widget tree is built
      await tester.pump();

      // Screen itself exists (loading or loaded)
      expect(find.byType(AdsRewardScreen), findsOneWidget);
    });

    testWidgets('renders Watch & Earn app bar title after load', (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Watch & Earn'), findsWidgets);
    });

    testWidgets('shows Today and Remaining stat cards', (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('shows Watch Ad Now button when canWatch=true and under limit',
        (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Watch Ad Now'), findsOneWidget);
    });

    testWidgets('shows Daily limit reached when todayViews >= maxDailyAds',
        (tester) async {
      when(() => mockApiService.get('/ads/can-watch')).thenAnswer(
        (_) async => _dioResp({'canWatch': false, 'cooldownRemaining': 0, 'todayViews': 10}),
      );

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Daily limit reached!'), findsOneWidget);
      expect(find.text('Come back tomorrow'), findsOneWidget);
    });

    testWidgets('shows cooldown timer when cooldownRemaining > 0', (tester) async {
      when(() => mockApiService.get('/ads/can-watch')).thenAnswer(
        (_) async =>
            _dioResp({'canWatch': false, 'cooldownRemaining': 90, 'todayViews': 5}),
      );

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      // Pump just long enough for the API call to resolve but NOT long enough
      // for the 1-second timer tick to fire.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Next ad available in'), findsOneWidget);
      // Timer hasn't ticked yet — should still read 01:30
      expect(find.text('01:30'), findsOneWidget);
    });

    testWidgets('falls back gracefully on API error (canWatch=true, todayViews=3)',
        (tester) async {
      when(() => mockApiService.get('/ads/can-watch'))
          .thenThrow(Exception('network error'));

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Fallback: canWatch=true → shows Watch Ad Now
      expect(find.text('Watch Ad Now'), findsOneWidget);
    });

    testWidgets('AppBar has back arrow button', (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Watch Ad Now button triggers showRewardedAd', (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('Watch Ad Now'));
      await tester.pump();

      verify(() => mockAdService.showRewardedAd(
            onUserEarnedReward: any(named: 'onUserEarnedReward'),
            onAdFailedToShow: any(named: 'onAdFailedToShow'),
          )).called(1);
    });

    testWidgets('stat Today card has WCAG semantic label', (tester) async {
      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.bySemanticsLabel(RegExp(r'Today:')), findsOneWidget);
    });

    testWidgets('simulation dialog appears when ad fails to show', (tester) async {
      when(() => mockApiService.post('/ads/claim', data: any(named: 'data')))
          .thenAnswer((_) async => _dioResp({}, statusCode: 200));

      when(() => mockAdService.showRewardedAd(
            onUserEarnedReward: any(named: 'onUserEarnedReward'),
            onAdFailedToShow: any(named: 'onAdFailedToShow'),
          )).thenAnswer((invocation) {
        final onFail =
            invocation.namedArguments[#onAdFailedToShow] as VoidCallback;
        onFail();
      });

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
        apiServiceProvider.overrideWithValue(mockApiService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('Watch Ad Now'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}

/// Mirrors the private _formatTime logic for unit-level testing.
String _fmt(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
