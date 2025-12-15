// lib/data/crop_task_templates.dart
//
// Static crop task knowledge base.
// Used to auto-suggest tasks for farmers based on crop & stage.

enum CropStage {
  sown,
  growing,
  harvest,
}

class CropTaskTemplate {
  final String title;
  final int afterDays; // days after stage starts
  final String? note;

  const CropTaskTemplate({
    required this.title,
    required this.afterDays,
    this.note,
  });
}

class CropTaskTemplates {
  /// Returns task templates for a given crop & stage
  static List<CropTaskTemplate> getTasks({
    required String cropName,
    required CropStage stage,
  }) {
    final crop = cropName.toLowerCase();

    switch (crop) {
      case 'wheat':
        return _wheat(stage);

      case 'rice':
        return _rice(stage);

      case 'cotton':
        return _cotton(stage);

      case 'maize':
        return _maize(stage);

      default:
        return [];
    }
  }

  // ---------------- WHEAT ----------------

  static List<CropTaskTemplate> _wheat(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(
            title: 'First irrigation',
            afterDays: 5,
            note: 'Light irrigation after germination',
          ),
          CropTaskTemplate(
            title: 'Fertilizer application',
            afterDays: 20,
            note: 'Apply urea or recommended fertilizer',
          ),
        ];

      case CropStage.growing:
        return const [
          CropTaskTemplate(
            title: 'Weeding',
            afterDays: 25,
          ),
          CropTaskTemplate(
            title: 'Second irrigation',
            afterDays: 30,
          ),
        ];

      case CropStage.harvest:
        return const [
          CropTaskTemplate(
            title: 'Harvest crop',
            afterDays: 120,
            note: 'Harvest when grains are fully mature',
          ),
        ];
    }
  }

  // ---------------- RICE ----------------

  static List<CropTaskTemplate> _rice(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(
            title: 'Maintain water level',
            afterDays: 3,
            note: 'Ensure standing water in field',
          ),
          CropTaskTemplate(
            title: 'First fertilizer dose',
            afterDays: 15,
          ),
        ];

      case CropStage.growing:
        return const [
          CropTaskTemplate(
            title: 'Pest monitoring',
            afterDays: 30,
          ),
          CropTaskTemplate(
            title: 'Second fertilizer dose',
            afterDays: 35,
          ),
        ];

      case CropStage.harvest:
        return const [
          CropTaskTemplate(
            title: 'Drain water',
            afterDays: 100,
          ),
          CropTaskTemplate(
            title: 'Harvest paddy',
            afterDays: 110,
          ),
        ];
    }
  }

  // ---------------- COTTON ----------------

  static List<CropTaskTemplate> _cotton(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(
            title: 'First irrigation',
            afterDays: 7,
          ),
          CropTaskTemplate(
            title: 'Thinning plants',
            afterDays: 15,
          ),
        ];

      case CropStage.growing:
        return const [
          CropTaskTemplate(
            title: 'Pest control spray',
            afterDays: 30,
            note: 'Watch for bollworms',
          ),
          CropTaskTemplate(
            title: 'Top dressing fertilizer',
            afterDays: 45,
          ),
        ];

      case CropStage.harvest:
        return const [
          CropTaskTemplate(
            title: 'Cotton picking',
            afterDays: 160,
          ),
        ];
    }
  }

  // ---------------- MAIZE ----------------

  static List<CropTaskTemplate> _maize(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(
            title: 'First irrigation',
            afterDays: 4,
          ),
          CropTaskTemplate(
            title: 'Fertilizer application',
            afterDays: 18,
          ),
        ];

      case CropStage.growing:
        return const [
          CropTaskTemplate(
            title: 'Weeding',
            afterDays: 25,
          ),
          CropTaskTemplate(
            title: 'Pest monitoring',
            afterDays: 35,
          ),
        ];

      case CropStage.harvest:
        return const [
          CropTaskTemplate(
            title: 'Harvest maize',
            afterDays: 90,
          ),
        ];
    }
  }
}
