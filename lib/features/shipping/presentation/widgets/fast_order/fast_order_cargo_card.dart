import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderCargoCard extends StatelessWidget {
  final double pesoTN;
  final String tipoCarga;
  final bool isLocked;
  final ValueChanged<double> onPesoChanged;

  const FastOrderCargoCard({
    super.key,
    required this.pesoTN,
    required this.tipoCarga,
    required this.onPesoChanged,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textBlack, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cargoInfoItem("PESO DE CARGA", "${pesoTN.toStringAsFixed(1)} TN"),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, size: 10, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        "FIJO POR VEHÍCULO",
                        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              // --- ICONO DINÁMICO ---
              AnimatedScale(
                scale: 1.0 + (pesoTN / 30 * 0.5),
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    pesoTN < 5 ? Icons.local_shipping_outlined : Icons.local_shipping,
                    color: AppColors.warningYellow,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.warningYellow,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: AppColors.warningYellow.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 5),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: pesoTN,
              min: 1.0,
              max: 30.0,
              onChanged: isLocked ? null : (val) {
                HapticFeedback.selectionClick();
                onPesoChanged(val);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1 TN", style: GoogleFonts.inter(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w700)),
              Text("CATEGORÍA: ${tipoCarga.toUpperCase()}", style: GoogleFonts.inter(fontSize: 9, color: AppColors.warningYellow, fontWeight: FontWeight.w900)),
              Text("30 TN", style: GoogleFonts.inter(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cargoInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w800)),
        Text(value, style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
