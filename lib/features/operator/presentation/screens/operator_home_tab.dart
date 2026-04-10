import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OperatorHomeTab extends StatefulWidget {
  final String rol;
  const OperatorHomeTab({super.key, required this.rol});

  @override
  State<OperatorHomeTab> createState() => _OperatorHomeTabState();
}

class _OperatorHomeTabState extends State<OperatorHomeTab> {
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOnline ? Icons.airport_shuttle_rounded : Icons.power_settings_new_rounded,
              size: 80,
              color: isOnline ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              "Panel de Operador",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOnline ? "Estás EN LÍNEA y listo para recibir misiones." : "Estás DESCONECTADO.",
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline ? AppColors.accentCoral : AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () {
                  setState(() {
                    isOnline = !isOnline;
                  });
                },
                child: Text(
                  isOnline ? "DESCONECTARSE" : "CONECTARSE",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
