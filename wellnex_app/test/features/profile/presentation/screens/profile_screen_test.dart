import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wellnex_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final temp = Directory.systemTemp.createTempSync();
    Hive.init(temp.path);
    await StorageService.init();
    await StorageService.saveUser({
      'name': 'Test User',
      'email': 'test@example.com',
      'dailyStepGoal': 8000,
      'age': 30,
      'weightKg': 75,
      'heightCm': 180,
    });
    mockApiService = MockApiService();
  });

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen shows overview, badges, activity, settings tabs', (WidgetTester tester) async {
    when(() => mockApiService.get(any())).thenAnswer((invocation) async {
      final path = invocation.positionalArguments[0] as String;
      if (path.contains('achievements') || path.contains('badges')) {
        return Response(requestOptions: RequestOptions(path: path), data: [], statusCode: 200);
      }
      return Response(requestOptions: RequestOptions(path: path), data: {}, statusCode: 200);
    });

    final container = ProviderContainer(overrides: [
      apiServiceProvider.overrideWithValue(mockApiService),
    ]);

    await tester.pumpWidget(createTestWidget(container));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Badges'), findsWidgets);
    expect(find.text('Activity'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    
    // Check if user info is displayed
    expect(find.text('Test User'), findsWidgets);
    
    // Check BMI label
    expect(find.text('Body Mass Index'), findsWidgets);
    expect(find.text('Normal'), findsWidgets); // 75 / (1.8*1.8) = 23.1
    
    // Dispose the widget tree to clean up any pending TabController timers
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
    container.dispose();
  });
}
