import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/features/companies/presentation/screens/company_dashboard_screen.dart';
import 'package:wellnex_app/features/companies/presentation/providers/company_provider.dart';
import 'package:wellnex_app/features/companies/domain/models/company_model.dart';
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

  testWidgets('renders loading state', (tester) async {
    final mockState = CompanyState(isLoading: true);

    await tester.pumpWidget(createWidgetUnderTest(
      const CompanyDashboardScreen(),
      overrides: [
        companyProvider.overrideWith((ref) => MockCompanyNotifier(mockState)),
      ],
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders not a member state', (tester) async {
    final mockState = CompanyState(isLoading: false, member: null);

    await tester.pumpWidget(createWidgetUnderTest(
      const CompanyDashboardScreen(),
      overrides: [
        companyProvider.overrideWith((ref) => MockCompanyNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Not a member of any company'), findsOneWidget);
  });

  testWidgets('renders dashboard correctly', (tester) async {
    final mockMember = CompanyMember(
      id: '1',
      userId: 'u12345',
      companyId: 'c1',
      role: CompanyRole.employee,
      userMetadata: {'name': 'Alice'},
      totalSteps: 1000,
    );

    final mockState = CompanyState(
      isLoading: false,
      member: mockMember,
      leaderboard: [mockMember],
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const CompanyDashboardScreen(),
      overrides: [
        companyProvider.overrideWith((ref) => MockCompanyNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Corporate Wellness'), findsOneWidget);
    expect(find.text('Employee #u1234'), findsOneWidget);
    expect(find.text('EMPLOYEE'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('1000 steps'), findsOneWidget);
  });
}

class MockCompanyNotifier extends StateNotifier<CompanyState> implements CompanyNotifier {
  MockCompanyNotifier(super.state);

  @override
  Future<bool> joinCompany(String inviteCode) async => true;
}
