import 'package:flutter/material.dart';

class AppColors {
  // --- MARCA (BRAND) ---
  static const Color accentCoral = Color(0xFFF5897C); 
  static const Color primaryBlue = Color(0xFF1E235D); 

  // --- MODO CLARO (LIGHT THEME) ---
  static const Color backgroundLight = Color(0xFFF8F9FA);    
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9); 
  static const Color textMainLight = Color(0xFF1E235D);
  static const Color textBlackLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  
  // --- MODO OSCURO (DARK THEME) ---
  static const Color backgroundDark = Color(0xFF0A0A0A); 
  static const Color surfaceDark = Color(0xFF141414); 
  static const Color surfaceElevatedDark = Color(0xFF1A1A1A); 
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  
  // --- BORDES Y SEPARADORES ---
  static const Color dividerLight = Color(0xFFE2E8F0);   
  static const Color dividerDark = Color(0x1AFFFFFF); // white10
  
  // --- CONSTANTES GLOBALES Y ESTADOS ---
  static const Color warningYellow = Color(0xFFFBBF24); 
  static const Color statusSuccess = Color(0xFF10B981); 
  static const Color infoBlue = Color(0xFF3B82F6);      
  static const Color error = Color(0xFFEF4444);         

  // --- COMPATIBILIDAD (Reemplazos Progresivos a Theme.of(context)) ---
  static const Color textBlack = textBlackLight;
  static const Color textMain = textMainLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color dividerGray = dividerLight;
  static const Color background = backgroundLight;
  static const Color white = Colors.white;
  static const Color surfaceElevated = surfaceElevatedLight;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}