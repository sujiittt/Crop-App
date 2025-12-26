// lib/data/crop_task_generator.dart
//
// Converts crop task templates into real task drafts
// using crop stage start date.

import 'crop_task_templates.dart';

class GeneratedTask {
  final String title;
  final DateTime dueDate;
  final String? note;

  GeneratedTask({
    required this.title,
    required this.dueDate,
    this.note,
  });
}

class CropTaskGenerator {
  static List<GeneratedTask> generateTasks({
    required String cropName,
    required CropStage stage,
    required DateTime stageStartDate,
  }) {
    final templates = CropTaskTemplates.getTasks(
      cropName: cropName,
      stage: stage,
    );

    return templates.map((template) {
      return GeneratedTask(
        title: template.title,
        dueDate: stageStartDate.add(Duration(days: template.afterDays)),
        note: template.note,
      );
    }).toList();
  }
  static bool hasTemplatesForCrop({
    required String cropName,
    required CropStage stage,
  }) {
    return CropTaskTemplates.getTasks(
      cropName: cropName,
      stage: stage,
    ).isNotEmpty;
  }
}
