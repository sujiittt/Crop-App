// lib/presentation/widgets/farm_canvas/iso_tile_3d_simple.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Simple 3D-ish tile used for the farm grid.
///
/// - Shows a green land top with soft gradient
/// - Brown soil block below for depth
/// - Center circle with crop emoji or "+" for empty tiles
/// - Label underneath (short crop name or "Empty")
/// - Smooth highlight when selected
class IsoTile3DSimple extends StatelessWidget {
  final double size;
  final String? cropEmoji;
  final String label;
  final bool isEmpty;

  /// Optional: highlight state (e.g. current growth stage / selected tile)
  final bool selected;

  /// Optional: emphasise growing tiles (slightly stronger glow)
  final bool grow;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const IsoTile3DSimple({
    Key? key,
    required this.size,
    required this.label,
    required this.isEmpty,
    this.cropEmoji,
    this.selected = false,
    this.grow = false,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main green & soil colours
    final Color primary = AppTheme.lightTheme.primaryColor;
    const Color soilTop = Color(0xFFD9B892); // light brown
    const Color soilSide = Color(0xFFB1784D); // darker brown

    // Shadow / glow strength
    final double shadowBlur = selected || grow ? 14 : 8;
    final double shadowOpacity = selected || grow ? 0.30 : 0.18;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Soft drop shadow under the whole tile
            Positioned(
              bottom: size * 0.06,
              child: Container(
                width: size * 0.78,
                height: size * 0.20,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(size * 0.30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: shadowBlur,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // Brown soil "block" (gives the 3D land feeling)
            Positioned(
              bottom: size * 0.12,
              child: Container(
                width: size * 0.78,
                height: size * 0.20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.26),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      soilTop,
                      soilSide,
                    ],
                  ),
                ),
              ),
            ),

            // The main green top — uses AnimatedContainer for smooth highlight
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: size * 0.80,
              height: size * 0.30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withOpacity(isEmpty ? 0.20 : 0.95),
                    primary.withOpacity(isEmpty ? 0.12 : 0.80),
                  ],
                ),
                border: Border.all(
                  color: selected || grow
                      ? primary
                      : Colors.white.withOpacity(0.85),
                  width: selected || grow ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(shadowOpacity),
                    blurRadius: shadowBlur,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Crop icon / plus button
                  Container(
                    width: size * 0.32,
                    height: size * 0.32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cropEmoji ?? '＋',
                        style: TextStyle(
                          fontSize: size * 0.20,
                          fontWeight: FontWeight.w600,
                          color: isEmpty ? primary : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size * 0.04),
                  // Label under emoji (short crop name or "Empty")
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size * 0.11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
