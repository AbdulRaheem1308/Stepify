import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../services/api_service.dart';
import '../../../../services/storage_service.dart';
import 'package:stepify_app/services/health_service.dart';
import 'package:stepify_app/services/pedometer_service.dart';
import 'package:stepify_app/features/devices/presentation/providers/device_provider.dart';

/// Dashboard state model
class DashboardState {
  final bool isLoading;
  final TodaySteps? todaySteps;
  final StreakInfo? streak;
  final WalletInfo? wallet;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? userStats;
  final List<DailyStep> weeklyHistory;
  final String? error;
  
  // XP System
  final int xpLevel;
  final int xpCurrentProgress; // 0-100
  final int xpToNextLevel;
  
  // Sync Status
  final SyncStatus syncStatus;
  final DateTime? lastSyncTime;

  // Diagnostics & Debugging Info
  final int sensorStepsToday;
  final int sensorOffset;
  final bool isSensorListening;
  final bool healthAuthorized;
  final String? sensorErrorMessage;

  DashboardState({
    this.isLoading = false,
    this.todaySteps,
    this.streak,
    this.wallet,
    this.user,
    this.userStats,
    this.weeklyHistory = const [],
    this.error,
    this.xpLevel = 1,
    this.xpCurrentProgress = 0,
    this.xpToNextLevel = 1000,
    this.syncStatus = SyncStatus.idle,
    this.lastSyncTime,
    this.sensorStepsToday = 0,
    this.sensorOffset = 0,
    this.isSensorListening = false,
    this.healthAuthorized = false,
    this.sensorErrorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    TodaySteps? todaySteps,
    StreakInfo? streak,
    WalletInfo? wallet,
    Map<String, dynamic>? user,
    Map<String, dynamic>? userStats,
    List<DailyStep>? weeklyHistory,
    String? error,
    int? xpLevel,
    int? xpCurrentProgress,
    int? xpToNextLevel,
    SyncStatus? syncStatus,
    DateTime? lastSyncTime,
    int? sensorStepsToday,
    int? sensorOffset,
    bool? isSensorListening,
    bool? healthAuthorized,
    String? sensorErrorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      todaySteps: todaySteps ?? this.todaySteps,
      streak: streak ?? this.streak,
      wallet: wallet ?? this.wallet,
      user: user ?? this.user,
      userStats: userStats ?? this.userStats,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      error: error,
      xpLevel: xpLevel ?? this.xpLevel,
      xpCurrentProgress: xpCurrentProgress ?? this.xpCurrentProgress,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      sensorStepsToday: sensorStepsToday ?? this.sensorStepsToday,
      sensorOffset: sensorOffset ?? this.sensorOffset,
      isSensorListening: isSensorListening ?? this.isSensorListening,
      healthAuthorized: healthAuthorized ?? this.healthAuthorized,
      sensorErrorMessage: sensorErrorMessage ?? this.sensorErrorMessage,
    );
  }
}

enum SyncStatus { idle, syncing, synced, failed }

class TodaySteps {
  final int stepCount;
  final int caloriesBurned;
  final double distanceKm;
  final int activeMinutes;
  final int goal;
  final int progress;
  final bool goalReached;

  TodaySteps({
    required this.stepCount,
    required this.caloriesBurned,
    required this.distanceKm,
    required this.activeMinutes,
    required this.goal,
    required this.progress,
    required this.goalReached,
  });

  factory TodaySteps.fromJson(Map<String, dynamic> json) {
    return TodaySteps(
      stepCount: json['stepCount'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      distanceKm: double.tryParse(json['distanceKm']?.toString() ?? '0') ?? 0.0,
      activeMinutes: json['activeMinutes'] ?? 0,
      goal: json['goal'] ?? 10000,
      progress: json['progress'] ?? 0,
      goalReached: json['goalReached'] ?? false,
    );
  }
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int? nextMilestone;
  final int? daysToMilestone;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.nextMilestone,
    this.daysToMilestone,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      nextMilestone: json['nextMilestone'],
      daysToMilestone: json['daysToMilestone'],
    );
  }
}

class WalletInfo {
  final int balance;
  final int lifetimePoints;
  final int? monthlyXp;

  WalletInfo({
    required this.balance,
    required this.lifetimePoints,
    this.monthlyXp,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: json['balance'] ?? 0,
      lifetimePoints: json['lifetimePoints'] ?? 0,
      monthlyXp: json['monthlyXp'],
    );
  }
}

class DailyStep {
  final DateTime date;
  final int steps;

  DailyStep({required this.date, required this.steps});
}

/// Dashboard Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(healthServiceProvider),
  );
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _apiService;
  final HealthService _healthService;
  final PedometerService _pedometerService = PedometerService();

  int _lastSyncedSteps = 0;
  DateTime? _lastSyncedTime;
  
  int _currentPedometerSteps = 0;
  int _pedometerOffset = 0;
  bool _pedometerOffsetInitialized = false;
  
  Timer? _uiBatchTimer;

  DashboardNotifier(this._apiService, this._healthService) : super(DashboardState()) {
    _loadUser();
    _initHardwarePedometer();
  }

  void _initHardwarePedometer() {
    // 1. Start the live pedometer independently so it doesn't get blocked by Health API OAuth
    _pedometerService.startListening(
      onStepsChanged: (stepsToday) {
        _currentPedometerSteps = stepsToday;
        
        if (!_pedometerOffsetInitialized && state.todaySteps != null) {
          final backendSteps = state.todaySteps!.stepCount;
          _pedometerOffset = backendSteps - stepsToday;
          if (_pedometerOffset < 0) _pedometerOffset = 0;
          _pedometerOffsetInitialized = true;
          
          // Immediately sync once when initializing
          syncSteps(stepsToday + _pedometerOffset);
        }

        state = state.copyWith(
          sensorStepsToday: stepsToday,
          sensorOffset: _pedometerOffset,
          isSensorListening: _pedometerService.isListening,
        );
      },
      onErrorOccurred: (err) {
        state = state.copyWith(
          sensorErrorMessage: err,
          isSensorListening: _pedometerService.isListening,
        );
      },
    );

    // 2. Request Health SDK (Google Fit) authorization
    Future.microtask(() async {
      final authorized = await _healthService.requestAuthorization();
      state = state.copyWith(
        healthAuthorized: authorized,
      );
    });
      // Batch UI updates every 5 seconds to prevent jitter and save resources
      _uiBatchTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        int stepsToSync = 0;
        final isAuth = await _healthService.requestAuthorization();
        
        if (_currentPedometerSteps > 0) {
          // Use real-time physical sensor steps
          stepsToSync = _pedometerOffsetInitialized 
              ? _currentPedometerSteps + _pedometerOffset 
              : _currentPedometerSteps;
        } else {
          // Fallback: Query Google Fit / Health Connect / HealthKit
          try {
            if (isAuth) {
              final healthSteps = await _healthService.getTodaySteps();
              if (healthSteps > 0) {
                stepsToSync = healthSteps;
                debugPrint('Pedometer: Falling back to Health Service steps: $healthSteps');
              }
            }
          } catch (e) {
            debugPrint('Pedometer: Fallback Health Service query failed: $e');
          }
        }

        state = state.copyWith(
          healthAuthorized: isAuth,
          sensorStepsToday: _currentPedometerSteps,
          sensorOffset: _pedometerOffset,
          isSensorListening: _pedometerService.isListening,
        );
        
        if (stepsToSync > 0) {
          // Only trigger if steps actually changed
          if (state.todaySteps == null || stepsToSync > state.todaySteps!.stepCount) {
             syncSteps(stepsToSync);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _uiBatchTimer?.cancel();
    super.dispose();
  }

  void _loadUser() {
    final user = StorageService.getUser();
    state = state.copyWith(user: user);
  }

  Future<void> fetchTodayData() async {
    state = state.copyWith(isLoading: true, syncStatus: SyncStatus.syncing);

    // Auto-sync steps from local sensors first (sync last 7 days of history in parallel to capture past offline steps)
    try {
      // Automatically pre-authorize and request permissions on startup so the physical mobile phone's built-in pedometer tracks out-of-the-box
      final authorized = await _healthService.requestAuthorization();
      if (authorized) {
        final historyMap = await _healthService.getStepHistory(7);
        final List<Future> syncTasks = [];
        for (final entry in historyMap.entries) {
          final dateStr = entry.key.toIso8601String().split('T')[0];
          final steps = entry.value;
          if (steps > 0) {
            syncTasks.add(
              () async {
                try {
                  await _apiService.post('/steps/sync', data: {
                    'date': dateStr,
                    'stepCount': steps,
                    'source': 'phone_sensors',
                  });
                } catch (err) {
                  print('Failed to sync steps for $dateStr: $err');
                }
              }()
            );
          }
        }
        if (syncTasks.isNotEmpty) {
          await Future.wait(syncTasks);
        }
      }
    } catch (e) {
      print('Auto-sync steps error: $e');
    }

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _apiService.get('/steps/today'),
        _apiService.get('/rewards/streak'),
        _apiService.get('/rewards/wallet'),
        _apiService.get('/steps/weekly'),
        _apiService.get('/users/me'),
        _apiService.get('/users/me/stats'),
      ]);

      // Calculate XP based on monthly XP (Season Level)
      final walletData = WalletInfo.fromJson(results[2].data);
      // Fallback to lifetimePoints if monthlyXp is missing (e.g. older users before migration)
      final xpInfo = _calculateXpLevel(walletData.monthlyXp ?? 0);

      // Parse weekly history
      final weeklyData = results[3].data['dailyBreakdown'] as List;
      final history = weeklyData.map((d) => DailyStep(
        date: DateTime.parse(d['date']),
        steps: d['stepCount'],
      )).toList();

      // Update local storage with fresh user data
      final userData = results[4].data;
      await StorageService.saveUser(userData);

      // User Stats
      final userStats = results[5].data;

      final backendStepsData = results[0].data;
      final backendSteps = backendStepsData['stepCount'] ?? 0;
      
      // Calculate offset if not initialized, OR update it if backend has more steps (e.g. smartwatch synced)
      final expectedTotal = _currentPedometerSteps + _pedometerOffset;
      if (backendSteps > expectedTotal) {
         _pedometerOffset = backendSteps - _currentPedometerSteps;
         if (_pedometerOffset < 0) _pedometerOffset = 0;
         _pedometerOffsetInitialized = true;
      } else if (!_pedometerOffsetInitialized) {
         _pedometerOffset = backendSteps - _currentPedometerSteps;
         if (_pedometerOffset < 0) _pedometerOffset = 0;
         _pedometerOffsetInitialized = true;
      }

      state = state.copyWith(
        isLoading: false,
        todaySteps: TodaySteps.fromJson(backendStepsData),
        streak: StreakInfo.fromJson(results[1].data),
        wallet: walletData,
        xpLevel: xpInfo['level'],
        xpCurrentProgress: xpInfo['progress'],
        xpToNextLevel: xpInfo['toNextLevel'],
        syncStatus: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        weeklyHistory: history,
        user: userData,
        userStats: userStats,
      );
    } catch (e) {
      // On error, handle gracefully and reset loading state
      state = state.copyWith(
        isLoading: false,
        error: ApiError.from(e).message,
        syncStatus: SyncStatus.failed,
      );
    }
  }
  
  /// Calculate XP level based on monthly points (Seasonal Level)
  Map<String, int> _calculateXpLevel(int points) {
    // XP thresholds: Level 1 = 0-999, Level 2 = 1000-2499, etc.
    const xpPerLevel = 1000;
    const levelMultiplier = 1.5;
    
    int level = 1;
    int totalXpForCurrentLevel = 0;
    int xpForNextLevel = xpPerLevel;
    
    int remainingPoints = points;
    
    while (remainingPoints >= xpForNextLevel) {
      remainingPoints -= xpForNextLevel;
      level++;
      totalXpForCurrentLevel += xpForNextLevel;
      xpForNextLevel = (xpPerLevel * (1 + (level - 1) * 0.5)).toInt();
    }
    
    final progress = ((remainingPoints / xpForNextLevel) * 100).toInt();
    final toNextLevel = xpForNextLevel - remainingPoints;
    
    return {
      'level': level,
      'progress': progress,
      'toNextLevel': toNextLevel,
    };
  }

  // Removed _generateDemoHistory


  Future<void> syncSteps(int stepCount) async {
    // 1. Optimistic UI update instantly on every step event
    if (state.todaySteps != null) {
      final currentSteps = state.todaySteps!.stepCount;
      // Only update if steps actually increased (or we had 0)
      if (stepCount > currentSteps || currentSteps == 0) {
        final goal = state.todaySteps!.goal > 0 ? state.todaySteps!.goal : 10000;
        state = state.copyWith(
          todaySteps: TodaySteps(
            stepCount: stepCount,
            caloriesBurned: (stepCount * 0.045).round(),
            distanceKm: stepCount * 0.000762,
            activeMinutes: state.todaySteps!.activeMinutes,
            goal: goal,
            progress: ((stepCount / goal) * 100).toInt(),
            goalReached: stepCount >= goal,
          ),
        );
      }
    }

    if (stepCount == _lastSyncedSteps) return;

    final now = DateTime.now();
    final stepDiff = (stepCount - _lastSyncedSteps).abs();
    final timeDiff = _lastSyncedTime == null ? const Duration(seconds: 999) : now.difference(_lastSyncedTime!);

    // Throttling: Only hit the backend if the user walked at least 10 steps, or 30 seconds have passed since the last sync
    if (stepDiff >= 10 || timeDiff.inSeconds >= 30) {
      _lastSyncedSteps = stepCount;
      _lastSyncedTime = now;
      
      try {
        final today = now.toIso8601String().split('T')[0];
        
        await _apiService.post('/steps/sync', data: {
          'date': today,
          'stepCount': stepCount,
          'source': 'phone_sensors',
        });
        
        // Removed fetchTodayData() here to prevent infinite loop and health dialog popups
      } catch (e) {
        print('Pedometer: Failed to sync stepCount $stepCount: $e');
      }
    }
  }
  Future<void> updateDailyGoal(int newGoal) async {
    try {
      // Optimistically update today's steps goal
      if (state.todaySteps != null) {
        state = state.copyWith(
          todaySteps: TodaySteps(
            stepCount: state.todaySteps!.stepCount,
            caloriesBurned: state.todaySteps!.caloriesBurned,
            distanceKm: state.todaySteps!.distanceKm,
            activeMinutes: state.todaySteps!.activeMinutes,
            goal: newGoal,
            progress: ((state.todaySteps!.stepCount / newGoal) * 100).toInt(),
            goalReached: state.todaySteps!.stepCount >= newGoal,
          ),
        );
      }

      // Call API to save to user profile
      await _apiService.put('/users/me', data: {
        'dailyStepGoal': newGoal,
      });

      // Optionally refresh to ensure full sync
      // await fetchTodayData(); 
    } catch (e) {
      // Revert or show error (for now just log/ignore in this notifier)
      // Ideally we would revert the optimistic update here
      
      // If using snackbar service, show error here
    }
  }
}
