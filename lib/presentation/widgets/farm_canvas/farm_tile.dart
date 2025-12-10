// lib/presentation/widgets/farm_canvas/farm_tile.dart
import 'package:flutter/material.dart';

import 'models.dart';
import 'iso_tile_3d_simple.dart';

/// Visual + interaction wrapper for a single farm tile.
///
/// This is what the grid in `farm_canvas.dart` uses.
class FarmTileView extends StatelessWidget {
  final FarmTile tile;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FarmTileView({
    super.key,
    required this.tile,
    required this.size,
    required this.onTap,
    this.onLongPress,
  });

  bool get _isEmpty => tile.isEmpty;

  @override
  Widget build(BuildContext context) {
    // Short label for the crop under the emoji
    final crop = tile.crop;
    String label;
    final bool isEmpty = (crop == null);

    if (isEmpty) {
      label = 'Empty';
    } else {
      // CropKind has only `label` and `emoji` in your models now
      label = crop!.label;
    }


    // Which stage is currently active?
    final TileStage? stage = tile.stage;

    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onLongPress: onLongPress,
        child: IsoTile3DSimple(
          size: size,
          cropEmoji: crop?.emoji,
          label: label,
          isEmpty: _isEmpty,
          // grow = highlighted state
          stage: stage,
        ),
      ),
    );
  }
}
