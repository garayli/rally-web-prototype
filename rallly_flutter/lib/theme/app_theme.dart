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
