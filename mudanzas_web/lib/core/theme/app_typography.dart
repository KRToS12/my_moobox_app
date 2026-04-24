import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // ============ FONT FAMILIES ============
  static const String headingFamily = 'Outfit';
  static const String bodyFamily = 'WorkSans';

  // ============ DISPLAY / HERO ============
  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 80,
        fontWeight: FontWeight.w900,
        height: 0.95,
        letterSpacing: -3.5,
        color: AppColors.white,
      );

  static TextStyle get displayMd => GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: -2.5,
        color: AppColors.white,
      );

  static TextStyle get displaySm => GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.5,
        color: AppColors.primaryBlue,
      );

  // ============ HEADINGS ============
  static TextStyle get h1 => GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -2.0,
        color: AppColors.primaryBlue,
      );

  static TextStyle get h2 => GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -1.5,
        color: AppColors.primaryBlue,
      );

  static TextStyle get h3 => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.8,
        color: AppColors.primaryBlue,
      );

  static TextStyle get h4 => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.4,
        color: AppColors.primaryBlue,
      );

  // ============ BODY TEXT ============
  static TextStyle get bodyLarge => GoogleFonts.workSans(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.65,
        letterSpacing: 0.1,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get body => GoogleFonts.workSans(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0.05,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get bodySm => GoogleFonts.workSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.textSecondaryLight,
      );

  // ============ UI ELEMENTS ============
  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.accentCoral,
      );

  static TextStyle get buttonPrimary => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.white,
      );

  static TextStyle get buttonOutline => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.white,
      );

  static TextStyle get navItem => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.white,
      );

  static TextStyle get caption => GoogleFonts.workSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get overline => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: AppColors.accentCoral,
      );

  // ============ RESPONSIVE VARIANTS ============
  static TextStyle displayResponsive(double width) {
    if (width < 768) {
      return display.copyWith(fontSize: 44, letterSpacing: -2.0);
    } else if (width < 1024) {
      return display.copyWith(fontSize: 60, letterSpacing: -2.8);
    }
    return display;
  }

  static TextStyle h1Responsive(double width) {
    if (width < 768) {
      return h1.copyWith(fontSize: 32, letterSpacing: -1.0);
    } else if (width < 1024) {
      return h1.copyWith(fontSize: 44, letterSpacing: -1.5);
    }
    return h1;
  }

  static TextStyle h2Responsive(double width) {
    if (width < 768) {
      return h2.copyWith(fontSize: 26, letterSpacing: -0.8);
    } else if (width < 1024) {
      return h2.copyWith(fontSize: 32, letterSpacing: -1.0);
    }
    return h2;
  }
}
