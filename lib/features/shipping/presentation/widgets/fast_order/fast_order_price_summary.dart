import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderPriceSummary extends StatelessWidget {
  final double distanciaKm;
  final double precioEstimado;
  final double pesoTN;
  final bool isLoading;
  final VoidCallback? onPriceChanged;

  const FastOrderPriceSummary({
    super.key,
    required this.distanciaKm,
    required this.precioEstimado,
    required this.pesoTN,
    this.isLoading = false,
    this.onPriceChanged,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.textBlack,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("RESUMEN DE TARIFA", style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900)),
              Text("${distanciaKm.toStringAsFixed(1)} KM", style: const TextStyle(color: AppColors.warningYellow, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              if (isLoading)
                const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryBlue),
                )
              else ...[
                InkWell(
                  onTap: onPriceChanged,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Text(precioEstimado.toStringAsFixed(2), style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      if (onPriceChanged != null)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.edit_outlined, color: AppColors.warningYellow, size: 16),
                        ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 6),
                  child: Text("BOB", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),

          const Divider(color: Colors.white10, height: 30),
          _priceDetailRow("Combustible Diesel", "Tarifa: 9.8 BOB/L"),
          _priceDetailRow("Mano de Obra", "Ajustada por ${pesoTN.toInt()} TN"),
        ],
      ),
    );
  }

  Widget _priceDetailRow(String label, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
          Text(detail, style: GoogleFonts.inter(color: AppColors.warningYellow, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
