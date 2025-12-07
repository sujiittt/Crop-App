// lib/presentation/widgets/farm_canvas/iso_tile_3d.dart
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:flutter/material.dart';

/// 2.5D farm plot tile with smooth tilt/parallax and micro-animations.
/// - Tunable sensitivity & limits
/// - Press scale & spring snap-back
/// - Reminder badge
/// - "+" ghost when empty
///
/// Backward compatible with previous Step B/C API.
class IsoTile3D extends StatefulWidget {
  const IsoTile3D({
    super.key,
    this.size = 96,
    required this.onTap,
    this.onLongPress,

    // State data
    this.cropKey,
    this.hasReminder = false,
    this.isEmpty,

    // Visuals
    this.soilTextureAsset = 'assets/soil/soil_noise.png',
    this.elevation = 10,
    this.borderRadius = 14,

    // ✨ New: motion tuning (all optional; sensible defaults)
    this.maxTiltRadians,        // default: 0.25 * pi
    this.dragToTiltFactor,      // default: 0.06 (per px)
    this.hoverToTiltFactor,     // default: 0.18 (normalized -1..1)
    this.springDuration,        // default: 240ms
    this.pressScale,            // default: 0.985 (subtle)
  });

  // Size & actions
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  // Data
  final String? cropKey;
  final bool? isEmpty;
  final bool hasReminder;

  // Look
  final String soilTextureAsset;
  final double elevation;
  final double borderRadius;

  // Motion knobs
  final double? maxTiltRadians;
  final double? dragToTiltFactor;
  final double? hoverToTiltFactor;
  final Duration? springDuration;
  final double? pressScale;

  @override
  State<IsoTile3D> createState() => _IsoTile3DState();
}

class _IsoTile3DState extends State<IsoTile3D> with SingleTickerProviderStateMixin {
  // Current tilt state
  double _tiltX = 0; // pitch
  double _tiltY = 0; // yaw

  // Press scale state
  double _scale = 1.0;

  late final AnimationController _spring;
  late final Animation<double> _anim;

  // Defaults (can be overridden per-instance)
  double get _maxTilt => widget.maxTiltRadians ?? (0.25 * math.pi);
  double get _dragFactor => widget.dragToTiltFactor ?? 0.06;
  double get _hoverFactor => widget.hoverToTiltFactor ?? 0.18;
  Duration get _springDur => widget.springDuration ?? const Duration(milliseconds: 240);
  double get _pressScale => widget.pressScale ?? 0.985;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController(vsync: this, duration: _springDur);
    _anim = CurvedAnimation(parent: _spring, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant IsoTile3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If user changes spring duration at runtime, update controller.
    if (oldWidget.springDuration != widget.springDuration) {
      _spring.duration = _springDur;
    }
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  // Map crop key -> asset filename (extend as you add images)
  String _assetForCropKey(String? key) {
    switch ((key ?? '').toLowerCase()) {
      case 'wheat':
        return 'assets/crops/wheat.png';
      case 'rice':
        return 'assets/crops/rice.png';
      case 'corn':
        return 'assets/crops/corn.png';
      case 'cotton':
        return 'assets/crops/cotton.png';
      case 'onion':
        return 'assets/crops/onion.png';
      case 'potato':
        return 'assets/crops/potato.png';
      case 'sugarcane':
        return 'assets/crops/sugarcane.png';
      case 'pulses':
        return 'assets/crops/pulses.png';
      default:
        return '';
    }
  }

  bool get _isEmpty {
    if (widget.isEmpty != null) return widget.isEmpty!;
    final key = widget.cropKey;
    return key == null || key.trim().isEmpty || _assetForCropKey(key).isEmpty;
  }

  void _animateBackToRest() {
    final startX = _tiltX;
    final startY = _tiltY;
    final startScale = _scale;

    void listener() {
      setState(() {
        _tiltX = lerpDouble(startX, 0, _anim.value)!;
        _tiltY = lerpDouble(startY, 0, _anim.value)!;
        _scale = lerpDouble(startScale, 1.0, _anim.value)!;
      });
    }

    _spring
      ..removeListener(listener)
      ..addListener(listener)
      ..reset()
      ..forward().whenCompleteOrCancel(() {
        _spring.removeListener(listener);
      });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    // Clamp input to avoid sudden spikes on emulators
    final dx = d.delta.dx.clamp(-12, 12);
    final dy = d.delta.dy.clamp(-12, 12);

    setState(() {
      _tiltY = (_tiltY + dx * _dragFactor).clamp(-_maxTilt, _maxTilt);
      _tiltX = (_tiltX - dy * _dragFactor).clamp(-_maxTilt, _maxTilt);
    });
  }

  void _onPanStart([DragStartDetails? _]) {
    // subtle press scale when user starts interacting
    setState(() => _scale = _pressScale);
  }

  void _onPanEnd([DragEndDetails? _]) => _animateBackToRest();

  void _onHover(PointerHoverEvent e, Size size) {
    // Desktop/Web only hover parallax
    final local = e.localPosition;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = ((local.dx - cx) / cx).clamp(-1.0, 1.0);
    final dy = ((local.dy - cy) / cy).clamp(-1.0, 1.0);
    setState(() {
      _tiltY = (dx * _hoverFactor).clamp(-_maxTilt, _maxTilt);
      _tiltX = (-dy * _hoverFactor).clamp(-_maxTilt, _maxTilt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final bevelHeight = size * 0.08;
    final cropAsset = _assetForCropKey(widget.cropKey);
    final hasCrop = !_isEmpty && cropAsset.isNotEmpty;

    // Perspective + current tilt
    final m = Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..rotateX(_tiltX)
      ..rotateY(_tiltY);

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Elevation shadow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius + 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: widget.elevation,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          // Base block gradient
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isEmpty
                        ? const [Color(0xFFCFB8A4), Color(0xFFB79379)]
                        : const [Color(0xFFB7E0B5), Color(0xFF8ACB88)],
                  ),
                ),
              ),
            ),
          ),
          // Soil layer with texture
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _isEmpty
                            ? const [Color(0xFFEEDFCC), Color(0xFFD6BFA3)]
                            : const [Color(0xFFE7F5E8), Color(0xFFD5F0DA)],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.25,
                    child: Image.asset(
                      widget.soilTextureAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bevel highlight
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: bevelHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.borderRadius),
                topRight: Radius.circular(widget.borderRadius),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          // Crop sprite
          if (hasCrop)
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -2),
                  child: _CropSprite(asset: cropAsset),
                ),
              ),
            ),
          // Reminder badge
          if (widget.hasReminder)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_active, size: 12, color: Colors.white),
              ),
            ),
          // "+" ghost if empty
          if (!hasCrop)
            Positioned.fill(
              child: Center(
                child: Icon(Icons.add, size: 22, color: Colors.brown.withOpacity(0.55)),
              ),
            ),
        ],
      ),
    );

    final content = MouseRegion(
      onExit: (_) => _animateBackToRest(),
      onHover: kIsWeb
          ? (e) {
        final box = context.findRenderObject() as RenderBox?;
        final sz = box?.size ?? Size(widget.size, widget.size);
        _onHover(e, sz);
      }
          : null,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTapDown: (_) {
          setState(() => _scale = _pressScale);
        },
        onTapUp: (_) {
          _animateBackToRest();
          widget.onTap();
        },
        onTapCancel: _animateBackToRest,
        child: Transform(
          alignment: Alignment.center,
          transform: m,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            child: tile,
          ),
        ),
      ),
    );

    return content;
  }
}

class _CropSprite extends StatelessWidget {
  const _CropSprite({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 12,
          right: 12,
          bottom: -2,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.10),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Image.asset(
          asset,
          width: 44,
          height: 44,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40),
        ),
      ],
    );
  }
}
