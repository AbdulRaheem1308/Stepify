import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:stepify_app/features/activities/presentation/screens/activity_history_screen.dart';
import 'package:stepify_app/features/activities/presentation/screens/activity_logging_screen.dart';
import 'package:stepify_app/features/settings/presentation/screens/settings_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stepify_app/services/storage_service.dart';

import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:dio/dio.dart';

class MockApiService extends ApiService {
  @override
  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters, CancelToken? cancelToken}) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {},
      statusCode: 200,
    );
  }
}

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.path);
    FlutterSecureStorage.setMockInitialValues({});
    await StorageService.init();
  });

  Widget createTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        apiServiceProvider.overrideWithValue(MockApiService()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: child,
      ),
    );
  }

  group('WCAG Accessibility Tests', () {
    // ─── Batch 1 ─────────────────────────────────────────────────────────────
    testWidgets('QuickActionCard meets tap target and contrast guidelines', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 120,
                child: QuickActionCard(
                  icon: Icons.directions_run,
                  title: 'Start Run',
                  subtitle: 'GPS Tracking',
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      final SemanticsNode semantics = tester.getSemantics(find.byType(QuickActionCard));
      expect(semantics.label, 'Start Run. GPS Tracking');
      expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    // ─── Batch 3: Analytics & Workouts UI ────────────────────────────────────

    testWidgets('ActivityHistoryScreen empty state meets tap target guideline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ActivityHistoryScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('ActivityHistoryScreen meets text contrast guideline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ActivityHistoryScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('ActivityLoggingScreen meets tap target guideline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ActivityLoggingScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('ActivityLoggingScreen meets text contrast guideline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ActivityLoggingScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('ActivityLoggingScreen has labeled tap targets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const ActivityLoggingScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    // ─── Batch 4: Profile & Settings UI ──────────────────────────────────────

    testWidgets('SettingsScreen meets tap target guideline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Toggle tiles onTap + Reset button must satisfy >= 48px
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('SettingsScreen meets text contrast guideline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('SettingsScreen has labeled tap targets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}

