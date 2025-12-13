// lib/core/services/notifications_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationsService {
  NotificationsService._internal();
  static final NotificationsService instance =
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
    DarwinInitializationSettings();

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  // ------------------------------------------------------------
  // INTERNAL SCHEDULER
  // ------------------------------------------------------------
  Future<int> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    if (!_initialized) await init();

    final tzTime = tz.TZDateTime.from(time, tz.local);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'cropwise_tasks',
      'Task reminders',
      channelDescription: 'Reminders for farm tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    return id;
  }

  // ------------------------------------------------------------
  // ✅ EXACT API EXPECTED BY YOUR UI
  // ------------------------------------------------------------

  /// Used by:
  /// - set_planting_reminder_button.dart
  /// - crop_recommendations_widget.dart
  ///
  /// MUST return int notificationId
  Future<int> schedulePlantingReminder({
    required String cropName,
    required DateTime whenLocal,
    String? note,
  }) async {
    final int notificationId =
        ('plant_$cropName$whenLocal').hashCode;

    final String body = note?.isNotEmpty == true
        ? note!
        : 'Time to plant $cropName';

    return _schedule(
      id: notificationId,
      title: 'Planting Reminder',
      body: body,
      time: whenLocal,
    );
  }

  // ------------------------------------------------------------
  // CANCEL
  // ------------------------------------------------------------
  Future<void> cancelByNotificationId(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
