import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wellnex_app/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    await StorageService.init();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SplashScreen renders properly with animations', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('Login'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    // Initial pump
    expect(find.text('Wellnex'), findsOneWidget);
    expect(find.text('Walk • Track • Earn'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Give time for animations and timer to run
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
