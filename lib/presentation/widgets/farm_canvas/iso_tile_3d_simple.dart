// lib/presentation/widgets/farm_canvas/iso_tile_3d_simple.dart
import 'package:flutter/material.dart';

/// Simple iso/3D-looking tile widget.
/// - size: width & height of the tile square
/// - cropEmoji: optional emoji or string to show when planted
/// - label: short label to show under emoji
/// - selected: highlight state (e.g., growing)
/// - onTap: tap handler
class IsoTile3DSimple extends StatelessWidget {
  final double size;
  final String? cropEmoji;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const IsoTile3DSimple({
    Key? key,
    required this.size,
    this.cropEmoji,
    this.label = 'Empty',
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  // Colors — you can replace these with AppTheme values
  Color get _soilEdge => const Color(0xFF7B5A3D); // brown
  Color get _soilTop => const Color(0xFFB07A4B); // lighter brown
  Color get _greenGlow => const Color(0xFF2E7D32).withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    final double pad = size * 0.06;
    final double topHeight = size * 0.62;
    final double edgeHeight = size * 0.18;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 3D shadow (lower)
            Positioned(
              top: topHeight + edgeHeight - 6,
              left: pad,
              right: pad,
              child: Transform.rotate(
                angle: -0.02,
                child: Container(
                  height: edgeHeight + 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            // Soil edge (slanted band) - gives 'height' feeling
            Positioned(
              top: topHeight - 6,
              left: pad / 2,
              right: pad / 2,
              child: Transform(
                transform: Matrix4.identity()..rotateX(0.15),
                alignment: Alignment.center,
                child: Container(
                  height: edgeHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _soilEdge.withOpacity(1.0),
                        _soilEdge.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Top surface
            Positioned(
              top: pad,
              left: pad,
              right: pad,
              child: Container(
                height: topHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      _soilTop.withOpacity(1.0),
                      _soilTop.withOpacity(0.94),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: selected ? 12 : 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                      color: selected ? _greenGlow.withOpacity(0.6) : Colors.transparent,
                      width: selected ? 2.0 : 0.0),
                ),
                child: _buildTopContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    // Center emoji or plus
    final bool planted = cropEmoji != null && cropEmoji!.isNotEmpty && label.toLowerCase() != 'empty';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The circular badge with emoji / icon
          Container(
            width: size * 0.38,
            height: size * 0.38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            alignment: Alignment.center,
            child: planted
                ? Text(
              cropEmoji!,
              style: TextStyle(fontSize: size * 0.28),
            )
                : Icon(
              Icons.add,
              size: size * 0.28,
              color: Colors.brown.shade700,
            ),
          ),

          const SizedBox(height: 6),
          // Label under the badge
          SizedBox(
            width: size * 0.7,
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size * 0.10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
