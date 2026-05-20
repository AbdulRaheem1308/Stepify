import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';
import '../../../../services/storage_service.dart';

// ---------------------------------------------------------------------------
// Activity options catalogue
// ---------------------------------------------------------------------------
const kActivityOptions = [
  {'id': 'walking',  'label': 'Walking',  'emoji': '🚶'},
  {'id': 'running',  'label': 'Running',  'emoji': '🏃'},
  {'id': 'cycling',  'label': 'Cycling',  'emoji': '🚴'},
  {'id': 'swimming', 'label': 'Swimming', 'emoji': '🏊'},
  {'id': 'yoga',     'label': 'Yoga',     'emoji': '🧘'},
  {'id': 'gym',      'label': 'Gym',      'emoji': '🏋️'},
  {'id': 'hiking',   'label': 'Hiking',   'emoji': '🥾'},
  {'id': 'dance',    'label': 'Dance',    'emoji': '💃'},
];

// ---------------------------------------------------------------------------
// Fitness Level metadata
// ---------------------------------------------------------------------------
const kFitnessLevels = {
  'beginner': {
    'label':    'Beginner',
    'emoji':    '🌱',
    'minSteps': 0,
    'maxSteps': 4999,
    'next':     'active',
    'nextMin':  5000,
  },
  'active': {
    'label':    'Active',
    'emoji':    '🏃',
    'minSteps': 5000,
    'maxSteps': 7999,
    'next':     'athlete',
    'nextMin':  8000,
  },
  'athlete': {
    'label':    'Athlete',
    'emoji':    '⚡',
    'minSteps': 8000,
    'maxSteps': 11999,
    'next':     'elite',
    'nextMin':  12000,
  },
  'elite': {
    'label':    'Elite',
    'emoji':    '🏆',
    'minSteps': 12000,
    'maxSteps': 99999,
    'next':     null,
    'nextMin':  null,
  },
};

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class FitnessState {
  final double? bmi;
  final String bmiCategory;
  final String fitnessLevel;
  final List<String> activityPreferences;
  final int dailyStepGoal;
  final bool isUpdating;
  final String? error;

  const FitnessState({
    this.bmi,
    this.bmiCategory   = 'Unknown',
    this.fitnessLevel  = 'beginner',
    this.activityPreferences = const [],
    this.dailyStepGoal = 10000,
    this.isUpdating    = false,
    this.error,
  });

  FitnessState copyWith({
    double? bmi,
    String? bmiCategory,
    String? fitnessLevel,
    List<String>? activityPreferences,
    int? dailyStepGoal,
    bool? isUpdating,
    String? error,
  }) {
    return FitnessState(
      bmi:                 bmi                 ?? this.bmi,
      bmiCategory:         bmiCategory         ?? this.bmiCategory,
      fitnessLevel:        fitnessLevel        ?? this.fitnessLevel,
      activityPreferences: activityPreferences ?? this.activityPreferences,
      dailyStepGoal:       dailyStepGoal       ?? this.dailyStepGoal,
      isUpdating:          isUpdating          ?? this.isUpdating,
      error:               error,
    );
  }

  /// Returns BMI needle position [0..1] clamped to the gauge arc.
  /// Gauge spans BMI 10 → 40 (full arc).
  double get bmiGaugePosition {
    if (bmi == null) return 0.0;
    return ((bmi! - 10.0) / 30.0).clamp(0.0, 1.0);
  }

  /// Fitness level progress towards next level [0..1].
  double fitnessProgress(int avgDailySteps) {
    final meta = kFitnessLevels[fitnessLevel]!;
    final nextMin = meta['nextMin'] as int?;
    if (nextMin == null) return 1.0; // elite → maxed out
    final minSteps = meta['minSteps'] as int;
    final range = nextMin - minSteps;
    final current = avgDailySteps - minSteps;
    return (current / range).clamp(0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class FitnessNotifier extends StateNotifier<FitnessState> {
  final ApiService _api;

  FitnessNotifier(this._api) : super(const FitnessState()) {
    _loadFromLocalStorage();
  }

  // ---- Load & compute from stored user data --------------------------------
  void _loadFromLocalStorage() {
    final user = StorageService.getUser();
    if (user == null) return;

    // BMI
    final heightCm = double.tryParse(user['heightCm']?.toString() ?? '');
    final weightKg = double.tryParse(user['weightKg']?.toString() ?? '');

    double? bmi;
    String bmiCategory = 'Unknown';
    if (heightCm != null && heightCm > 0 && weightKg != null && weightKg > 0) {
      final hM = heightCm / 100;
      bmi = weightKg / (hM * hM);
      bmiCategory = _bmiCategory(bmi);
    }

    // Activity prefs
    final rawPrefs = user['activityPreferences'];
    final List<String> prefs = rawPrefs is List
        ? rawPrefs.map((e) => e.toString()).toList()
        : <String>[];

    // Fitness level
    final fitnessLevel = user['fitnessLevel']?.toString() ?? 'beginner';

    // Daily step goal
    final goal = int.tryParse(user['dailyStepGoal']?.toString() ?? '') ?? 10000;

    state = FitnessState(
      bmi: bmi,
      bmiCategory: bmiCategory,
      fitnessLevel: fitnessLevel,
      activityPreferences: prefs,
      dailyStepGoal: goal,
    );
  }

  // ---- Reload (call after editing profile) --------------------------------
  void reload() => _loadFromLocalStorage();

  // ---- Toggle a single activity preference --------------------------------
  Future<void> toggleActivity(String activityId) async {
    final current = List<String>.from(state.activityPreferences);
    if (current.contains(activityId)) {
      current.remove(activityId);
    } else {
      current.add(activityId);
    }
    await updateActivityPreferences(current);
  }

  // ---- Persist activity preferences to API --------------------------------
  Future<void> updateActivityPreferences(List<String> prefs) async {
    state = state.copyWith(isUpdating: true, activityPreferences: prefs);
    try {
      await _api.put('/users/me', data: {'activityPreferences': prefs});
      // Update local cache
      final user = StorageService.getUser();
      if (user != null) {
        user['activityPreferences'] = prefs;
        await StorageService.saveUser(user);
      }
      state = state.copyWith(isUpdating: false);
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: ApiError.from(e).message);
    }
  }

  // ---- BMI category label -------------------------------------------------
  static String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final fitnessProvider =
    StateNotifierProvider<FitnessNotifier, FitnessState>((ref) {
  return FitnessNotifier(ref.watch(apiServiceProvider));
});
