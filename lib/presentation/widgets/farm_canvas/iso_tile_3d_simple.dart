// lib/presentation/widgets/farm_canvas/iso_tile_3d_simple.dart
import 'package:flutter/material.dart';
import 'models.dart';

class IsoTile3DSimple extends StatelessWidget {
  final double size;
  final String? cropEmoji;
  final String label;
  final bool isEmpty;
  final TileStage? stage;

  const IsoTile3DSimple({
    super.key,
    required this.size,
    required this.cropEmoji,
    required this.label,
    required this.isEmpty,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color soilTop = const Color(0xFF9C6A3A);
    final Color soilSide = const Color(0xFF6A4220);
    final Color topLight = theme.colorScheme.primary.withOpacity(0.90);
    final Color topDark = theme.colorScheme.primary.withOpacity(0.75);

    // Stage ring color
    Color? ringColor;
    switch (stage) {
      case TileStage.sown:
        ringColor = Colors.brown.withOpacity(0.4);
        break;
      case TileStage.growing:
        ringColor = Colors.green.withOpacity(0.6);
        break;
      case TileStage.harvest:
        ringColor = Colors.orange.withOpacity(0.6);
        break;
      default:
        ringColor = null;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soil block (bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size * 0.78,
              height: size * 0.32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.20),
                color: soilSide,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Top grass/plot
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size * 0.82,
              height: size * 0.55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [topLight, topDark],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1,
                ),
              ),
            ),
          ),

          // Small soil strip on top to give 3D layer
          Align(
            alignment: Alignment(0, 0.30),
            child: Container(
              width: size * 0.75,
              height: size * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.18),
                color: soilTop,
              ),
            ),
          ),

          // Crop / plus icon on top (with stage ring)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: size * 0.06),
              child: Container(
                width: size * 0.46,
                height: size * 0.46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.92),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: cropEmoji == null
                      ? Icon(
                    Icons.add,
                    size: size * 0.28,
                    color: theme.colorScheme.primary,
                  )
                      : Text(
                    cropEmoji!,
                    style: TextStyle(
                      fontSize: size * 0.30,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stage ring around crop (if any)
          if (ringColor != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: size * 0.04),
                child: Container(
                  width: size * 0.56,
                  height: size * 0.56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

          // Label at bottom (very small, no overflow)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: size * 0.05),
              child: SizedBox(
                width: size * 0.80,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isEmpty ? 'Tap to plant' : label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      fontSize: size * 0.20,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
