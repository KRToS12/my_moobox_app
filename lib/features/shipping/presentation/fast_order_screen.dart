import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class FastOrderScreen extends StatelessWidget {
  const FastOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "FAST TRANSPORT",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textBlack,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Center(
        child: Text(
          "Configurando flujo rápido...",
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}