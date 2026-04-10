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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Stack(
          children: [
            // --- LÍNEA DE RUTA (DASHED) ---
            Positioned(
              left: 11,
              top: 30,
              bottom: 30,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const dashHeight = 4.0;
                  const dashGap = 4.0;
                  final count = (constraints.maxHeight / (dashHeight + dashGap)).floor();
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(count, (index) => Container(
                      width: 2,
                      height: dashHeight,
                      decoration: BoxDecoration(
                        color: AppColors.dividerGray,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    )),
                  );
                },
              ),
            ),
            
            Column(
              children: [
                _locationSelector(
                  icon: Icons.panorama_fish_eye_rounded, 
                  color: AppColors.primaryBlue, 
                  label: "PUNTO DE RECOJO", 
                  value: origen, 
                  onTap: onTapOrigen,
                  isPrimary: true,
                ),
                const SizedBox(height: 32),
                _locationSelector(
                  icon: Icons.location_on_rounded, 
                  color: AppColors.accentCoral, 
                  label: "PUNTO DE ENTREGA", 
                  value: destino, 
                  onTap: onTapDestino,
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationSelector({
    required IconData icon, 
    required Color color, 
    required String label, 
    required String value, 
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: GoogleFonts.inter(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  value, 
                  style: GoogleFonts.inter(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700, 
                    color: AppColors.textBlack,
                  ), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.dividerGray),
        ],
      ),
    );
  }
}
