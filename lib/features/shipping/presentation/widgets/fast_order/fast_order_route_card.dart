import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderRouteCard extends StatelessWidget {
  final String origen;
  final String destino;
  final VoidCallback onTapOrigen;
  final VoidCallback onTapDestino;

  const FastOrderRouteCard({
    super.key,
    required this.origen,
    required this.destino,
    required this.onTapOrigen,
    required this.onTapDestino,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _locationSelector(Icons.radio_button_checked, AppColors.primaryBlue, "RECOJO", origen, onTapOrigen),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Align(alignment: Alignment.centerLeft, child: Container(width: 1, height: 25, color: AppColors.dividerGray)),
          ),
          _locationSelector(Icons.location_on, AppColors.accentCoral, "ENTREGA", destino, onTapDestino),
        ],
      ),
    );
  }

  Widget _locationSelector(IconData icon, Color color, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textBlack), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.dividerGray),
        ],
      ),
    );
  }
}
