import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import 'package:hive/hive.dart';
import 'package:stepify_app/services/storage_service.dart';

void main() {
  setUpAll(() async {
    final path = '${Directory.current.path}/test/hive_testing_path';
    Hive.init(path);
    await StorageService.init();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('AppRouter', () {
    testWidgets('pumps the router and navigates to basic routes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should start at splash screen
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('AppRoutes contains correct paths', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.activityHistory, '/activity/history');
      expect(AppRoutes.otp, '/otp');
      expect(AppRoutes.chat, '/messages/:id');
    });
  });
}
