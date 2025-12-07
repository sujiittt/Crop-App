// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme - compatibility-friendly theme used across the project.
/// It intentionally provides legacy getters and helper methods (getSuccessColor(bool), textSecondaryLight)
/// which the existing widgets call throughout the app.
class AppTheme {
  AppTheme._();

  // ---------- Color tokens ----------
  static const Color primary = Color(0xFF2E7D32); // faded green
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color accentBrown = Color(0xFFA1887F);
  static const Color accentBrownDark = Color(0xFF8D6E63);
  static const Color white = Colors.white;

  // legacy names used by many widgets:
  static const Color textPrimaryLight = Color(0xFF1B1B1B);
  static const Color textSecondaryLight = Color(0xFF6D6D6D);
  static const Color successLight = Color(0xFF43A047);
  static const Color warningLight = Color(0xFFFFC107);
  static const Color errorLight = Color(0xFFE53935);
  static const Color scaffoldBg = Color(0xFFF7FFF7);

  // ---------- Legacy-compatible getters (accept bool isDark) ----------
  // Older code calls AppTheme.getSuccessColor(true) / getAccentColor(false) etc.
  // Provide those signatures so nothing breaks.
  static Color getSuccessColor([bool isDark = false]) => isDark ? Color(0xFF81C784) : successLight;
  static Color getWarningColor([bool isDark = false]) => isDark ? Color(0xFFFFD54F) : warningLight;
  static Color getAccentColor([bool isDark = false]) => isDark ? accentBrownDark : accentBrown;
  static Color getErrorColor([bool isDark = false]) => isDark ? Color(0xFFEF9A9A) : errorLight;

  // Backwards-compatible short getters
  static Color get success => successLight;
  static Color get warning => warningLight;
  static Color get error => errorLight;
  static Color get textSecondary => textSecondaryLight;

  // ---------- Minimal ThemeData (safe for multiple SDKs) ----------
  // NOTE: We avoid an explicit `cardTheme:` assignment that triggered a type mismatch
  // error in some SDKs. Instead we set cardColor + rely on defaults for the rest.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: scaffoldBg,
    cardColor: white,

    // use a simple ColorScheme to ensure compatibility
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accentBrown,
      background: scaffoldBg,
      surface: white,
      onPrimary: white,
      onSurface: textPrimaryLight,
      onBackground: textPrimaryLight,
    ),

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: white,
      ),
      iconTheme: const IconThemeData(color: white),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary.withOpacity(0.9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 6,
    ),

    // bottom nav defaults
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primary,
      unselectedItemColor: textSecondaryLight,
      elevation: 8,
    ),

    // text theme (kept small and safe)
    textTheme: TextTheme(
      titleLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimaryLight),
      bodyLarge: GoogleFonts.openSans(fontSize: 15, color: textPrimaryLight),
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: textPrimaryLight),
      bodySmall: GoogleFonts.openSans(fontSize: 12, color: textSecondaryLight),
    ),
  );

  // Minimal dark theme mirroring same tokens
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accentBrownDark,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onPrimary: white,
      onSurface: white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF162E16),
      titleTextStyle: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w700, color: white),
      iconTheme: const IconThemeData(color: white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: white,
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w700, color: white),
      bodyLarge: GoogleFonts.openSans(fontSize: 15, color: white),
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.grey.shade300),
      bodySmall: GoogleFonts.openSans(fontSize: 12, color: Colors.grey.shade400),
    ),
  );
}

/// Extension to provide the small `.withValues(alpha: ...)` helper used in the project.
/// This mirrors old helper behavior (alpha 0..1) — returns color.withOpacity(alpha).
extension ColorHelpers on Color {
  /// withValues(alpha: 0.1) => color.withOpacity(0.1)
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    if (alpha <= 0.0) return withOpacity(0.0);
    if (alpha >= 1.0) return withOpacity(1.0);
    return withOpacity(alpha);
  }
}
