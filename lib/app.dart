import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'core/theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moobox App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.accentCoral,
          surface: AppColors.background,
          onPrimary: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.background,

        // Tipografía Quicksand
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppColors.primaryBlue,
          displayColor: AppColors.primaryBlue,
        ),

        // Botones Redondeados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentCoral,
            foregroundColor: AppColors.white,
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
        ),

        // Inputs con estilo Moobox
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentCoral, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}