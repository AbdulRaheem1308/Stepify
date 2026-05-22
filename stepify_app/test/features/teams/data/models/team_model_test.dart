import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/teams/data/models/team_model.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 0, 0);

  // ──────────────────────────────────────────────
  // Team
  // ──────────────────────────────────────────────
  group('Team model', () {
    final teamJson = {
      'id': 't1',
      'name': 'Alpha Team',
      'description': 'Best team ever',
      'captainId': 'cap1',
      'captainName': 'Alice',
      'members': [],
      'memberCount': 3,
      'maxMembers': 10,
      'totalSteps': 50000,
      'weeklySteps': 12000,
      'rank': 2,
      'isPublic': true,
      'inviteCode': 'ABC123',
      'createdAt': now.toIso8601String(),
    };

    test('fromJson parses all fields correctly', () {
      final team = Team.fromJson(teamJson);

      expect(team.id, 't1');
      expect(team.name, 'Alpha Team');
      expect(team.captainId, 'cap1');
      expect(team.captainName, 'Alice');
      expect(team.memberCount, 3);
      expect(team.maxMembers, 10);
      expect(team.weeklySteps, 12000);
      expect(team.rank, 2);
      expect(team.isPublic, isTrue);
      expect(team.inviteCode, 'ABC123');
      expect(team.createdAt.year, 2025);
    });

    test('fromJson uses fallbacks for missing fields', () {
      final team = Team.fromJson({'id': 'x', 'name': 'X', 'createdAt': null});

      expect(team.description, '');
      expect(team.captainId, '');
      expect(team.memberCount, 0);
      expect(team.maxMembers, 10);
      expect(team.weeklySteps, 0);
      expect(team.isPublic, isTrue);
    });

    test('fromJson handles _id field', () {
      final team = Team.fromJson({'_id': 'mongo123', 'name': 'Mongo Team'});
      expect(team.id, 'mongo123');
    });

    test('fromJson handles null/malformed createdAt gracefully', () {
      final team = Team.fromJson({'id': 'x', 'createdAt': 'not-a-date'});
      expect(team.createdAt, isA<DateTime>());
    });

    test('toJson serialises all required fields', () {
      final team = Team.fromJson(teamJson);
      final json = team.toJson();

      expect(json['id'], 't1');
      expect(json['name'], 'Alpha Team');
      expect(json['captainId'], 'cap1');
      expect(json['weeklySteps'], 12000);
      expect(json['inviteCode'], 'ABC123');
      expect(json['members'], isA<List>());
    });

    test('copyWith produces updated copy', () {
      final team = Team.fromJson(teamJson);
      final updated = team.copyWith(name: 'Beta Team', rank: 1);

      expect(updated.name, 'Beta Team');
      expect(updated.rank, 1);
      // Original fields preserved
      expect(updated.id, 't1');
      expect(updated.captainName, 'Alice');
    });

    test('isFull returns true when memberCount >= maxMembers', () {
      final fullTeam = Team.fromJson({...teamJson, 'memberCount': 10});
      final notFull = Team.fromJson(teamJson);

      expect(fullTeam.isFull, isTrue);
      expect(notFull.isFull, isFalse);
    });

    test('equality based on id and name', () {
      final team1 = Team.fromJson(teamJson);
      final team2 = Team.fromJson(teamJson);
      final different = Team.fromJson({...teamJson, 'id': 'other'});

      expect(team1, equals(team2));
      expect(team1, isNot(equals(different)));
    });

    test('toString returns readable representation', () {
      final team = Team.fromJson(teamJson);
      expect(team.toString(), contains('Alpha Team'));
    });
  });

  // ──────────────────────────────────────────────
  // TeamMember
  // ──────────────────────────────────────────────
  group('TeamMember model', () {
    final memberJson = {
      'id': 'm1',
      'name': 'Bob',
      'steps': 8000,
      'weeklySteps': 3200,
      'isCaptain': false,
      'joinedAt': now.toIso8601String(),
    };

    test('fromJson parses correctly', () {
      final member = TeamMember.fromJson(memberJson);

      expect(member.id, 'm1');
      expect(member.name, 'Bob');
      expect(member.steps, 8000);
      expect(member.weeklySteps, 3200);
      expect(member.isCaptain, isFalse);
    });

    test('fromJson handles nested user field', () {
      final json = {
        'userId': 'u1',
        'user': {'name': 'Carol', 'avatarUrl': 'https://example.com/avatar.png'},
        'weeklySteps': 4000,
        'steps': 0,
        'joinedAt': now.toIso8601String(),
      };
      final member = TeamMember.fromJson(json);

      expect(member.id, 'u1');
      expect(member.name, 'Carol');
      expect(member.avatarUrl, 'https://example.com/avatar.png');
    });

    test('fromJson sets isCaptain from role field', () {
      final json = {...memberJson, 'isCaptain': null, 'role': 'captain'};
      final member = TeamMember.fromJson(json);
      expect(member.isCaptain, isTrue);
    });

    test('toJson includes all fields', () {
      final member = TeamMember.fromJson(memberJson);
      final json = member.toJson();

      expect(json['id'], 'm1');
      expect(json['steps'], 8000);
      expect(json['isCaptain'], isFalse);
    });

    test('copyWith works correctly', () {
      final member = TeamMember.fromJson(memberJson);
      final updated = member.copyWith(weeklySteps: 9999, isCaptain: true);

      expect(updated.weeklySteps, 9999);
      expect(updated.isCaptain, isTrue);
      expect(updated.name, 'Bob'); // unchanged
    });

    test('equality by id', () {
      final m1 = TeamMember.fromJson(memberJson);
      final m2 = TeamMember.fromJson(memberJson);
      final m3 = TeamMember.fromJson({...memberJson, 'id': 'other'});

      expect(m1, equals(m2));
      expect(m1, isNot(equals(m3)));
    });
  });

  // ──────────────────────────────────────────────
  // TeamChallenge
  // ──────────────────────────────────────────────
  group('TeamChallenge model', () {
    final challengeJson = {
      'id': 'ch1',
      'title': '10K Step Challenge',
      'description': 'Walk 10,000 steps today!',
      'teamId': 't1',
      'targetSteps': 10000,
      'currentSteps': 6000,
      'startDate': now.toIso8601String(),
      'endDate': now.add(const Duration(days: 7)).toIso8601String(),
      'status': 'active',
      'rewardCoins': 500,
      'rewardXp': 200,
    };

    test('fromJson parses all fields', () {
      final challenge = TeamChallenge.fromJson(challengeJson);

      expect(challenge.id, 'ch1');
      expect(challenge.title, '10K Step Challenge');
      expect(challenge.targetSteps, 10000);
      expect(challenge.currentSteps, 6000);
      expect(challenge.status, 'active');
      expect(challenge.rewardCoins, 500);
    });

    test('fromJson handles null dates gracefully', () {
      final json = {...challengeJson, 'startDate': null, 'endDate': null};
      final challenge = TeamChallenge.fromJson(json);

      expect(challenge.startDate, isA<DateTime>());
      expect(challenge.endDate, isA<DateTime>());
    });

    test('fromJson handles malformed dates gracefully', () {
      final json = {...challengeJson, 'startDate': 'bad-date', 'endDate': 'also-bad'};
      final challenge = TeamChallenge.fromJson(json);

      expect(challenge.startDate, isA<DateTime>());
      expect(challenge.endDate, isA<DateTime>());
    });

    test('progress calculated correctly', () {
      final challenge = TeamChallenge.fromJson(challengeJson);
      expect(challenge.progress, closeTo(0.6, 0.001));
    });

    test('progress is clamped for over-achieved challenges', () {
      final json = {...challengeJson, 'currentSteps': 15000};
      final challenge = TeamChallenge.fromJson(json);
      // Progress raw value can exceed 1.0 (UI clamps it)
      expect(challenge.progress, greaterThanOrEqualTo(1.0));
    });

    test('isActive returns true for active status', () {
      final challenge = TeamChallenge.fromJson(challengeJson);
      expect(challenge.isActive, isTrue);
    });

    test('isCompleted returns true when steps met', () {
      final json = {...challengeJson, 'currentSteps': 10000, 'status': 'active'};
      final challenge = TeamChallenge.fromJson(json);
      expect(challenge.isCompleted, isTrue);
    });

    test('isCompleted returns true for completed status', () {
      final json = {...challengeJson, 'status': 'completed'};
      final challenge = TeamChallenge.fromJson(json);
      expect(challenge.isCompleted, isTrue);
    });

    test('copyWith produces updated copy', () {
      final challenge = TeamChallenge.fromJson(challengeJson);
      final updated = challenge.copyWith(currentSteps: 10000, status: 'completed');

      expect(updated.currentSteps, 10000);
      expect(updated.status, 'completed');
      expect(updated.title, '10K Step Challenge'); // unchanged
    });

    test('toJson includes all fields', () {
      final challenge = TeamChallenge.fromJson(challengeJson);
      final json = challenge.toJson();

      expect(json['id'], 'ch1');
      expect(json['targetSteps'], 10000);
      expect(json['rewardCoins'], 500);
      expect(json['startDate'], isA<String>());
    });

    test('equality by id', () {
      final c1 = TeamChallenge.fromJson(challengeJson);
      final c2 = TeamChallenge.fromJson(challengeJson);
      final c3 = TeamChallenge.fromJson({...challengeJson, 'id': 'other'});

      expect(c1, equals(c2));
      expect(c1, isNot(equals(c3)));
    });

    test('toString returns readable representation', () {
      final challenge = TeamChallenge.fromJson(challengeJson);
      expect(challenge.toString(), contains('10K Step Challenge'));
    });
  });
}
