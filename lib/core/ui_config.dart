// lib/core/ui_config.dart
import 'package:flutter/material.dart';

class UIConfig {
  // global default tile tuning
  static const double tileMaxTilt = 0.17; // radians (~10°)
  static const double tileDragFactor = 0.045;
  static const double tileHoverFactor = 0.12;
  static const Duration tileSpring = Duration(milliseconds: 200);
  static const double tilePressScale = 0.99;
}
