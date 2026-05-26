import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/main.dart';
import 'package:stepify_app/core/router/app_router.dart';

void main() {
  testWidgets('StepifyApp creates successfully', (WidgetTester tester) async {
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );

    // Basic test to ensure the root widget can be constructed
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(mockRouter),
        ],
        child: const StepifyApp(),
      ),
    );
    
    // We just verify it pumps without throwing a critical widget error
    expect(find.byType(StepifyApp), findsOneWidget);
  });
}
