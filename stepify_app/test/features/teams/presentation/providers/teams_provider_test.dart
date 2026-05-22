import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/features/teams/data/models/team_model.dart';
import 'package:stepify_app/features/teams/presentation/providers/teams_provider.dart';
import 'package:stepify_app/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late TeamsNotifier notifier;

  final testTeam = Team(
    id: 'team1',
    name: 'Alpha Team',
    description: 'The best team',
    captainId: 'cap1',
    captainName: 'Captain America',
    members: [],
    memberCount: 0,
    totalSteps: 10000,
    weeklySteps: 5000,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockApi = MockApiService();
    notifier = TeamsNotifier(mockApi);
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('TeamsNotifier', () {
    test('initial state is correct', () {
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.myTeams, isEmpty);
      expect(notifier.state.publicTeams, isEmpty);
      expect(notifier.state.teamChallenges, isEmpty);
      expect(notifier.state.currentTeam, isNull);
      expect(notifier.state.error, isNull);
    });

    test('fetchMyTeams sets state correctly on success', () async {
      when(() => mockApi.get('/teams/my-teams')).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: [testTeam.toJson()],
        statusCode: 200,
      ));

      await notifier.fetchMyTeams();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
      expect(notifier.state.myTeams.length, 1);
      expect(notifier.state.myTeams.first.name, 'Alpha Team');
    });

    test('fetchMyTeams sets error state on failure', () async {
      when(() => mockApi.get('/teams/my-teams')).thenThrow(Exception('API Error'));

      await notifier.fetchMyTeams();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('API Error'));
      expect(notifier.state.myTeams, isEmpty);
    });

    test('createTeam adds team to myTeams on success', () async {
      when(() => mockApi.post('/teams', data: any(named: 'data'))).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: testTeam.toJson(),
        statusCode: 201,
      ));

      final result = await notifier.createTeam(name: 'Alpha Team', description: 'desc');

      expect(result, isNotNull);
      expect(result!.name, 'Alpha Team');
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.myTeams.length, 1);
      expect(notifier.state.myTeams.first.name, 'Alpha Team');
    });

    test('clearError resets error state', () {
      // Setup error state
      when(() => mockApi.get('/teams/my-teams')).thenThrow(Exception('Error'));
      notifier.fetchMyTeams().then((_) {
        expect(notifier.state.error, isNotNull);
        
        notifier.clearError();
        
        expect(notifier.state.error, isNull);
      });
    });

    test('fetchTeamLeaderboard returns list on success', () async {
      when(() => mockApi.get('/teams/leaderboard')).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: [testTeam.toJson()],
        statusCode: 200,
      ));

      final leaderboard = await notifier.fetchTeamLeaderboard();

      expect(leaderboard.length, 1);
      expect(leaderboard.first.name, 'Alpha Team');
    });

    test('fetchTeamLeaderboard throws on failure', () async {
      when(() => mockApi.get('/teams/leaderboard')).thenThrow(Exception('API Error'));

      expect(() => notifier.fetchTeamLeaderboard(), throwsException);
    });
  });
}
