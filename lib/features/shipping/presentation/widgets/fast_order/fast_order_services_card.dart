import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _counterRow(
              context: context,
              label: "ESTIBADORES / AYUDANTES", 
              icon: Icons.groups_rounded, 
              value: ayudantes, 
              onChanged: onAyudantesChanged
            ),
            _buildSmartRecommendation(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20), 
              child: Divider(color: Theme.of(context).dividerColor, thickness: 0.5)
            ),
            Row(
              children: [
                Expanded(child: _miniCounter(context, "PISO ORIGEN", pisosOrigen, onPisosOrigenChanged)),
                const SizedBox(width: 20),
                Expanded(child: _miniCounter(context, "PISO DESTINO", pisosDestino, onPisosDestinoChanged)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartRecommendation() {
    String rec = "RECOMENDACIÓN IA: ";
    if (pesoTN <= 3) rec += "1 AYUDANTE.";
    else if (pesoTN <= 10) rec += "2-3 AYUDANTES.";
    else rec += "4+ AYUDANTES.";

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.03), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rec, 
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: FontWeight.w900, 
                color: AppColors.primaryBlue,
                letterSpacing: 0.5,
              )
            )
          ),
        ],
      ),
    );
  }

  Widget _counterRow({required BuildContext context, required String label, required IconData icon, required int value, required Function(int) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label, 
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: FontWeight.w900, 
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                letterSpacing: 0.5,
              )
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CANTIDAD REQUERIDA", 
              style: GoogleFonts.inter(
                fontSize: 13, 
                fontWeight: FontWeight.w700, 
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            _buildControl(context, value, onChanged),
          ],
        ),
      ],
    );
  }

  Widget _miniCounter(BuildContext context, String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.inter(
            fontSize: 9, 
            fontWeight: FontWeight.w900, 
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            letterSpacing: 0.5,
          )
        ),
        const SizedBox(height: 10),
        _buildControl(context, value, onChanged, isSmall: true),
      ],
    );
  }

  Widget _buildControl(BuildContext context, int value, Function(int) onChanged, {bool isSmall = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleButton(context, Icons.remove, () => value > 0 ? {HapticFeedback.lightImpact(), onChanged(value - 1)} : null),
          Container(
            constraints: BoxConstraints(minWidth: isSmall ? 30 : 45),
            child: Center(
              child: Text(
                "$value", 
                style: GoogleFonts.inter(
                  fontSize: isSmall ? 14 : 16, 
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )
              )
            ),
          ),
          _circleButton(context, Icons.add, () => {HapticFeedback.lightImpact(), onChanged(value + 1)}),
        ],
      ),
    );
  }

  Widget _circleButton(BuildContext context, IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 16, color: onTap == null ? Theme.of(context).dividerColor : AppColors.primaryBlue),
        ),
      ),
    );
  }
}
