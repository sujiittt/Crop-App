// lib/presentation/widgets/farm_canvas/iso_tile_3d_simple.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Simple lightweight 3D-ish tile used in farm canvas.
/// Safe for emulator and mobile — uses Transform + gradients + shadows.
class IsoTile3DSimple extends StatefulWidget {
  /// size in pixels for the top face (square)
  final double size;

  /// crop emoji or icon to show when planted (nullable)
  final String? cropEmoji;

  /// label beneath the tile
  final String? label;

  /// tap callback
  final VoidCallback? onTap;

  /// whether tile is currently selected (affects highlight)
  final bool selected;

  const IsoTile3DSimple({
    Key? key,
    this.size = 110,
    this.cropEmoji,
    this.label,
    this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  State<IsoTile3DSimple> createState() => _IsoTile3DSimpleState();
}

class _IsoTile3DSimpleState extends State<IsoTile3DSimple>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final topSize = widget.size;
    final depth = topSize * 0.22; // height of the side face

    // colors: fade green top, brown accent for soil side
    final primaryTop = const Color(0xFF2E7D32).withOpacity(0.95); // deep green
    final fadedTop = const Color(0xFF66BB6A).withOpacity(0.95); // lighter green
    final soilEdge = const Color(0xFF8D6E63); // faded brown
    final highlight = Colors.white.withOpacity(0.9);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapCancel: () => _ctrl.reverse(),
      onTapUp: _onTapUp,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final t = _anim.value;
          // small 3D tilt on press/hover
          final tiltX = lerpDouble(0.06, -0.02, t)!; // radians
          final tiltY = lerpDouble(-0.02, 0.02, t)!;
          final scale = lerpDouble(1.0, 1.04, t)!;

          // highlight when selected
          final borderColor = widget.selected ? primaryTop : Colors.transparent;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0.0, lerpDouble(0, -6, t)!)
              ..scale(scale, scale)
              ..rotateX(tiltX)
              ..rotateY(tiltY),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D stack: top face, side face beneath it to create depth
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // side face (translated down = visible below top)
                    Positioned(
                      top: topSize * 0.35,
                      child: Container(
                        width: topSize,
                        height: depth,
                        decoration: BoxDecoration(
                          color: soilEdge,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // top face
                    Container(
                      width: topSize,
                      height: topSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [fadedTop, primaryTop],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                          // small inner highlight
                          BoxShadow(
                            color: highlight.withOpacity(0.06),
                            blurRadius: 0,
                            spreadRadius: 0.5,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: _buildTopContent(topSize),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // label (short)
                SizedBox(
                  width: topSize + 6,
                  child: Text(
                    widget.label ?? '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopContent(double size) {
    // if no crop set -> show ghost plus
    final planted = (widget.cropEmoji ?? '').trim().isNotEmpty;
    final icon = planted ? widget.cropEmoji! : '+';
    final isPlus = !planted;

    return Center(
      child: FractionallySizedBox(
        widthFactor: isPlus ? 0.35 : 0.55,
        heightFactor: isPlus ? 0.35 : 0.55,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isPlus ? Colors.white.withOpacity(0.95) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isPlus ? 0.08 : 0.12),
                blurRadius: isPlus ? 6 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: isPlus ? 22 : 28,
                color: isPlus ? Colors.grey[700] : Colors.green[900],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// tiny helper (same as dart:ui lerpDouble)
double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  a = a ?? 0.0;
  b = b ?? 0.0;
  return a * (1.0 - t) + b * t;
}
