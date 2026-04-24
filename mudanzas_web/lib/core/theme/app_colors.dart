import 'package:flutter/material.dart';

class AppColors {
  // ─── MARCA (BRAND) ─────────────────────────────────────────────────────────
  static const Color accentCoral = Color(0xFFF5897C); // Rosa Salmón Moobox
  static const Color secondarySalmon = Color(0xFFFFB3A9);
  static const Color primaryBlue = Color(0xFF1E235D); // Mantener por compatibilidad
  
  // ─── MODO CLARO (PREMIUM LUXURY) ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFCFCFD); 
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF8FAFC);
  static const Color textMainLight = Color(0xFF0F172A); 
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFF1F5F9);
  
  // ─── MODO OSCURO (DEEP MINIMALISM) ─────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF020617);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceElevatedDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0x1AFFFFFF);

  // ─── ESTADOS ──────────────────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color starGold = Color(0xFFFBBF24);
  static const Color white = Color(0xFFFFFFFF);

  // ─── GRADIENTES ────────────────────────────────────────────────────────────
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [accentCoral, Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientLight = LinearGradient(
    colors: [white, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkSectionGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF020617)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── ALIASES DE COMPATIBILIDAD ────────────────────────────────────────────
  static const Color textBlackLight = textMainLight;
  static const Color primaryBlueLight = Color(0xFF2D3580);
  static const Color primaryBlueDeep = Color(0xFF0D1038);
  static const Color textBlack = textMainLight;
  static const Color textMain = textMainLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color dividerGray = dividerLight;
  static const Color background = backgroundLight;
  static const Color surfaceElevated = surfaceElevatedLight;

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  static Color sectionBg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSub(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
}
