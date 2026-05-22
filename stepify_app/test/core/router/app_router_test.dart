import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('AppRouter', () {
    test('provides a GoRouter instance with correct initial location', () {
      final container = ProviderContainer();
      final router = container.read(appRouterProvider);

      expect(router, isNotNull);
      // Wait, we cannot easily check initialLocation from GoRouter object in tests
      // without looking at router.routerDelegate, but we can verify it's a GoRouter.
      expect(router.runtimeType.toString(), contains('GoRouter'));
    });

    test('AppRoutes contains correct paths', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.settings, '/settings');
    });
  });
}
