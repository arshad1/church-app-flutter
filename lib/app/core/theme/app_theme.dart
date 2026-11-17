import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Sunrise Coral & Indigo" design system.
///
/// The original constant names (background, surface, primary, ...) are kept so
/// every screen that already references them picks up the new palette.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Core palette
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFF0F1535); // deep indigo
  static const Color backgroundAlt = Color(0xFF1C1446); // indigo-violet
  static const Color surface = Color(0xFF1C2050); // solid card / sheet colour
  static const Color surfaceLight = Color(0xFF262B63);

  static const Color primary = Color(0xFFFF7A6B); // coral
  static const Color secondary = Color(0xFFFF4F8B); // pink
  static const Color accent = Color(0xFFFFB86B); // sunrise orange
  static const Color cyan = Color(0xFF3DD6F5); // cool highlight for glows
  static const Color live = Color(0xFFFF3B5C);
  static const Color success = Color(0xFF34D399);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFAEB4DB);
  static const Color textMuted = Color(0xFF7C82B0);
  static const Color borderColor = Color(0xFF2E3372);
  static const Color onPrimary = Color(0xFF2B0A16);

  /// Translucent "glass" fill used for cards on top of the gradient background.
  static Color get glass => Colors.white.withValues(alpha: 0.07);
  static Color get glassBorder => accent.withValues(alpha: 0.22);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundAlt],
  );

  static LinearGradient get imageOverlay => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background.withValues(alpha: 0.10),
      background.withValues(alpha: 0.92),
    ],
  );

  static List<BoxShadow> glow([Color color = secondary, double alpha = 0.35]) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------
  /// Elegant serif used for headings.
  static TextStyle heading({
    double fontSize = 22,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) => GoogleFonts.playfairDisplay(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    height: height,
  );

  /// Clean sans-serif used for body text.
  static TextStyle body({
    double fontSize = 14,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
  );

  // ---------------------------------------------------------------------------
  // Inputs
  // ---------------------------------------------------------------------------
  static InputDecoration inputDecoration({
    String? label,
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: accent, size: 20) : null,
      suffixIcon: suffix,
      labelStyle: const TextStyle(color: textSecondary),
      floatingLabelStyle: const TextStyle(color: accent),
      hintStyle: const TextStyle(color: textMuted),
      filled: true,
      fillColor: glass,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: live),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: live, width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // ---------------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------------
  static final ThemeData dark = _buildDark();

  /// The app is designed dark-first; the light slot uses the same theme so
  /// devices in light mode still get the intended look.
  static final ThemeData light = dark;

  static ThemeData _buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        error: live,
        onPrimary: onPrimary,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: heading(fontSize: 30),
        headlineMedium: heading(fontSize: 26),
        headlineSmall: heading(fontSize: 22),
        titleLarge: heading(fontSize: 20),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: heading(fontSize: 22),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: heading(fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: body(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: glassBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glass,
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: accent),
        hintStyle: const TextStyle(color: textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      tabBarTheme: TabBarThemeData(
        labelColor: onPrimary,
        unselectedLabelColor: textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: body(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: body(fontSize: 13, fontWeight: FontWeight.w500),
        indicator: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: glass,
        selectedColor: primary,
        side: BorderSide(color: glassBorder),
        labelStyle: body(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
