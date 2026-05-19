import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../core/services/background_service.dart';

/// App Settings State
class AppSettings {
  final String themeMode; // 'light', 'dark', 'system'
  final String language; // 'en', 'hi', 'es'
  final bool pushNotificationsEnabled;
  final bool dailyRemindersEnabled;
  final bool dataSyncOverCellular;
  final bool soundEnabled;
  final bool isPublic;
  final bool showOnLeaderboard;
  final bool showMilestones;
  final bool backgroundSyncEnabled;
  final String distanceUnit; // 'km', 'mi'
  final String syncFrequency; // 'Auto (15m)', 'Manual Only', 'Every Hour'

  AppSettings({
    this.themeMode = 'system',
    this.language = 'en',
    this.pushNotificationsEnabled = true,
    this.dailyRemindersEnabled = true,
    this.dataSyncOverCellular = false,
    this.soundEnabled = true,
    this.isPublic = true,
    this.showOnLeaderboard = true,
    this.showMilestones = true,
    this.backgroundSyncEnabled = false,
    this.distanceUnit = 'km',
    this.syncFrequency = 'Auto (15m)',
  });

  AppSettings copyWith({
    String? themeMode,
    String? language,
    bool? pushNotificationsEnabled,
    bool? dailyRemindersEnabled,
    bool? dataSyncOverCellular,
    bool? soundEnabled,
    bool? isPublic,
    bool? showOnLeaderboard,
    bool? showMilestones,
    bool? backgroundSyncEnabled,
    String? distanceUnit,
    String? syncFrequency,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      dataSyncOverCellular: dataSyncOverCellular ?? this.dataSyncOverCellular,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      isPublic: isPublic ?? this.isPublic,
      showOnLeaderboard: showOnLeaderboard ?? this.showOnLeaderboard,
      showMilestones: showMilestones ?? this.showMilestones,
      backgroundSyncEnabled: backgroundSyncEnabled ?? this.backgroundSyncEnabled,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      syncFrequency: syncFrequency ?? this.syncFrequency,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final ApiService _apiService;

  SettingsNotifier(this._apiService) : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final response = await _apiService.get('/users/me/settings');
      final data = response.data;
      
      state = AppSettings(
        themeMode: data['themeMode'] ?? 'system',
        language: data['language'] ?? 'en',
        pushNotificationsEnabled: data['pushNotifications'] ?? true,
        dailyRemindersEnabled: data['dailyReminders'] ?? true,
        dataSyncOverCellular: data['dataSyncOverCellular'] ?? false,
        soundEnabled: data['soundEnabled'] ?? true,
        isPublic: data['isPublic'] ?? true,
        showOnLeaderboard: data['showOnLeaderboard'] ?? true,
        showMilestones: data['showMilestones'] ?? true,
        backgroundSyncEnabled: StorageService.get('backgroundSyncEnabled', defaultValue: false) ?? false,
        distanceUnit: data['distanceUnit'] ?? 'km',
        syncFrequency: StorageService.get('syncFrequency', defaultValue: 'Auto (15m)') ?? 'Auto (15m)',
      );
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _apiService.put('/users/me/settings', data: {
        'themeMode': state.themeMode,
        'language': state.language,
        'pushNotifications': state.pushNotificationsEnabled,
        'dailyReminders': state.dailyRemindersEnabled,
        'dataSyncOverCellular': state.dataSyncOverCellular,
        'soundEnabled': state.soundEnabled,
        'isPublic': state.isPublic,
        'showOnLeaderboard': state.showOnLeaderboard,
        'showMilestones': state.showMilestones,
        'distanceUnit': state.distanceUnit,
      });
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  void setThemeMode(String mode) {
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    _saveSettings();
  }

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotificationsEnabled: value);
    _saveSettings();
  }

  void toggleDailyReminders(bool value) {
    state = state.copyWith(dailyRemindersEnabled: value);
    _saveSettings();
  }
  
  void togglePublicProfile(bool value) {
    state = state.copyWith(isPublic: value);
    _saveSettings();
  }
  
  void toggleShowOnLeaderboard(bool value) {
    state = state.copyWith(showOnLeaderboard: value);
    _saveSettings();
  }
  
  void toggleShowMilestones(bool value) {
    state = state.copyWith(showMilestones: value);
    _saveSettings();
  }
  void toggleDataSyncOverCellular(bool value) {
    state = state.copyWith(dataSyncOverCellular: value);
    _saveSettings();
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
    _saveSettings();
  }

  Future<void> toggleBackgroundSync(bool value) async {
    state = state.copyWith(backgroundSyncEnabled: value);
    await StorageService.put('backgroundSyncEnabled', value);
    
    if (value) {
      await BackgroundService.registerPeriodicTask();
    } else {
      await BackgroundService.cancelTask();
    }
  }

  void setDistanceUnit(String unit) {
    state = state.copyWith(distanceUnit: unit);
    _saveSettings();
  }

  Future<void> setSyncFrequency(String frequency) async {
    state = state.copyWith(syncFrequency: frequency);
    await StorageService.put('syncFrequency', frequency);
    
    // Re-register periodic background tasks with updated interval if enabled
    if (state.backgroundSyncEnabled) {
      await BackgroundService.cancelTask();
      await BackgroundService.registerPeriodicTask();
    }
  }

  void resetToDefaults() {
    state = AppSettings();
    _saveSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(apiServiceProvider));
});
