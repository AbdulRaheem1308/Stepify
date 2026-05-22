import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stepify_app/services/storage_service.dart';

void main() {
  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    await StorageService.init();
    FlutterSecureStorage.setMockInitialValues({});
  });
  testWidgets('OtpScreen renders correctly and shows 6 inputs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OtpScreen(phone: '+1234567890'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verify OTP'), findsOneWidget);
    expect(find.textContaining('+1234567890'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('Resend in 60s'), findsOneWidget);
  });
}
