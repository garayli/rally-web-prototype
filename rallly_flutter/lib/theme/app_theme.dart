import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color palette (matches HTML prototype) ────────────────────────────────
class RallyColors {
  RallyColors._();

  // Light mode
  static const bg = Color(0xFFF5F0E8);
  static const white = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFEDE8DE);
  static const border = Color(0xFFE0D8CC);
  static const border2 = Color(0xFFD4C8B8);

  static const accent = Color(0xFF5A8A00);       // tennis ball green
  static const accentLight = Color(0xFFF0EBE0);
  static const accent2 = Color(0xFFC8431A);       // clay red
  static const accent2Light = Color(0xFFFEF2EE);
  static const accent3 = Color(0xFF8DB600);       // bright yellow-green

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const muted = Color(0xFF9CA3AF);
  static const muted2 = Color(0xFFD1D5DB);

  // Dark mode
  static const darkBg = Color(0xFF0F110D);
  static const darkSurface = Color(0xFF181C14);
  static const darkSurface2 = Color(0xFF1F2418);
  static const darkBorder = Color(0xFF2A3020);
  static const darkBorder2 = Color(0xFF364030);
  static const darkAccent = Color(0xFF8DB600);
  static const darkText = Color(0xFFF1F5E8);
  static const darkText2 = Color(0xFFA0AA88);
  static const darkMuted = Color(0xFF5A6448);

  // Skill level pill colours
  static const skillAdvBg = Color(0xFFEAF5D3);
  static const skillAdvFg = Color(0xFF3A6200);
  static const skillInterBg = Color(0xFFFFF4E6);
  static const skillInterFg = Color(0xFFC46A00);
  static const skillBegBg = Color(0xFFEEF4FF);
  static const skillBegFg = Color(0xFF3B6DD9);
}

// ─── ThemeData factory ───────────────────────────────────────────────────────
class RallyTheme {
  RallyTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? RallyColors.darkAccent : RallyColors.accent,
      onPrimary: Colors.white,
      secondary: RallyColors.accent2,
      onSecondary: Colors.white,
      error: RallyColors.accent2,
      onError: Colors.white,
      surface: isDark ? RallyColors.darkSurface : RallyColors.white,
      onSurface: isDark ? RallyColors.darkText : RallyColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? RallyColors.darkBg : RallyColors.bg,

      // Typography
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 48,
          letterSpacing: -2,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 36,
          letterSpacing: -1.5,
        ),
        displaySmall: const TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 28,
          letterSpacing: -1,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'InstrumentSerif',
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: (isDark ? RallyColors.darkBg : RallyColors.bg)
            .withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isDark ? RallyColors.darkText : RallyColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: isDark ? RallyColors.darkText : RallyColors.textPrimary,
        ),
      ),

      // Bottom Nav Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? RallyColors.darkSurface : RallyColors.white,
        selectedItemColor: isDark ? RallyColors.darkAccent : RallyColors.accent,
        unselectedItemColor: isDark ? RallyColors.darkMuted : RallyColors.muted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3,
        ),
        elevation: 12,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? RallyColors.darkSurface : RallyColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? RallyColors.darkBorder : RallyColors.border,
          ),
        ),
      ),

      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? RallyColors.darkAccent : RallyColors.accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? RallyColors.darkText : RallyColors.textPrimary,
          side: BorderSide(
            color: isDark ? RallyColors.darkBorder2 : RallyColors.border2,
            width: 1.5,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? RallyColors.darkSurface : RallyColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? RallyColors.darkBorder2 : RallyColors.border2,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? RallyColors.darkBorder2 : RallyColors.border2,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? RallyColors.darkAccent : RallyColors.accent,
            width: 1.5,
          ),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: isDark ? RallyColors.darkMuted : RallyColors.muted,
          letterSpacing: 0.5,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: isDark ? RallyColors.darkMuted : RallyColors.muted2,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? RallyColors.darkBorder : RallyColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ─── Court Palette System ─────────────────────────────────────────────────────
// Three court-type themes (Clay / Hard / Grass) translated from the V2
// HTML prototype's CSS variables. Screens read these via CourtPalette.of(context).

enum CourtTheme { clay, hard, grass }

class CourtPalette {
  final CourtTheme theme;
  final Color bg;
  final Color surface;
  final Color surfaceSoft;
  final Color border;
  final Color border2;
  final Color accent;
  final Color accentStrong;
  final Color accentSoft;
  final Color accentTint;
  final Color highlight;
  final Color highlightTint;
  final Color text;
  final Color text2;
  final Color muted;
  final Color muted2;
  final Color gradA;
  final Color gradB;
  final Color skillBg;
  final Color skillFg;

  const CourtPalette._({
    required this.theme,
    required this.bg,
    required this.surface,
    required this.surfaceSoft,
    required this.border,
    required this.border2,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.accentTint,
    required this.highlight,
    required this.highlightTint,
    required this.text,
    required this.text2,
    required this.muted,
    required this.muted2,
    required this.gradA,
    required this.gradB,
    required this.skillBg,
    required this.skillFg,
  });

  static const CourtPalette clay = CourtPalette._(
    theme: CourtTheme.clay,
    bg:           Color(0xFFF3E5D2),
    surface:      Color(0xFFFBF3E4),
    surfaceSoft:  Color(0xFFEBD9BB),
    border:       Color(0xFFDEC8A4),
    border2:      Color(0xFFC9B084),
    accent:       Color(0xFFB7421A),
    accentStrong: Color(0xFF8E2F11),
    accentSoft:   Color(0xFFF4D3B8),
    accentTint:   Color(0xFFFAE4CF),
    highlight:    Color(0xFF1F3A2B),
    highlightTint:Color(0xFFDCE5DA),
    text:         Color(0xFF2A1A10),
    text2:        Color(0xFF5C4232),
    muted:        Color(0xFF997757),
    muted2:       Color(0xFFC9B084),
    gradA:        Color(0xFFC84A22),
    gradB:        Color(0xFF8E2F11),
    skillBg:      Color(0xFFFAE4CF),
    skillFg:      Color(0xFF8E2F11),
  );

  static const CourtPalette hard = CourtPalette._(
    theme: CourtTheme.hard,
    bg:           Color(0xFFECEFF5),
    surface:      Color(0xFFFFFFFF),
    surfaceSoft:  Color(0xFFDDE3EE),
    border:       Color(0xFFC8D2E2),
    border2:      Color(0xFFA6B4CB),
    accent:       Color(0xFF1E5DC2),
    accentStrong: Color(0xFF0F3F8E),
    accentSoft:   Color(0xFFBFD0EE),
    accentTint:   Color(0xFFDCE6F6),
    highlight:    Color(0xFFFF8A1F),
    highlightTint:Color(0xFFFFE4C4),
    text:         Color(0xFF0E1A2E),
    text2:        Color(0xFF3A4A66),
    muted:        Color(0xFF6F7E94),
    muted2:       Color(0xFFA6B4CB),
    gradA:        Color(0xFF2E73DC),
    gradB:        Color(0xFF0F3F8E),
    skillBg:      Color(0xFFDCE6F6),
    skillFg:      Color(0xFF0F3F8E),
  );

  static const CourtPalette grass = CourtPalette._(
    theme: CourtTheme.grass,
    bg:           Color(0xFFF4F1E6),
    surface:      Color(0xFFFFFFFF),
    surfaceSoft:  Color(0xFFE6E3D1),
    border:       Color(0xFFD5D0BC),
    border2:      Color(0xFFBAB59C),
    accent:       Color(0xFF1F5C36),
    accentStrong: Color(0xFF0F3D22),
    accentSoft:   Color(0xFFCAD9B8),
    accentTint:   Color(0xFFE2EBD0),
    highlight:    Color(0xFFC8A04A),
    highlightTint:Color(0xFFF2E5C4),
    text:         Color(0xFF1A2718),
    text2:        Color(0xFF3D4D38),
    muted:        Color(0xFF7C8576),
    muted2:       Color(0xFFBAB59C),
    gradA:        Color(0xFF2A7A48),
    gradB:        Color(0xFF0F3D22),
    skillBg:      Color(0xFFE2EBD0),
    skillFg:      Color(0xFF0F3D22),
  );

  String get displayName {
    switch (theme) {
      case CourtTheme.clay:  return 'Toprak';
      case CourtTheme.hard:  return 'Sert Kort';
      case CourtTheme.grass: return 'Çim';
    }
  }
}
