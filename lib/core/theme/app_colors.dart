import 'package:flutter/material.dart';

class AppColors {
  // --- COLORES DE MARCA (BRAND) ---
  static const Color accentCoral = Color(0xFFF5897C); // Identidad base
  static const Color primaryBlue = Color(0xFF1E235D); // Azul Corporativo

  // --- ESCALA DE GRISES Y NEGROS (Para evitar look infantil) ---
  static const Color textBlack = Color(0xFF0F172A);    // Negro Slate (Más profesional)
  static const Color textMain = Color(0xFF1E235D);     // Azul profundo para títulos
  static const Color textSecondary = Color(0xFF64748B); // Gris para descripciones
  static const Color dividerGray = Color(0xFFE2E8F0);   // Para bordes finos

  // --- GAMA DE ESTADOS (LOGÍSTICA) ---
  static const Color warningYellow = Color(0xFFFBBF24); // Amarillo Tráfico (Alertas/Espera)
  static const Color statusSuccess = Color(0xFF10B981); // Verde Esmeralda (Entregado/Activo)
  static const Color infoBlue = Color(0xFF3B82F6);      // Azul brillante (En camino)
  static const Color error = Color(0xFFEF4444);         // Rojo técnico (Cancelado)

  // --- SUPERFICIES Y FONDOS ---
  static const Color background = Color(0xFFF8F9FA);    // Blanco Humo Unificado
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Gris muy claro para tarjetas

  // --- GRADIENTES ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}