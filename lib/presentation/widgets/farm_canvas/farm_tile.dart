// lib/presentation/widgets/farm_canvas/farm_tile.dart
import 'package:flutter/material.dart';

// Adjust import path if your project uses different package name
import 'package:cropwise/presentation/widgets/farm_canvas/iso_tile_3d_simple.dart';

// Import your models file that defines FarmTile, TileStage, etc.
// Adjust the path if needed in your project.
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
  // Keep a small controller to use if you still want a pulse in parent
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
    if (_isEmpty) {
      _ctrl.repeat(reverse: true);
    }
  }

  bool get _isEmpty => widget.tile.isEmpty;

  @override
  void didUpdateWidget(covariant FarmTileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isEmpty && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!_isEmpty && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _label {
    final crop = widget.tile.crop;
    try {
      final label = crop?.label;
      if (label != null && label.isNotEmpty) return label;
    } catch (_) {}
    // fallback to stringified crop or "Empty"
    return widget.tile.crop?.toString() ?? 'Empty';
  }

  String? get _emoji {
    final crop = widget.tile.crop;
    try {
      final e = crop?.emoji;
      if (e != null && e.isNotEmpty) return e;
    } catch (_) {}
    return null;
  }

  bool get _isGrowing {
    try {
      return widget.tile.stage == TileStage.growing;
    } catch (_) {
      return widget.tile.crop != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size.clamp(48.0, 360.0);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: s,
        height: s,
        child: ScaleTransition(
          scale: _pulse,
          child: IsoTile3DSimple(
            size: s,
            cropEmoji: _emoji,
            label: _label,
            selected: _isGrowing,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
