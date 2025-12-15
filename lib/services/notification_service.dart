// lib/services/notification_service.dart
//
// TEMPORARY STUB NOTIFICATION SERVICE
// ----------------------------------
// Keeps app compiling on Android while preserving
// existing task & reminder logic.
// No platform plugins used.

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance =
  NotificationService._internal();

  /// Init (safe no-op)
  Future<void> init() async {
    return;
  }

  // ------------------------------------------------------------
  // PLANTING REMINDER (used in crop recommendation screens)
  // ------------------------------------------------------------
  Future<int> schedulePlantingReminder({
    required String cropName,
    required DateTime whenLocal,
    String? note,
  }) async {
    return ('plant_$cropName$whenLocal').hashCode;
  }

  // ------------------------------------------------------------
  // TASK NOTIFICATIONS — MATCH task_storage.dart EXACTLY
  // ------------------------------------------------------------

  /// This matches:
  /// scheduleTaskNotification(model)
  Future<int> scheduleTaskNotification(dynamic taskModel) async {
    // Expecting model.id, model.title, model.dateTime (common pattern)
    final String id =
        taskModel.id?.toString() ?? taskModel.hashCode.toString();

    return id.hashCode;
  }

  /// Matches cancelTaskNotification(taskId)
  Future<void> cancelTaskNotification(String taskId) async {
    return;
  }

  // ------------------------------------------------------------
  // GENERIC
  // ------------------------------------------------------------
  Future<void> cancelByNotificationId(int id) async {
    return;
  }

  Future<void> cancelAll() async {
    return;
  }
}
