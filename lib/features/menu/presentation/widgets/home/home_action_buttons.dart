import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/features/shipping/presentation/fast_order_screen.dart';
import 'package:my_moobox_app/features/shipping/presentation/selection_order_screen.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _actionButton(
            context,
            "Fast\nTransport",
            Icons.bolt_outlined,
            AppColors.accentCoral,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FastOrderScreen(capacidadSugerida: 0, idVehiculoPreseleccionado: null))),
          ),
          const SizedBox(width: 15),
          _actionButton(
            context,
            "IA\nAsistencia",
            Icons.smart_toy_rounded,
            AppColors.primaryBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectionOrderScreen())),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, 
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, height: 1.1)),
            ],
          ),
        ),
      ),
    );
  }
}
