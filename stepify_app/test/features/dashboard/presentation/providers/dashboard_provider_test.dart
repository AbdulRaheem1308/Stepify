import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/dashboard/presentation/providers/dashboard_provider.dart';

void main() {
  group('DashboardState', () {
    test('initializes with correct defaults', () {
      final state = DashboardState();
      
      expect(state.isLoading, false);
      expect(state.weeklyHistory, isEmpty);
      expect(state.xpLevel, 1);
      expect(state.xpCurrentProgress, 0);
      expect(state.xpToNextLevel, 1000);
      expect(state.syncStatus, SyncStatus.idle);
      expect(state.sensorStepsToday, 0);
      expect(state.sensorOffset, 0);
      expect(state.isSensorListening, false);
      expect(state.healthAuthorized, false);
    });

    test('copyWith updates fields correctly', () {
      final state = DashboardState().copyWith(
        isLoading: true,
        xpLevel: 5,
        syncStatus: SyncStatus.synced,
        healthAuthorized: true,
      );
      
      expect(state.isLoading, true);
      expect(state.xpLevel, 5);
      expect(state.syncStatus, SyncStatus.synced);
      expect(state.healthAuthorized, true);
      // Ensure others are unchanged
      expect(state.xpCurrentProgress, 0);
    });
  });

  group('TodaySteps', () {
    test('fromJson parses correctly', () {
      final json = {
        'stepCount': 5000,
        'caloriesBurned': 250,
        'distanceKm': 3.5,
        'activeMinutes': 45,
        'goal': 10000,
        'progress': 50,
        'goalReached': false,
      };

      final steps = TodaySteps.fromJson(json);

      expect(steps.stepCount, 5000);
      expect(steps.caloriesBurned, 250);
      expect(steps.distanceKm, 3.5);
      expect(steps.activeMinutes, 45);
      expect(steps.goal, 10000);
      expect(steps.progress, 50);
      expect(steps.goalReached, false);
    });

    test('copyWith updates fields correctly', () {
      final initial = TodaySteps(
        stepCount: 100,
        caloriesBurned: 10,
        distanceKm: 0.1,
        activeMinutes: 1,
        goal: 10000,
        progress: 1,
        goalReached: false,
      );

      final updated = initial.copyWith(stepCount: 200, progress: 2);
      
      expect(updated.stepCount, 200);
      expect(updated.progress, 2);
      expect(updated.goal, 10000); // Unchanged
    });
  });

  group('StreakInfo', () {
    test('fromJson parses correctly', () {
      final json = {
        'currentStreak': 5,
        'longestStreak': 10,
        'nextMilestone': 7,
        'daysToMilestone': 2,
      };

      final streak = StreakInfo.fromJson(json);

      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 10);
      expect(streak.nextMilestone, 7);
      expect(streak.daysToMilestone, 2);
    });
  });

  group('WalletInfo', () {
    test('fromJson parses correctly', () {
      final json = {
        'balance': 1500,
        'lifetimePoints': 5000,
        'monthlyXp': 1000,
      };

      final wallet = WalletInfo.fromJson(json);

      expect(wallet.balance, 1500);
      expect(wallet.lifetimePoints, 5000);
      expect(wallet.monthlyXp, 1000);
    });
  });
}
