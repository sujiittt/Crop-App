// lib/data/crop_task_templates.dart
//
// Static crop task knowledge base.
// Used to auto-suggest tasks for farmers based on crop & stage.

// ADD THIS at top
import '../../presentation/widgets/farm_canvas/models.dart';

enum CropStage {
  sown,
  growing,
  harvest,
}

/// 🔁 Converter (SINGLE SOURCE OF TRUTH)
CropStage cropStageFromTileStage(TileStage stage) {
  switch (stage) {
    case TileStage.sown:
      return CropStage.sown;
    case TileStage.growing:
      return CropStage.growing;
    case TileStage.harvest:
      return CropStage.harvest;
  }
}
// uses TileStage instead

// List of crops that have task templates
const Set<String> supportedCrops = {
  'wheat',
  'rice',
  'cotton',
  'maize',
  'tomato',
  'potato',
  'onion',
};


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
  static bool hasTemplatesForCrop(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
      case 'rice':
      case 'maize':
      case 'onion':
      case 'tomato':
      case 'potato':
      case 'cotton':
        return true;
      default:
        return false;
    }
  }

  /// Returns task templates for a given crop & stage
  static List<CropTaskTemplate> getTasks({
    required String cropName,
    required TileStage stage,
  }) {
    final crop = cropName.toLowerCase();
    final cropStage = cropStageFromTileStage(stage);

    switch (crop) {
      case 'wheat':
        return _wheat(cropStage);
      case 'rice':
        return _rice(cropStage);
      case 'maize':
        return _maize(cropStage);
      case 'tomato':
        return _tomato(cropStage);
      case 'potato':
        return _potato(cropStage);
      case 'onion':
        return _onion(cropStage);
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

  // ---------------- TOMATO ----------------
  static List<CropTaskTemplate> _tomato(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(title: 'Initial watering', afterDays: 3),
          CropTaskTemplate(title: 'Apply compost', afterDays: 10),
        ];
      case CropStage.growing:
        return const [
          CropTaskTemplate(title: 'Support staking', afterDays: 20),
          CropTaskTemplate(title: 'Pest check', afterDays: 30),
        ];
      case CropStage.harvest:
        return const [
          CropTaskTemplate(title: 'Harvest tomatoes', afterDays: 70),
        ];
    }
  }

  static List<CropTaskTemplate> _potato(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(title: 'First irrigation', afterDays: 5),
        ];
      case CropStage.growing:
        return const [
          CropTaskTemplate(title: 'Earthing up', afterDays: 25),
        ];
      case CropStage.harvest:
        return const [
          CropTaskTemplate(title: 'Harvest potatoes', afterDays: 90),
        ];
    }
  }

  static List<CropTaskTemplate> _onion(CropStage stage) {
    switch (stage) {
      case CropStage.sown:
        return const [
          CropTaskTemplate(title: 'Light irrigation', afterDays: 4),
        ];
      case CropStage.growing:
        return const [
          CropTaskTemplate(title: 'Weeding', afterDays: 30),
        ];
      case CropStage.harvest:
        return const [
          CropTaskTemplate(title: 'Harvest onions', afterDays: 110),
        ];
    }
  }

}