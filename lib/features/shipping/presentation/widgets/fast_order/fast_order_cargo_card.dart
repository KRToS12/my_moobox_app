import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderCargoCard extends StatelessWidget {
  final double pesoTN;
  final String tipoCarga;
  final ValueChanged<double> onPesoChanged;

  const FastOrderCargoCard({
    super.key,
    required this.pesoTN,
    required this.tipoCarga,
    required this.onPesoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cargoInfoItem("PESO", "${pesoTN.toStringAsFixed(1)} TN"),
              _cargoInfoItem("CATEGORÍA", tipoCarga.toUpperCase()),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: pesoTN,
            min: 1.0,
            max: 30.0,
            activeColor: AppColors.warningYellow,
            inactiveColor: Colors.white24,
            onChanged: onPesoChanged,
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
