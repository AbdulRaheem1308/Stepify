import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wellnex_app/features/profile/presentation/screens/edit_profile_screen.dart';
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
        home: EditProfileScreen(),
      ),
    );
  }

  testWidgets('EditProfileScreen loads user data into text fields', (WidgetTester tester) async {
    when(() => mockApiService.get('/users/avatars')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/users/avatars'), data: [], statusCode: 200),
    );

    final container = ProviderContainer(overrides: [
      apiServiceProvider.overrideWithValue(mockApiService),
    ]);

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('75'), findsOneWidget);
    expect(find.text('180'), findsOneWidget);
    
    // Check Step Goal
    expect(find.text('Daily Step Goal: 8000'), findsOneWidget);
  });
}
