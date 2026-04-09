import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderConfirmButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const FastOrderConfirmButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isSubmitting ? null : onPressed,
        child: isSubmitting 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text("PUBLICAR SOLICITUD", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
      ),
    );
  }
}
