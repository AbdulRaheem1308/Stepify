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
        // 1. Get Token (Secure Storage works without init)
        final token = await StorageService.getAccessToken();
        
        if (token == null) {
          debugPrint("No token found in background task. Skipping sync.");
          return Future.value(true);
        }

        // 2. Initialize Services
        // ApiService usually reads token from storage, but in background we might need to be explicit
        // if ApiService's internal check relies on other state. 
        // However, looking at standard implementation, it likely calls StorageService.getAccessToken().
        final apiService = ApiService(); 

        
        final healthService = HealthService();

        // 3. Fetch Steps
        // We need permissions to be already granted.
        final steps = await healthService.getTodaySteps();
        
        if (steps > 0) {
           debugPrint("Background Sync: Syncing $steps steps");
           // 4. Send to Backend
           try {
             // Re-using the sync logic. 
             // Ideally we call a repository, but direct API call is safer in isolated background task to avoid complex DI.
             await apiService.post('/steps/sync', data: {
               'stepCount': steps,
               'date': DateTime.now().toIso8601String(),
               'source': 'BACKGROUND_WEARABLE'
             });
             debugPrint("Background Sync: Success");
           } catch (e) {
             debugPrint("Background Sync API Error: $e");
             // Don't fail the task, it will retry safely or just run next time
           }
        }
      }
    } catch (e) {
      debugPrint("Background Task Error: $e");
      return Future.value(false); // Task failed
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode, // Logs to console
    );
    debugPrint("Background Service Initialized");
  }

  static Future<void> registerPeriodicTask() async {
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
    await Workmanager().cancelAll();
    debugPrint("Background Tasks Cancelled");
  }
}
