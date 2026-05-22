import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stepify_app/services/storage_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    await StorageService.init();
    FlutterSecureStorage.setMockInitialValues({});
  });
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  testWidgets('CompleteProfileScreen renders all form fields', (tester) async {
    when(() => mockApiService.get(any())).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: ''),
      data: []
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CompleteProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Complete Profile'), findsOneWidget);
    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Weight (kg)'), findsOneWidget);
    expect(find.text('Height (cm)'), findsOneWidget);
    expect(find.text('Complete Setup'), findsOneWidget);
    
    // Test goal slider text exists
    expect(find.textContaining('steps'), findsOneWidget);
  });
}
