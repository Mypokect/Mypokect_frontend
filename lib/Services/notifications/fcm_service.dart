import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// FCM Service for push notifications
class FCMService {
  final FirebaseMessaging _firebaseMessaging;
  final Dio _dio;
  final String _apiBaseUrl;

  FCMService({
    required FirebaseMessaging firebaseMessaging,
    required Dio dio,
    required String apiBaseUrl,
  })  : _firebaseMessaging = firebaseMessaging,
        _dio = dio,
        _apiBaseUrl = apiBaseUrl;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission (iOS)
    await _requestPermission();

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await _registerToken(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _registerToken(newToken);
    });

    // Configure foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerToken(String token) async {
    try {
      // Detect platform
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

      await _dio.post(
        '$_apiBaseUrl/v1/push/register-token',
        data: {
          'token': token,
          'platform': platform,
        },
      );

      debugPrint('Token registered successfully');
    } catch (e) {
      debugPrint('Error registering token: $e');
    }
  }

  /// Unregister FCM token from backend
  Future<void> unregisterToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _dio.delete('$_apiBaseUrl/v1/push/unregister-token/$token');
        await _firebaseMessaging.deleteToken();
        debugPrint('Token unregistered successfully');
      }
    } catch (e) {
      debugPrint('Error unregistering token: $e');
    }
  }

  /// Setup message handlers
  void setupMessageHandlers({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onMessageOpenedApp,
  }) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(onMessageReceived);

    // Handle messages that opened the app from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

    // Handle initial message if app was opened from notification
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        onMessageOpenedApp(message);
      }
    });
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
