import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ─── TEMA CLARO ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentCoral, // Cambiado de azul a coral
        secondary: AppColors.primaryBlue,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textBlackLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      dividerColor: AppColors.dividerLight,
      textTheme: GoogleFonts.workSansTextTheme().apply(
        bodyColor: AppColors.textSecondaryLight,
        displayColor: AppColors.accentCoral, // Cambiado de azul a coral
      ),
      elevatedButtonTheme: _elevatedButton(AppColors.white),
      outlinedButtonTheme: _outlinedButton(AppColors.accentCoral),
      inputDecorationTheme: _inputDecoration(
        fill: AppColors.surfaceLight,
        border: AppColors.dividerLight,
        label: AppColors.textSecondaryLight,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  // ─── TEMA OSCURO ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCoral,
        secondary: AppColors.primaryBlueLight,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textMainDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      dividerColor: AppColors.dividerDark,
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textSecondaryDark,
        displayColor: AppColors.textMainDark,
      ),
      elevatedButtonTheme: _elevatedButton(AppColors.white),
      outlinedButtonTheme: _outlinedButton(AppColors.accentCoral),
      inputDecorationTheme: _inputDecoration(
        fill: AppColors.surfaceElevatedDark,
        border: AppColors.dividerDark,
        label: AppColors.textSecondaryDark,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  // ─── HELPERS PRIVADOS ─────────────────────────────────────────────────────
  static ElevatedButtonThemeData _elevatedButton(Color textColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentCoral,
        foregroundColor: textColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(Color color) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration({
    required Color fill,
    required Color border,
    required Color label,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentCoral, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: GoogleFonts.workSans(color: label, fontSize: 15),
      hintStyle: GoogleFonts.workSans(
        color: label.withValues(alpha: 0.6),
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }
}
