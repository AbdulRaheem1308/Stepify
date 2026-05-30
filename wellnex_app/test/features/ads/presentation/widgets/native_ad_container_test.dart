import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:wellnex_app/features/ads/presentation/widgets/native_ad_container.dart';
import 'package:wellnex_app/services/ad_service.dart';
import 'package:wellnex_app/services/storage_service.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockAdService extends Mock implements AdService {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildTestable({
  List<Override> overrides = const [],
  String factoryId = 'adFactoryExample',
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: NativeAdContainer(factoryId: factoryId)),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockAdService mockAdService;

  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    await StorageService.init();
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    mockAdService = MockAdService();
  });

  group('NativeAdContainer', () {
    testWidgets('shows premium fallback when loadNativeAd returns null',
        (tester) async {
      when(() => mockAdService.loadNativeAd(factoryId: any(named: 'factoryId')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Fallback shows Wellnex Premium promo
      expect(find.text('Well Nex Premium'), findsOneWidget);
      expect(find.text('Ad Free Experience'), findsOneWidget);
      expect(find.text('Upgrade'), findsOneWidget);
    });

    testWidgets('shows premium fallback when loadNativeAd throws', (tester) async {
      when(() => mockAdService.loadNativeAd(factoryId: any(named: 'factoryId')))
          .thenThrow(Exception('AdMob error'));

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Well Nex Premium'), findsOneWidget);
    });

    testWidgets('fallback has WCAG Semantics label', (tester) async {
      when(() => mockAdService.loadNativeAd(factoryId: any(named: 'factoryId')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final semantics = find.bySemanticsLabel(
        RegExp(r'Well Nex Premium - Ad Free Experience'),
      );
      expect(semantics, findsOneWidget);
    });

    testWidgets('upgrade button is present and tappable in fallback',
        (tester) async {
      when(() => mockAdService.loadNativeAd(factoryId: any(named: 'factoryId')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Button exists and can be tapped without crash
      await tester.tap(find.text('Upgrade'));
      await tester.pump();
    });

    testWidgets('disposes native ad on unmount', (tester) async {
      when(() => mockAdService.loadNativeAd(factoryId: any(named: 'factoryId')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(_buildTestable(overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
      ]));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Remove widget — dispose should be called without error
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
