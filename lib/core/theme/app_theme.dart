import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentCoral,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        onSurface: AppColors.textBlackLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      dividerColor: AppColors.dividerLight,
      
      textTheme: GoogleFonts.quicksandTextTheme().apply(
        bodyColor: AppColors.textBlackLight,
        displayColor: AppColors.textMainLight,
      ),
      
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.white),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.surfaceLight,
        borderColor: AppColors.primaryBlue.withOpacity(0.1),
        textColor: AppColors.textSecondaryLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCoral, // Opcional: El coral resalta más sobre oscuro
        secondary: AppColors.primaryBlue,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        onSurface: AppColors.textMainDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      dividerColor: AppColors.dividerDark,
      
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textMainDark,
        displayColor: AppColors.textMainDark,
      ),

      elevatedButtonTheme: _elevatedButtonTheme(AppColors.textMainDark),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.surfaceElevatedDark,
        borderColor: AppColors.dividerDark,
        textColor: AppColors.textSecondaryDark,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color textColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentCoral,
        foregroundColor: textColor,
        elevation: 2,
        textStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentCoral, width: 2),
      ),
      labelStyle: TextStyle(color: textColor),
    );
  }
}
