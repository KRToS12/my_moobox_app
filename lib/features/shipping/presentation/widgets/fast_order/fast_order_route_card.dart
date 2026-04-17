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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
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
              left: 16.5,
              top: 40,
              bottom: 40,
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
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    )),
                  );
                },
              ),
            ),
            
            Column(
              children: [
                _locationSelector(context,
                  icon: Icons.panorama_fish_eye_rounded, 
                  color: AppColors.primaryBlue, 
                  label: "PUNTO DE RECOJO", 
                  value: origen, 
                  onTap: onTapOrigen,
                  isPrimary: true,
                ),
                const SizedBox(height: 32),
                _locationSelector(context,
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

  Widget _locationSelector(BuildContext context, {
    required IconData icon, 
    required Color color, 
    required String label, 
    required String value, 
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    bool isSelected = !value.contains("Seleccionar");

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alineación centrada para mejor look
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Un poco más de aire
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 1.5), // Círculo más definido
            ),
            child: Icon(icon, color: color, size: 18),
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
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    letterSpacing: 0.5,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  value, 
                  style: GoogleFonts.inter(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700, 
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
          isSelected 
            ? const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.statusSuccess)
            : Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
