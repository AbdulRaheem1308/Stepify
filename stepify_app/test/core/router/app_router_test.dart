import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/core/router/app_router.dart';

void main() {
  test('AppRouter should provide a valid GoRouter instance', () {
    final container = ProviderContainer();
    
    final router = container.read(appRouterProvider);
    
    expect(router, isA<GoRouter>());
    expect(router.configuration.routes.isNotEmpty, isTrue);
    
    container.dispose();
  });
}
