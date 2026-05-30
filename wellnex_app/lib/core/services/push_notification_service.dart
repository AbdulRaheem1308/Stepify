import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import '../../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level background handler (must be a top-level function, not a method)
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the OS isolate – no need to re-init here.
  debugPrint('[FCM BG] Message received: ${message.messageId}');
}

// ─────────────────────────────────────────────────────────────────────────────
// Local notifications plugin (singleton)
// ─────────────────────────────────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Android notification channel used for all Wellnex push notifications.
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'wellnex_default',          // must match backend channelId
  'Wellnex Notifications',
  description: 'Step rewards, challenges, badges and daily reminders.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────
class PushNotificationService {
  PushNotificationService(this._apiService);

  final ApiService _apiService;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ── Initialise everything ────────────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 2. Init flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // we request separately below
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: onLocalNotificationTap,
    );

    // 3. Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Request OS permission (Android 13+ / iOS)
    await _requestPermission();

    // 5. Fetch token and register with backend (silently – no throw)
    await _fetchAndRegisterToken();

    // 6. Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _registerTokenWithBackend(newToken);
    });

    // 7. Handle foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    // 8. Handle notification taps when the app is in the background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationOpen);

    // 9. Handle notification that launched the app from terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationOpen(initialMessage);
    }

    debugPrint('[FCM] PushNotificationService initialized');
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<void> _fetchAndRegisterToken() async {
    try {
      // Only attempt if user is logged in (has a stored access token)
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) return;

      final token = await _fcm.getToken();
      if (token == null) return;

      await _registerTokenWithBackend(token);
    } catch (e) {
      debugPrint('[FCM] Token fetch/register failed (non-fatal): $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) return;

      await _apiService.post(
        '/notifications/fcm-token',
        data: {'token': token},
      );
      debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      debugPrint('[FCM] Backend token registration failed (non-fatal): $e');
    }
  }

  // ── Foreground Messages ───────────────────────────────────────────────────

  void handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    debugPrint('[FCM FG] ${notification.title}: ${notification.body}');

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  void handleNotificationOpen(RemoteMessage message) {
    debugPrint('[FCM] Notification opened: ${message.data}');
    // TODO: deep-link into the relevant screen based on message.data['type']
  }

  void onLocalNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Local notification tapped: ${response.payload}');
    // TODO: deep-link handling
  }

  // ── Public: Register token after login ───────────────────────────────────

  /// Call this right after a successful login so the fresh token is sent.
  Future<void> registerTokenAfterLogin() async {
    await _fetchAndRegisterToken();
  }

  /// Call this on logout to clear the stored token from the backend.
  Future<void> clearTokenOnLogout() async {
    try {
      await _apiService.post('/notifications/fcm-token', data: {'token': ''});
      await _fcm.deleteToken();
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────────────────────────────────────
final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(apiServiceProvider));
});
