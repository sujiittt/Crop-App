// lib/presentation/widgets/farm_canvas/farm_tile.dart
import 'package:flutter/material.dart';
import 'models.dart';
import 'iso_tile_3d_simple.dart';

/// Visual + interaction wrapper for a single farm tile.
///
/// This is what the grid in `farm_canvas.dart` uses.
///
/// Added: optional `onAddTask` callback. If provided, a small '+' button will
/// appear at the top-right of the tile to quick-create a task for this tile.
class FarmTileView extends StatelessWidget {
  final FarmTile tile;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAddTask;

  const FarmTileView({
    super.key,
    required this.tile,
    required this.size,
    required this.onTap,
    this.onLongPress,
    this.onAddTask,
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
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Main tile area (keeps existing behavior)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            onLongPress: onLongPress,
            child: IsoTile3DSimple(
              size: size,
              cropEmoji: isEmpty ? null : crop.emoji,
              label: label,
              isEmpty: isEmpty,
            ),
          ),

          // Top-right small add-task button (only if callback provided)
          if (onAddTask != null)
            Positioned(
              right: 2,
              top: 2,
              child: SizedBox(
                width: size * 0.22,
                height: size * 0.22,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onAddTask,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
