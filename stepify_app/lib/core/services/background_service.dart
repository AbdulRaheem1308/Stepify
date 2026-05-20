import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../services/health_service.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

const String kBackgroundSyncTask = "stepify.backgroundSync";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background Task Started: $task");
    
    try {
      if (task == kBackgroundSyncTask) {
        final prefs = await SharedPreferences.getInstance();
        final nowStr = DateTime.now().toIso8601String();
        await prefs.setString('bg_sync_last_run', nowStr);
        await prefs.setString('bg_sync_status', 'Running...');

        // 1. Get Token (Secure Storage works without init)
        final token = await StorageService.getAccessToken();
        
        if (token == null) {
          debugPrint("No token found in background task. Skipping sync.");
          await prefs.setString('bg_sync_status', 'Skipped: No access token found');
          return Future.value(true);
        }

        // 2. Initialize Services
        final apiService = ApiService(); 

        
        final healthService = HealthService();

        // 3. Fetch Steps
        // We need permissions to be already granted.
        final steps = await healthService.getTodaySteps();
        
        if (steps > 0) {
           debugPrint("Background Sync: Syncing $steps steps");
           // 4. Send to Backend
           try {
             await apiService.post('/steps/sync', data: {
               'stepCount': steps,
               'date': DateTime.now().toIso8601String(),
               'source': 'BACKGROUND_WEARABLE'
             });
             debugPrint("Background Sync: Success");
             await prefs.setString('bg_sync_status', 'Success: Synced $steps steps');
           } catch (e) {
             debugPrint("Background Sync API Error: $e");
             await prefs.setString('bg_sync_status', 'API Error: $e');
           }
        } else {
           debugPrint("Background Sync: 0 steps today, skipping API call");
           await prefs.setString('bg_sync_status', 'Skipped: Today\'s steps is 0');
        }
      }
    } catch (e) {
      debugPrint("Background Task Error: $e");
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bg_sync_status', 'Fatal Error: $e');
      } catch (_) {}
      return Future.value(false); // Task failed
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode, // Logs to console
    );
    _initialized = true;
    debugPrint("Background Service Initialized");
  }

  static Future<void> registerPeriodicTask() async {
    await init();
    await Workmanager().registerPeriodicTask(
      "stepify_sync_job",
      kBackgroundSyncTask,
      frequency: const Duration(minutes: 15), // Android minimum
      constraints: Constraints(
        networkType: NetworkType.connected, 
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint("Background Task Registered");
  }

  static Future<void> cancelTask() async {
    await init();
    await Workmanager().cancelAll();
    debugPrint("Background Tasks Cancelled");
  }
}
