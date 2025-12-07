import 'package:flutter/foundation.dart';

/// Crop types
enum CropKind {
  wheat('🌾', 'Wheat'),
  rice('🌱', 'Rice'),
  maize('🌽', 'Maize'),
  onion('🧅', 'Onion'),
  tomato('🍅', 'Tomato'),
  potato('🥔', 'Potato');

  final String emoji;
  final String label;
  const CropKind(this.emoji, this.label);

  static CropKind? fromString(String s) {
    try {
      return CropKind.values.firstWhere((e) => describeEnum(e) == s);
    } catch (_) {
      return null;
    }
  }

  String get asString => describeEnum(this);
}

/// Per-tile growth stage
enum TileStage { sown, growing, harvest }

extension TileStageX on TileStage {
  String get label {
    switch (this) {
      case TileStage.sown:
        return 'Sown';
      case TileStage.growing:
        return 'Growing';
      case TileStage.harvest:
        return 'Harvest';
    }
  }

  String get asString => describeEnum(this);

  static TileStage? fromString(String s) {
    try {
      return TileStage.values.firstWhere((e) => describeEnum(e) == s);
    } catch (_) {
      return null;
    }
  }
}

@immutable
class FarmTile {
  final int x;
  final int y;
  final CropKind? crop;
  final TileStage? stage; // null if empty
  final int density; // 1 (single) or 2 (dense)

  const FarmTile({
    required this.x,
    required this.y,
    this.crop,
    this.stage,
    this.density = 1,
  });

  bool get isEmpty => crop == null;

  /// Plant sets stage to Sown initially
  FarmTile plant(CropKind kind, {int density = 1}) =>
      FarmTile(x: x, y: y, crop: kind, stage: TileStage.sown, density: density.clamp(1, 2));

  FarmTile clear() => FarmTile(x: x, y: y, crop: null, stage: null, density: 1);

  FarmTile withStage(TileStage newStage) =>
      FarmTile(x: x, y: y, crop: crop, stage: newStage, density: density);

  FarmTile withDensity(int newDensity) =>
      FarmTile(x: x, y: y, crop: crop, stage: stage, density: newDensity.clamp(1, 2));

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'crop': crop?.asString,
    'stage': stage?.asString,
    'density': density,
  };

  factory FarmTile.fromJson(Map<String, dynamic> json) {
    return FarmTile(
      x: json['x'] as int,
      y: json['y'] as int,
      crop: json['crop'] == null
          ? null
          : CropKind.fromString(json['crop'] as String),
      stage: json['stage'] == null
          ? null
          : TileStageX.fromString(json['stage'] as String),
      density: (json['density'] as int?) ?? 1,
    );
  }
}

@immutable
class FarmField {
  final String id;
  final String name;
  final int cols;
  final int rows;
  final List<FarmTile> tiles;

  const FarmField({
    required this.id,
    required this.name,
    required this.cols,
    required this.rows,
    required this.tiles,
  });

  factory FarmField.empty({
    required String id,
    required String name,
    required int cols,
    required int rows,
  }) {
    final tiles = <FarmTile>[];
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        tiles.add(FarmTile(x: x, y: y)); // non-const to avoid const issues
      }
    }
    return FarmField(id: id, name: name, cols: cols, rows: rows, tiles: tiles);
  }

  FarmTile? tileAt(int x, int y) {
    if (x < 0 || x >= cols || y < 0 || y >= rows) return null;
    return tiles[y * cols + x];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cols': cols,
    'rows': rows,
    'tiles': tiles.map((t) => t.toJson()).toList(),
  };

  factory FarmField.fromJson(Map<String, dynamic> json) {
    return FarmField(
      id: json['id'] as String,
      name: json['name'] as String,
      cols: json['cols'] as int,
      rows: json['rows'] as int,
      tiles: (json['tiles'] as List)
          .map((e) => FarmTile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
