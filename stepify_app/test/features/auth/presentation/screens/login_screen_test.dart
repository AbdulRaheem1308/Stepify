import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/auth/presentation/screens/login_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:stepify_app/features/auth/services/social_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSocialAuthService extends Mock implements SocialAuthService {}

void main() {
  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    await StorageService.init();
    FlutterSecureStorage.setMockInitialValues({});
  });
  testWidgets('LoginScreen renders correctly with text and buttons', (tester) async {
    final mockSocialAuth = MockSocialAuthService();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          socialAuthServiceProvider.overrideWithValue(mockSocialAuth),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    if (exception != null) {
      print('BUILD EXCEPTION: $exception');
    }

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('Join the movement safely.'), findsOneWidget);
    expect(find.textContaining('Continue with Google'), findsOneWidget);
    expect(find.textContaining('Terms & Privacy Policy'), findsOneWidget);
  });
}
