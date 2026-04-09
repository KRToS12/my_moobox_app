import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderServicesCard extends StatelessWidget {
  final int ayudantes;
  final int pisosOrigen;
  final int pisosDestino;
  final double pesoTN;
  final ValueChanged<int> onAyudantesChanged;
  final ValueChanged<int> onPisosOrigenChanged;
  final ValueChanged<int> onPisosDestinoChanged;

  const FastOrderServicesCard({
    super.key,
    required this.ayudantes,
    required this.pisosOrigen,
    required this.pisosDestino,
    required this.pesoTN,
    required this.onAyudantesChanged,
    required this.onPisosOrigenChanged,
    required this.onPisosDestinoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _counterRow("Ayudantes", ayudantes, onAyudantesChanged),
          _buildSmartRecommendation(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: AppColors.dividerGray)),
          _counterRow("Pisos Origen", pisosOrigen, onPisosOrigenChanged),
          const SizedBox(height: 10),
          _counterRow("Pisos Destino", pisosDestino, onPisosDestinoChanged),
        ],
      ),
    );
  }

  Widget _buildSmartRecommendation() {
    String rec = "Recomendado: ";
    if (pesoTN <= 3) rec += "1 ayudante.";
    else if (pesoTN <= 10) rec += "2-3 ayudantes.";
    else rec += "4+ ayudantes.";

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(rec, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryBlue))),
        ],
      ),
    );
  }

  Widget _counterRow(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
        Row(
          children: [
            _circleButton(Icons.remove, () => onChanged(value - 1)),
            SizedBox(width: 35, child: Center(child: Text("$value", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900)))),
            _circleButton(Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.dividerGray)),
        child: Icon(icon, size: 16, color: AppColors.primaryBlue),
      ),
    );
  }
}
