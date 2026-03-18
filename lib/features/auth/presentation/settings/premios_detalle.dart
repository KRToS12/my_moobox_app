import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ReferidosPremiosScreen extends StatelessWidget {
  const ReferidosPremiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PREMIOS Y REFERIDOS",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textBlack,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de la sección en el perfil
            Icon(
              Icons.card_giftcard_rounded, 
              size: 80, 
              color: AppColors.primaryBlue.withOpacity(0.2)
            ),
            const SizedBox(height: 20),
            Text(
              "PRÓXIMAMENTE",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "Estamos preparando recompensas exclusivas para tus fletes en Bolivia.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}