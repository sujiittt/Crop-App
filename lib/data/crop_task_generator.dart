import 'crop_task_templates.dart';
import '../../presentation/widgets/farm_canvas/models.dart';

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
    required TileStage stage,
    required DateTime stageStartDate,
  }) {
    final templates = CropTaskTemplates.getTasks(
      cropName: cropName,
      stage: stage,
    );

    if (templates.isEmpty) return [];

    return templates.map((t) {
      return GeneratedTask(
        title: t.title,
        dueDate: stageStartDate.add(Duration(days: t.afterDays)),
        note: t.note,
      );
    }).toList();
  }

  static bool hasTemplatesForCrop(String cropName) {
    return [
      'wheat',
      'rice',
      'maize',
      'cotton',
      'tomato',
      'potato',
      'onion',
    ].contains(cropName.toLowerCase());
  }
}
