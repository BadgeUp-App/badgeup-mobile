import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand palette — identical in light & dark.
  static const Color primary = Color(0xFF005BC2);
  static const Color primaryContainer = Color(0xFF007AFF);
  static const Color primaryDim = Color(0xFF0050AB);
  static const Color onPrimary = Color(0xFFF9F8FF);

  static const Color secondary = Color(0xFF8E2FBD);
  static const Color secondaryContainer = Color(0xFFF6D9FF);
  static const Color onSecondaryContainer = Color(0xFF7F1BAE);

  static const Color tertiary = Color(0xFF006F28);
  static const Color tertiaryContainer = Color(0xFF6FFB85);
  static const Color onTertiaryContainer = Color(0xFF005D21);
  static const Color tertiaryDim = Color(0xFF006122);

  static const Color pastelPeach = Color(0xFFFFD8C4);
  static const Color onPastelPeach = Color(0xFF7A4A3A);

  static const Color error = Color(0xFFA83836);
  static const Color errorContainer = Color(0xFFFA746F);

  static const Color rarityCommon = Color(0xFFAEB2BB);
  static const Color rarityRare = primaryContainer;
  static const Color rarityEpic = secondary;
  static const Color rarityLegendary = Color(0xFFE7B93B);

  // Compat aliases.
  static const Color primaryOrange = pastelPeach;
  static const Color primaryBlue = primaryContainer;
  static const Color primaryPurple = secondary;
  static const Color accentGreen = tertiary;
  static const Color warningAmber = Color(0xFFE7B93B);
  static const Color errorRed = error;

  // Light surface tokens.
  static const Color _lightSurface = Color(0xFFF9F9FE);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightSurfaceContainerLow = Color(0xFFF2F3FA);
  static const Color _lightSurfaceContainer = Color(0xFFECEEF5);
  static const Color _lightSurfaceContainerHigh = Color(0xFFE5E8F0);
  static const Color _lightSurfaceContainerHighest = Color(0xFFDFE2EC);
  static const Color _lightSurfaceDim = Color(0xFFD6DAE3);
  static const Color _lightOnSurface = Color(0xFF2E333A);
  static const Color _lightOnSurfaceVariant = Color(0xFF5B5F67);
  static const Color _lightOutline = Color(0xFF777B83);
  static const Color _lightOutlineVariant = Color(0xFFAEB2BB);

  // Dark "Deep Slate / Midnight Fog" surface tokens.
  static const Color _darkSurface = Color(0xFF0E1117);
  static const Color _darkSurfaceContainerLowest = Color(0xFF080A0F);
  static const Color _darkSurfaceContainerLow = Color(0xFF14171F);
  static const Color _darkSurfaceContainer = Color(0xFF181C25);
  static const Color _darkSurfaceContainerHigh = Color(0xFF1F232D);
  static const Color _darkSurfaceContainerHighest = Color(0xFF262B36);
  static const Color _darkSurfaceDim = Color(0xFF0A0C11);
  static const Color _darkOnSurface = Color(0xFFE5E8F0);
  static const Color _darkOnSurfaceVariant = Color(0xFF9C9FA8);
  static const Color _darkOutline = Color(0xFF6A6E77);
  static const Color _darkOutlineVariant = Color(0xFF3A3E46);

  // Compat aliases that old screens still reference.
  static const Color darkBg = _darkSurface;
  static const Color darkCard = _darkSurfaceContainer;
  static const Color darkBorder = _darkOutlineVariant;
  static const Color darkSurface = _darkSurface;
  static const Color darkSurfaceContainer = _darkSurfaceContainer;
  static const Color darkSurfaceContainerLow = _darkSurfaceContainerLow;
  static const Color darkSurfaceContainerLowest = _darkSurfaceContainerLowest;
  static const Color darkSurfaceContainerHigh = _darkSurfaceContainerHigh;
  static const Color darkOnSurface = _darkOnSurface;
  static const Color darkOnSurfaceVariant = _darkOnSurfaceVariant;

  // Current brightness flag — synced from MaterialApp.builder.
  static Brightness _brightness = Brightness.light;
  static bool get _isDark => _brightness == Brightness.dark;

  static void syncBrightness(Brightness b) {
    _brightness = b;
  }

  // Adaptive getters. These are NOT const, so widgets that reference them
  // cannot be wrapped in `const` constructors.
  static Color get surface => _isDark ? _darkSurface : _lightSurface;
  static Color get surfaceContainerLowest =>
      _isDark ? _darkSurfaceContainerLowest : _lightSurfaceContainerLowest;
  static Color get surfaceContainerLow =>
      _isDark ? _darkSurfaceContainerLow : _lightSurfaceContainerLow;
  static Color get surfaceContainer =>
      _isDark ? _darkSurfaceContainer : _lightSurfaceContainer;
  static Color get surfaceContainerHigh =>
      _isDark ? _darkSurfaceContainerHigh : _lightSurfaceContainerHigh;
  static Color get surfaceContainerHighest =>
      _isDark ? _darkSurfaceContainerHighest : _lightSurfaceContainerHighest;
  static Color get surfaceDim => _isDark ? _darkSurfaceDim : _lightSurfaceDim;
  static Color get onSurface => _isDark ? _darkOnSurface : _lightOnSurface;
  static Color get onSurfaceVariant =>
      _isDark ? _darkOnSurfaceVariant : _lightOnSurfaceVariant;
  static Color get outline => _isDark ? _darkOutline : _lightOutline;
  static Color get outlineVariant =>
      _isDark ? _darkOutlineVariant : _lightOutlineVariant;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: _isDark
              ? const Color(0x33000000)
              : const Color(0x0F2E333A),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  static List<BoxShadow> get subtleLift => [
        BoxShadow(
          color: _isDark
              ? const Color(0x22000000)
              : const Color(0x0A2E333A),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: _lightSurface,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: secondary,
      onSecondary: Color(0xFFFFF7FC),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: Color(0xFFE9FFE5),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: Color(0xFFFFF7F6),
      errorContainer: errorContainer,
      onErrorContainer: Color(0xFF6E0A12),
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
      surfaceContainerLowest: _lightSurfaceContainerLowest,
      surfaceContainerLow: _lightSurfaceContainerLow,
      surfaceContainer: _lightSurfaceContainer,
      surfaceContainerHigh: _lightSurfaceContainerHigh,
      surfaceContainerHighest: _lightSurfaceContainerHighest,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: _lightOnSurface,
      displayColor: _lightOnSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: _lightOnSurface,
        letterSpacing: -0.4,
      ),
      iconTheme: const IconThemeData(color: _lightOnSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: _lightSurfaceContainerLowest,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceContainerLow,
      hintStyle: GoogleFonts.inter(
        color: _lightOutline.withValues(alpha: 0.55),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryContainer, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pastelPeach,
        foregroundColor: onPastelPeach,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryContainer,
    scaffoldBackgroundColor: _darkSurface,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryContainer,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: primary,
      onPrimaryContainer: Color(0xFFD9E7FF),
      secondary: Color(0xFFE1BBF0),
      onSecondary: Color(0xFF2D0043),
      secondaryContainer: Color(0xFF5B1681),
      onSecondaryContainer: Color(0xFFF6D9FF),
      tertiary: Color(0xFF60EC79),
      onTertiary: Color(0xFF003912),
      tertiaryContainer: Color(0xFF00531E),
      onTertiaryContainer: Color(0xFF6FFB85),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      surfaceContainerLowest: _darkSurfaceContainerLowest,
      surfaceContainerLow: _darkSurfaceContainerLow,
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceContainerHigh,
      surfaceContainerHighest: _darkSurfaceContainerHighest,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: _darkOnSurface,
      displayColor: _darkOnSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: _darkOnSurface,
        letterSpacing: -0.4,
      ),
      iconTheme: const IconThemeData(color: _darkOnSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: _darkSurfaceContainer,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceContainerLow,
      hintStyle: GoogleFonts.inter(
        color: _darkOnSurfaceVariant.withValues(alpha: 0.55),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryContainer, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pastelPeach,
        foregroundColor: onPastelPeach,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
  );
}
