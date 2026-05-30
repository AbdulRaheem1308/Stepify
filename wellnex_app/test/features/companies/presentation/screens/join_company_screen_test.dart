import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/features/companies/presentation/screens/join_company_screen.dart';
import 'package:wellnex_app/features/companies/presentation/providers/company_provider.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('renders screen correctly', (tester) async {
    final mockState = CompanyState(isLoading: false);

    await tester.pumpWidget(createWidgetUnderTest(
      const JoinCompanyScreen(),
      overrides: [
        companyProvider.overrideWith((ref) => MockCompanyNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Join Company'), findsWidgets);
    expect(find.text('Enter Company Code'), findsOneWidget);
    expect(find.text('Invite Code'), findsOneWidget);
  });

  testWidgets('shows loading indicator when joining', (tester) async {
    final mockState = CompanyState(isLoading: true);

    await tester.pumpWidget(createWidgetUnderTest(
      const JoinCompanyScreen(),
      overrides: [
        companyProvider.overrideWith((ref) => MockCompanyNotifier(mockState)),
      ],
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message if failed', (tester) async {
    final mockState = CompanyState(isLoading: false, error: 'Invalid code');

    await tester.pumpWidget(createWidgetUnderTest(
      const JoinCompanyScreen(),
      overrides: [
        companyProvider.overrideWith((ref) => MockCompanyNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Invalid code'), findsOneWidget);
  });
}

class MockCompanyNotifier extends StateNotifier<CompanyState> implements CompanyNotifier {
  MockCompanyNotifier(super.state);

  @override
  Future<bool> joinCompany(String inviteCode) async => false;
}
