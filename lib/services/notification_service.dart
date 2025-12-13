// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/task_model.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notifications & timezone
  Future<void> init() async {
    if (_initialized) return;

    // Init timezone
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    // Android initialization
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosInit =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Schedule notification for a task
  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (!_initialized) await init();

    final int notificationId = task.id.hashCode;

    final scheduledTime =
    tz.TZDateTime.from(task.dateTime, tz.local);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'cropwise_tasks',
      'Task reminders',
      channelDescription: 'Reminders for farm tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails =
    DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      notificationId,
      task.title,
      task.cropLabel != null
          ? 'Crop: ${task.cropLabel}'
          : 'Farm task reminder',
      scheduledTime,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  /// Cancel notification when task is deleted/completed
  Future<void> cancelTaskNotification(String taskId) async {
    if (!_initialized) await init();
    await _plugin.cancel(taskId.hashCode);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
