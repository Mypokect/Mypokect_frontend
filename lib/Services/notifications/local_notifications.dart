import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

/// Local notifications service
class LocalNotificationsService {
  static final LocalNotificationsService _instance = LocalNotificationsService._internal();
  factory LocalNotificationsService() => _instance;
  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize({
    required Function(int, String?, String?, String?) onNotificationTapped,
  }) async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        onNotificationTapped(
          details.id ?? 0,
          details.payload,
          null,
          null,
        );
      },
    );

    _initialized = true;
    debugPrint('Local notifications initialized');
  }

  /// Request permissions (primarily for iOS)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true; // Android doesn't require runtime permission
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios de Pago',
      channelDescription: 'Notificaciones de recordatorios de pago',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule a notification for a specific date/time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios de Pago',
      channelDescription: 'Notificaciones de recordatorios de pago',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Scheduled notification $id for $scheduledDate');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Cancelled notification $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Schedule reminder notifications (both "before" and "today")
  Future<void> scheduleReminderNotifications({
    required int reminderId,
    required String title,
    required double? amount,
    required DateTime dueDate,
    required int notifyOffsetMinutes,
  }) async {
    // Cancel existing notifications for this reminder
    await cancelNotification(reminderId * 10); // "before" notification
    await cancelNotification(reminderId * 10 + 1); // "today" notification

    final now = DateTime.now();
    
    // Schedule "before" notification
    final beforeDate = dueDate.subtract(Duration(minutes: notifyOffsetMinutes));
    if (beforeDate.isAfter(now)) {
      final amountText = amount != null ? ' - \$${amount.toStringAsFixed(0)}' : '';
      await scheduleNotification(
        id: reminderId * 10,
        title: '🔔 Recordatorio de pago',
        body: '$title vence pronto$amountText',
        scheduledDate: beforeDate,
        payload: 'reminder:$reminderId',
      );
    }

    // Schedule "today" notification (at the due date)
    if (dueDate.isAfter(now)) {
      final amountText = amount != null ? ' - \$${amount.toStringAsFixed(0)}' : '';
      await scheduleNotification(
        id: reminderId * 10 + 1,
        title: '⚠️ Pago vence hoy',
        body: 'Hoy vence: $title$amountText',
        scheduledDate: dueDate,
        payload: 'reminder:$reminderId',
      );
    }
  }

  /// Cancel reminder notifications
  Future<void> cancelReminderNotifications(int reminderId) async {
    await cancelNotification(reminderId * 10);
    await cancelNotification(reminderId * 10 + 1);
  }
}
