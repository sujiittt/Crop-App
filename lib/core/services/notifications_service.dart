// lib/core/services/notifications_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _flnp =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'cropwise_reminders';
  static const String _channelName = 'CropWise Reminders';
  static const String _channelDesc = 'Planting and task reminders for CropWise';

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      // No-op on web
      _initialized = true;
      return;
    }

    // Timezone init
    try {
      tzdata.initializeTimeZones();
      final kolkata = tz.getLocation('Asia/Kolkata');
      tz.setLocalLocation(kolkata);
    } catch (_) {
      // Fallback to local if tz fails for some reason
      tzdata.initializeTimeZones();
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flnp.initialize(
      initSettings,
      // If you want tap handling, add onDidReceiveNotificationResponse here.
    );

    // Create Android channel explicitly (iOS uses categories automatically)
    if (Platform.isAndroid) {
      final androidPlugin = _flnp
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ));
    }

    _initialized = true;
  }

  /// Schedule a one-time planting reminder at [whenLocal] (local time).
  /// Returns the notification id used (also stored alongside the reminder).
  Future<int> schedulePlantingReminder({
    required String cropName,
    required DateTime whenLocal,
    String? note,
  }) async {
    await init();
    if (kIsWeb) return -1; // no-op on web

    // Use epoch seconds hash for a simple, unique-ish id
    final id = whenLocal.millisecondsSinceEpoch.remainder(1 << 31);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        priority: Priority.high,
        importance: Importance.high,
        category: AndroidNotificationCategory.reminder,
        styleInformation: const DefaultStyleInformation(true, true),
      ),
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    final tzTime = tz.TZDateTime.from(whenLocal, tz.local);

    await _flnp.zonedSchedule(
      id,
      'Planting reminder: $cropName',
      (note?.isNotEmpty ?? false) ? note : 'Time to act for $cropName 🌱',
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: cropName,
    );

    return id;
  }

  Future<void> cancelReminder(int id) async {
    await init();
    if (kIsWeb) return;
    await _flnp.cancel(id);
  }

  Future<List<int>> pendingNotificationIds() async {
    await init();
    if (kIsWeb) return const [];
    final pending = await _flnp.pendingNotificationRequests();
    return pending.map((e) => e.id).toList();
  }
}
