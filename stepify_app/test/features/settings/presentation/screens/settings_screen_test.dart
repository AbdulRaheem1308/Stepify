import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:stepify_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: SettingsScreen(),
      ),
    );
  }

  testWidgets('SettingsScreen displays settings toggles', (tester) async {
    tester.view.physicalSize = const Size(1440, 2560);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));

    final state = const AppSettings(
      themeMode: 'dark',
      language: 'en',
      pushNotificationsEnabled: true,
      dailyRemindersEnabled: false,
    );

    final container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith((ref) {
          final notifier = SettingsNotifier(mockApiService);
          // Wait for load to finish or just override state
          notifier.state = state;
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    
    // Check toggle switch status
    final switches = tester.widgetList<Switch>(find.byType(Switch));
    expect(switches.isNotEmpty, true);
  });

  testWidgets('SettingsScreen shows error snackbar', (tester) async {
    tester.view.physicalSize = const Size(1440, 2560);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockApiService = MockApiService();
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200));

    late SettingsNotifier testNotifier;
    final container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith((ref) {
          testNotifier = SettingsNotifier(mockApiService);
          return testNotifier;
        }),
      ],
    );

    await tester.pumpWidget(createWidget(container));
    await tester.pumpAndSettle();
    
    // Trigger error state change
    testNotifier.state = testNotifier.state.copyWith(error: 'Failed to save settings');
    await tester.pump(); // Triggers listener
    await tester.pump(const Duration(milliseconds: 100)); // Triggers SnackBar animation
    expect(find.byType(SnackBar), findsOneWidget);

    // Let the SnackBar dismiss so we don't leave pending timers
    await tester.pumpAndSettle();
  });
}
