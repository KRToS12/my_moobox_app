import 'package:flutter/material.dart';

class AppColors {
  // Colores principales del Logo
  static const Color accentCoral = Color(0xFFF5897C); // Color basico MOOBOX
  static const Color primaryBlue = Color(0xFF1E235D); // Color segundario MOOBOX
  

  // Colores de superficie y fondo
  static const Color background = Color(0xFFF8F9FA);  // Blanco humo para los fondos
  static const Color white = Color(0xFFFFFFFF);

  // Colores de estado y texto
  static const Color textMain = Color(0xFF1E235D);    // azul para títulos
  static const Color textSecondary = Color(0xFF64748B); // Gris azulado para subtítulos
  static const Color statusSuccess = Color(0xFF48CAE4); // Turquesa para Libres 
  static const Color error = Color(0xFFE63946);       // Rojo suave para errores

  // Gradiente opcional para banners
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF323A8C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}