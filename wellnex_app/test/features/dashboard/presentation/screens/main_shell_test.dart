import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wellnex_app/features/dashboard/presentation/screens/main_shell.dart';
import 'package:wellnex_app/services/ad_service.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAdService extends Mock implements AdService {}
class MockBannerAd extends Mock implements BannerAd {}
void main() {
  late MockAdService mockAdService;

  setUpAll(() {
    registerFallbackValue(VoidCallback);
  });

  setUp(() {
    mockAdService = MockAdService();
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(
            location: state.uri.path,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(mockAdService),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        routerConfig: router,
      ),
    );
  }

  group('MainShell Tests', () {
    testWidgets('Handles ad load success callback properly', (tester) async {
      final mockBannerAd = MockBannerAd();
      when(() => mockBannerAd.load()).thenAnswer((_) async {});
      when(() => mockBannerAd.dispose()).thenAnswer((_) async {});
      when(() => mockBannerAd.size).thenReturn(const AdSize(width: 320, height: 50));
      
      // Capture the callbacks passed to createBannerAd
      VoidCallback? capturedOnLoaded;
      
      when(() => mockAdService.createBannerAd(
        onAdLoaded: any(named: 'onAdLoaded'),
        onAdFailedToLoad: any(named: 'onAdFailedToLoad'),
      )).thenAnswer((invocation) {
        capturedOnLoaded = invocation.namedArguments[#onAdLoaded] as VoidCallback?;
        return mockBannerAd;
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Trigger the success callback
      expect(capturedOnLoaded, isNotNull);
      capturedOnLoaded?.call();
      // We do not pump the widget tree here because AdWidget will crash in test environments
      // without native platform views initialized, but the callback itself is covered.
    });

    testWidgets('Handles ad load failure callback properly', (tester) async {
      final mockBannerAd = MockBannerAd();
      when(() => mockBannerAd.load()).thenAnswer((_) async {});
      when(() => mockBannerAd.dispose()).thenAnswer((_) async {});
      when(() => mockBannerAd.size).thenReturn(const AdSize(width: 320, height: 50));
      
      Function(LoadAdError)? capturedOnFailed;
      
      when(() => mockAdService.createBannerAd(
        onAdLoaded: any(named: 'onAdLoaded'),
        onAdFailedToLoad: any(named: 'onAdFailedToLoad'),
      )).thenAnswer((invocation) {
        capturedOnFailed = invocation.namedArguments[#onAdFailedToLoad] as Function(LoadAdError)?;
        return mockBannerAd;
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Trigger the failure callback
      expect(capturedOnFailed, isNotNull);
      capturedOnFailed?.call(LoadAdError(1, 'domain', 'message', null));
      
      await tester.pumpAndSettle();
    });
  });
}
