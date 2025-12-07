// lib/presentation/widgets/farm_canvas/farm_canvas_placeholder.dart
import 'package:flutter/material.dart';

class FarmCanvasPlaceholder extends StatelessWidget {
  const FarmCanvasPlaceholder({super.key});

  static const double _height = 220; // fixed height slot for now

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.20),
            primary.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle background pattern
          Positioned.fill(
            child: CustomPaint(painter: _LightGridPainter(color: primary.withOpacity(0.15))),
          ),

          // Top bar (title + page chip)
          Positioned(
            left: 12,
            right: 12,
            top: 10,
            child: Row(
              children: [
                Icon(Icons.terrain_rounded, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your Fields',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Page 1/1',
                    style: theme.textTheme.labelMedium?.copyWith(color: primary),
                  ),
                ),
              ],
            ),
          ),

          // Center message
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.agriculture_rounded, color: primary, size: 42),
                const SizedBox(height: 8),
                Text(
                  'Farm Canvas coming here',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swipeable fields, tiles & crops will appear in next steps.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LightGridPainter extends CustomPainter {
  final Color color;
  const _LightGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double cell = 20; // light grid spacing
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightGridPainter oldDelegate) =>
      oldDelegate.color != color;
}
