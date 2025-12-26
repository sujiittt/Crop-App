// lib/presentation/widgets/farm_canvas/iso_tile_3d_simple.dart
import 'package:flutter/material.dart';

/// Polished 3D farm tile with:
/// - Better soil depth
/// - Softer natural shadows
/// - Cleaner color grading
/// - Tighter layout (no overflow)
class IsoTile3DSimple extends StatelessWidget {
  final double size;
  final String? cropEmoji;
  final String label;
  final bool isEmpty;
  final bool selected;
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
    // Colors
    const soilLight = Color(0xFFE1C6A5);
    const soilDark = Color(0xFF9B6A42);
    const soilShadow = Color(0xFF6B4A30);

    const landBright = Color(0xFF6BBF59);
    const landDark = Color(0xFF4FA143);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Shadow (very soft)
              Positioned(
                bottom: size * 0.05,
                child: Container(
                  width: size * 0.70,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(size * 0.3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                ),
              ),

              // Soil block
              Positioned(
                bottom: size * 0.08,
                child: Container(
                  width: size * 0.70,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.18),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [soilLight, soilDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: soilShadow.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ),

              // Land surface
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: size * 0.78,
                height: size * 0.30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isEmpty
                        ? [
                      Colors.green.shade200,
                      Colors.green.shade300,
                    ]
                        : [landBright, landDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                          selected ? 0.25 : (grow ? 0.18 : 0.10)),
                      blurRadius: selected ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: selected ? Colors.white : Colors.white70,
                    width: selected ? 2 : 1.2,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max, // 🔴 IMPORTANT
                      children: [
                        // Crop icon (flexible)
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Container(
                              width: size * 0.32,
                              height: size * 0.32,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cropEmoji ?? '＋',
                                style: TextStyle(
                                  fontSize: size * 0.20,
                                  fontWeight: FontWeight.bold,
                                  color: isEmpty
                                      ? Colors.green.shade800
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Label (flexible, auto-scales)
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                      color: Colors.black26,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
