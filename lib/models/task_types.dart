// lib/models/task_types.dart
import 'package:flutter/material.dart';

/// Common task types used in the app.
/// Note: TaskModel.type stores a string; use toStorageString() before saving.
enum TaskType {
  irrigation,
  fertilizer,
  pesticide,
  harvest,
  soilTest,
  marketVisit,
  priceCheck,
  custom,
}

extension TaskTypeMeta on TaskType {
  String get label {
    switch (this) {
      case TaskType.irrigation:
        return 'Irrigation';
      case TaskType.fertilizer:
        return 'Fertilizer';
      case TaskType.pesticide:
        return 'Pesticide';
      case TaskType.harvest:
        return 'Harvest';
      case TaskType.soilTest:
        return 'Soil Test';
      case TaskType.marketVisit:
        return 'Market Visit';
      case TaskType.priceCheck:
        return 'Price Check';
      case TaskType.custom:
      default:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskType.irrigation:
        return Icons.water_drop;
      case TaskType.fertilizer:
        return Icons.grass;
      case TaskType.pesticide:
        return Icons.bug_report;
      case TaskType.harvest:
        return Icons.agriculture;
      case TaskType.soilTest:
        return Icons.science;
      case TaskType.marketVisit:
        return Icons.store;
      case TaskType.priceCheck:
        return Icons.show_chart;
      case TaskType.custom:
      default:
        return Icons.event_note;
    }
  }

  /// Convert to a storable string (used in TaskModel.type)
  String toStorageString() => name;

  /// User-visible short hint (optional)
  String get hint {
    switch (this) {
      case TaskType.irrigation:
        return 'Water the field';
      case TaskType.fertilizer:
        return 'Apply fertilizer';
      case TaskType.pesticide:
        return 'Spray for pests';
      case TaskType.harvest:
        return 'Harvest crop';
      case TaskType.soilTest:
        return 'Take soil sample';
      case TaskType.marketVisit:
        return 'Visit market / buy inputs';
      case TaskType.priceCheck:
        return 'Check mandi price';
      case TaskType.custom:
      default:
        return 'Custom task';
    }
  }
}

/// Convert from storage string to TaskType.
/// If unknown, returns TaskType.custom
TaskType taskTypeFromString(String? s) {
  if (s == null) return TaskType.custom;
  try {
    return TaskType.values.firstWhere((e) => e.name == s);
  } catch (_) {
    return TaskType.custom;
  }
}

/// All primary types in a useful order for the UI
List<TaskType> primaryTaskTypes() {
  return [
    TaskType.irrigation,
    TaskType.fertilizer,
    TaskType.pesticide,
    TaskType.harvest,
    TaskType.soilTest,
    TaskType.marketVisit,
    TaskType.priceCheck,
    TaskType.custom,
  ];
}

/// Simple smart suggestions based on crop label and stage.
///
/// - cropLabel: optional (example: "Wheat", "Rice", or emoji "🌾")
/// - stage: optional simple stage string like "sown", "growing", "harvest"
///
/// Returns a short ordered list of TaskType suggestions (highest priority first).
List<TaskType> suggestTasksForCropStage(String? cropLabel, String? stage) {
  final s = (stage ?? '').toLowerCase();
  final crop = (cropLabel ?? '').toLowerCase();

  // Stage-based suggestions
  if (s.contains('sown') || s.contains('seed') || s.contains('nursery')) {
    return [
      TaskType.irrigation,
      TaskType.soilTest,
      TaskType.fertilizer,
      TaskType.custom,
    ];
  }

  if (s.contains('growing') || s.contains('vegetative') || s.contains('flower')) {
    // Growing stage - irrigation, fertilizer, pest control are typical
    return [
      TaskType.irrigation,
      TaskType.fertilizer,
      TaskType.pesticide,
      TaskType.soilTest,
      TaskType.custom,
    ];
  }

  if (s.contains('harvest') || s.contains('ripen') || s.contains('mature')) {
    return [
      TaskType.harvest,
      TaskType.marketVisit,
      TaskType.priceCheck,
      TaskType.custom,
    ];
  }

  // Crop-specific tweaks (basic examples)
  if (crop.contains('rice') || crop.contains('paddy')) {
    return [
      TaskType.irrigation,
      TaskType.fertilizer,
      TaskType.pesticide,
    ];
  }

  if (crop.contains('vegetable') || crop.contains('tomato') || crop.contains('potato')) {
    return [
      TaskType.pesticide,
      TaskType.fertilizer,
      TaskType.irrigation,
    ];
  }

  // Default suggestions
  return [
    TaskType.irrigation,
    TaskType.fertilizer,
    TaskType.pesticide,
    TaskType.harvest,
  ];
}
