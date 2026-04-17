import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import 'action_slider.dart';

class DriverOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isSpecial;
  final Position? currentPosition;
  final double? vehicleCapacity;
  final VoidCallback onAccept;

  const DriverOrderCard({
    super.key,
    required this.order,
    this.isSpecial = false,
    this.currentPosition,
    this.vehicleCapacity,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final double reward = (order['monto_ofertado'] ?? 0).toDouble();
    final String destination = _getDestination(order);
    final String cargoType = order['tipo_carga'] ?? "Carga General";
    final double weight = (order['peso_carga'] ?? 0).toDouble();
    
    // Calcular distancia si hay GPS
    double? distanceKm;
    if (currentPosition != null) {
      final directions = order['direcciones'] as List?;
      if (directions != null) {
        final origin = directions.firstWhere(
          (d) => d['tipo_direccion'] == 'origen',
          orElse: () => null,
        );
        if (origin != null) {
          distanceKm = Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            origin['latitud'],
            origin['longitud'],
          ) / 1000;
        }
      }
    }

    final bool isNearby = distanceKm != null && distanceKm <= 2.0;
    final bool isOverweight = vehicleCapacity != null && vehicleCapacity! > 0 && weight > vehicleCapacity!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isSpecial 
            ? AppColors.primaryBlue 
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSpecial ? AppColors.accentCoral : Theme.of(context).dividerColor,
          width: isSpecial ? 2 : 1,
        ),
        boxShadow: [
          if (isSpecial)
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        children: [
          // HEADER: Badge y Etiquetas
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isSpecial)
                  _buildBadge("PARA TU VEHÍCULO", AppColors.accentCoral)
                else if (isOverweight)
                  _buildBadge("PESO EXCEDIDO", AppColors.error)
                else if (isNearby)
                  _buildBadge("CERCA DE TI", AppColors.statusSuccess)
                else
                  _buildBadge("OFERTA ABIERTA", AppColors.primaryBlue.withOpacity(0.5)),
                Text(
                  "Ref: ${order['id_oferta'].toString().substring(0, 6)}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSpecial ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // CUERPO: Cuánto Gano y A Dónde Voy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GANARÁS",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isSpecial ? Colors.white70 : AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            reward.toStringAsFixed(0),
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: isSpecial ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "BOB",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isSpecial ? AppColors.accentCoral : AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (distanceKm != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: isNearby ? AppColors.statusSuccess : (isSpecial ? Colors.white54 : AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${distanceKm.toStringAsFixed(1)} KM",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isNearby ? AppColors.statusSuccess : (isSpecial ? Colors.white54 : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // RUTA: Destino con énfasis
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSpecial ? Colors.white.withOpacity(0.08) : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.accentCoral, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "HACIA:",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSpecial ? Colors.white54 : AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  destination,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: isSpecial ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                
                // Detalles de carga (Peso y Tipo) en una sola fila
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _infoPill(Icons.scale_rounded, "$weight TN", isSpecial),
                      const SizedBox(width: 8),
                      _infoPill(Icons.inventory_2_rounded, cargoType, isSpecial),
                      const SizedBox(width: 8),
                      _infoPill(Icons.groups_rounded, "${order['estibadores'] ?? 0} AYUD.", isSpecial),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Detalles de Pisos
                Row(
                  children: [
                    _infoPill(Icons.layers_rounded, "PISO OR.: ${order['piso_origen'] ?? 0}", isSpecial),
                    const SizedBox(width: 10),
                    _infoPill(Icons.layers_rounded, "PISO DEST.: ${order['piso_destino'] ?? 0}", isSpecial),
                  ],
                ),

                const SizedBox(height: 30),

                // BOTÓN DE ACCIÓN: SLIDER
                ActionSlider(
                  label: "Desliza para aceptar",
                  onAction: onAccept,
                  baseColor: isSpecial ? Colors.white : AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String text, bool isSpecial) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSpecial ? Colors.white.withOpacity(0.12) : AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isSpecial ? Colors.white70 : AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isSpecial ? Colors.white : AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _getDestination(Map<String, dynamic> order) {
    final directions = order['direcciones'] as List?;
    if (directions != null) {
      final dest = directions.firstWhere(
        (d) => d['tipo_direccion'] == 'destino',
        orElse: () => null,
      );
      if (dest != null && dest['calle'] != null) {
        return dest['calle'];
      }
    }
    return "Cochabamba, Boliva";
  }
}
