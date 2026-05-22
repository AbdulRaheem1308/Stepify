import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/companies/presentation/providers/company_provider.dart';
import 'package:stepify_app/features/companies/domain/models/company_model.dart';
import 'package:stepify_app/services/company_service.dart';

class MockCompanyService extends Mock implements CompanyService {}

class MockRef extends Mock implements Ref {}

void main() {
  late MockCompanyService mockService;
  late MockRef mockRef;
  late CompanyNotifier notifier;

  setUp(() {
    mockService = MockCompanyService();
    mockRef = MockRef();

    when(() => mockService.getMyCompany()).thenAnswer((_) async => null);

    notifier = CompanyNotifier(mockService, mockRef);
  });

  group('CompanyNotifier', () {
    test('initial load sets member to null if none', () async {
      await Future.delayed(Duration.zero);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.member, isNull);
    });

    test('initial load fetches leaderboard if member exists', () async {
      final mockMember = CompanyMember(
        id: '1',
        userId: 'u1',
        companyId: 'c1',
        role: CompanyRole.employee,
      );

      when(() => mockService.getMyCompany()).thenAnswer((_) async => mockMember);
      when(() => mockService.getLeaderboard('c1')).thenAnswer((_) async => [mockMember]);

      final localNotifier = CompanyNotifier(mockService, mockRef);
      await Future.delayed(Duration.zero);

      expect(localNotifier.state.isLoading, isFalse);
      expect(localNotifier.state.member, mockMember);
      expect(localNotifier.state.leaderboard.length, 1);
    });

    test('joinCompany success updates state', () async {
      final mockMember = CompanyMember(
        id: '2',
        userId: 'u2',
        companyId: 'c2',
        role: CompanyRole.employee,
      );

      when(() => mockService.joinCompany('CODE123')).thenAnswer((_) async => mockMember);
      when(() => mockService.getLeaderboard('c2')).thenAnswer((_) async => [mockMember]);

      final result = await notifier.joinCompany('CODE123');

      expect(result, isTrue);
      expect(notifier.state.member, mockMember);
      expect(notifier.state.leaderboard.length, 1);
    });

    test('joinCompany failure sets error', () async {
      when(() => mockService.joinCompany('BADCODE')).thenThrow(Exception('Failed'));

      final result = await notifier.joinCompany('BADCODE');

      expect(result, isFalse);
      expect(notifier.state.error, isNotNull);
    });
  });
}
