import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/features/shipping/presentation/fast_order_screen.dart';
import 'home_section_title.dart';

class AvailableFleetCarousel extends StatefulWidget {
  const AvailableFleetCarousel({super.key});

  @override
  State<AvailableFleetCarousel> createState() => _AvailableFleetCarouselState();
}

class _AvailableFleetCarouselState extends State<AvailableFleetCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25), 
          child: HomeSectionTitle("FLOTA DISPONIBLE")
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 225, // Altura óptima para evitar cortes
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase.from('vehiculos').stream(primaryKey: ['id_vehiculo']).order('capacidad_kg'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(left: 25, top: 15), 
                  child: Text("No hay unidades operativas disponibles.", style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontWeight: FontWeight.w600))
                );
              }

              return PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _buildVehicleCard(context, snapshot.data![index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> data) {
    // Conversión segura de peso a toneladas
    final double capacidadKg = double.tryParse(data['capacidad_kg']?.toString() ?? '0') ?? 0;
    final double toneladas = capacidadKg / 1000;
    final String matricula = data['matricula']?.toString().toUpperCase() ?? "S/P";
    final String clasificacion = data['clasificacion_vehiculo']?.toUpperCase() ?? 'GENERAL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          // COLUMNA IZQUIERDA: ESPECIFICACIONES RÁPIDAS
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    clasificacion,
                    style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text("CAPACIDAD", style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                Text("${toneladas.toStringAsFixed(1)} TN", 
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.badge_outlined, size: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text("PLACA: $matricula", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                  ],
                ),
                const Spacer(),
                // BOTÓN DE ACCIÓN INDUSTRIAL
                InkWell(
                  onTap: () => _mostrarDetallesVehiculo(context, data),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("VER UNIDAD", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(width: 6),
                        const Icon(Icons.add_circle_outline, size: 12, color: AppColors.warningYellow),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // IMAGEN DEL VEHÍCULO DE EXHIBICIÓN
          Expanded(
            flex: 6,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // FOCO DE SALA DE EXHIBICIÓN
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                // SOMBRA EN EL PISO
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: 90,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, spreadRadius: 2)
                      ],
                    ),
                  ),
                ),
                // EL VEHÍCULO CON ESCALA "POP-OUT"
                Transform.scale(
                  scale: 1.3,
                  child: _buildVehicleImage(data['foto_url']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL DE CONVERSIÓN DIRECTA ---
  void _mostrarDetallesVehiculo(BuildContext context, Map<String, dynamic> data) {
    final double capTN = (double.tryParse(data['capacidad_kg']?.toString() ?? '0') ?? 0) / 1000;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HomeSectionTitle("FICHA TÉCNICA MOOBOX"),
                _buildStatusBadge(data['estado_servicio'] ?? true),
              ],
            ),
            const Divider(height: 30),
            if (data['foto_dimensiones_url'] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(data['foto_dimensiones_url'], height: 160, width: double.infinity, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
            ],
            _buildDetailRow("MATRÍCULA / PLACA", data['matricula'] ?? "PENDIENTE"),
            _buildDetailRow("CAPACIDAD REGISTRADA", "${data['capacidad_kg']} KG"),
            _buildDetailRow("TIPO DE UNIDAD", data['clasificacion_vehiculo']?.toUpperCase() ?? "CARGA GENERAL"),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("CANCELAR", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navegación con parámetros corregidos para FastOrderScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FastOrderScreen(
                            idVehiculoPreseleccionado: data['id_vehiculo'],
                            capacidadSugerida: capTN >= 1.0 ? capTN : 1.0,
                          ),
                        ),
                      );
                    },
                    child: Text("SOLICITAR ESTA UNIDAD", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool activo) {
    final color = activo ? AppColors.statusSuccess : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 6),
          Text(activo ? "EN LÍNEA" : "OFFLINE", style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildVehicleImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).scaffoldBackgroundColor),
        child: Icon(Icons.local_shipping_outlined, size: 40, color: Theme.of(context).dividerColor)
      );
    }
    return Image.network(url, fit: BoxFit.contain);
  }
}
