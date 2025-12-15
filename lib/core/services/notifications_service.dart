// lib/core/services/notifications_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotificationsService {
  NotificationsService._internal();
  static final NotificationsService instance =
  NotificationsService._internal();

  Future<void> init() async {
    // Do nothing on Android for now
    if (kIsWeb) return;
    if (Platform.isAndroid) return;
  }

  /// Used by crop recommendation screens
  Future<int> schedulePlantingReminder({
    required String cropName,
    required DateTime whenLocal,
    String? note,
  }) async {
    // Stubbed for Android
    return ('plant_$cropName$whenLocal').hashCode;
  }

  Future<void> cancelByNotificationId(int id) async {
    // no-op
  }

  Future<void> cancelAll() async {
    // no-op
  }
}
