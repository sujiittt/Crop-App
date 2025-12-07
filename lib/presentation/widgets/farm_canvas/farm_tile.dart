// lib/presentation/widgets/farm_canvas/farm_tile.dart
import 'package:flutter/material.dart';
import 'models.dart';

typedef TileCallback = void Function(FarmTile tile);

class FarmTileView extends StatefulWidget {
  final FarmTile tile;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FarmTileView({
    super.key,
    required this.tile,
    required this.size,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<FarmTileView> createState() => _FarmTileViewState();
}

class _FarmTileViewState extends State<FarmTileView> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.tile.isEmpty) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant FarmTileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isEmpty && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.tile.isEmpty && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;
    final s = widget.size;
    final borderRadius = BorderRadius.circular(6);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: s,
        height: s,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _backgroundColor(context, tile),
            borderRadius: borderRadius,
            border: Border.all(
              color: _borderColor(context, tile),
              width: tile.isEmpty ? 1.0 : 1.2,
            ),
            boxShadow: tile.isEmpty
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Stack(
            children: [
              // If planted: show small crop icon / emoji + label
              if (!tile.isEmpty) _plantedContent(tile, s),

              // If empty: ghost '+' with subtle animation
              if (tile.isEmpty) _emptyGhost(s),
            ],
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context, FarmTile tile) {
    final surface = Theme.of(context).colorScheme.surface;
    if (tile.isEmpty) return surface;
    // planted: lightly tinted based on stage
    switch (tile.stage) {
      case TileStage.sown:
        return surface.withOpacity(0.98);
      case TileStage.growing:
        return Colors.green.withOpacity(0.04);
      case TileStage.harvest:
        return Colors.orange.withOpacity(0.04);
      default:
        return surface;
    }
  }

  Color _borderColor(BuildContext context, FarmTile tile) {
    if (tile.isEmpty) {
      return Theme.of(context).dividerColor.withOpacity(0.8);
    }
    // planted border strength depends on density
    final density = tile.density ?? 1;
    return density >= 3 ? Colors.green.shade600 : Theme.of(context).dividerColor;
  }

  Widget _plantedContent(FarmTile tile, double s) {
    // Keep this consistent with your previous planted visuals;
    // use emoji label if available, fallback to simple icon.
    final crop = tile.crop;
    final emojiOrIcon = crop?.emoji ?? '🌱';

// Some models might not have shortLabel, so safely use label or name
    final label = (crop?.label ?? crop?.toString() ?? '').toString();


    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji / icon circle
          Container(
            width: s * 0.46,
            height: s * 0.46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (tile.stage == TileStage.growing)
                  ? Colors.white
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              emojiOrIcon,
              style: TextStyle(fontSize: s * 0.28),
            ),
          ),
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: s * 0.12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyGhost(double s) {
    // A translucent "+" with soft border and subtle pulse.
    return Center(
      child: ScaleTransition(
        scale: _pulse,
        child: Container(
          width: s * 0.5,
          height: s * 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.brown.shade100.withOpacity(0.35),
                Colors.brown.shade200.withOpacity(0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.brown.shade200.withOpacity(0.6),
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: s * 0.28,
            color: Colors.brown.shade700.withOpacity(0.95),
          ),
        ),
      ),
    );
  }
}
