import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class MissionBanner extends StatelessWidget {
  const MissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.textBlack, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.textBlack.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))]
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LOGÍSTICA MOOBOX", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.warningYellow, letterSpacing: 2.0)),
                const SizedBox(height: 12),
                Text("Seguridad y\nEficiencia Total", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(height: 20),
                _missionItem("Monitoreo de carga 24/7"),
                _missionItem("Seguros integrados por viaje"),
              ],
            ),
            Positioned(bottom: -15, right: -15, child: Opacity(opacity: 0.9, child: Image.asset('assets/images/LOGOsf.png', height: 130))),
          ],
        ),
      ),
    );
  }

  Widget _missionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.warningYellow),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
