import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/features/shipping/presentation/fast_order_screen.dart';
import '../../../../data/repositories/vehicle_repository.dart';
import 'package:my_moobox_app/features/menu/presentation/screens/maps.dart';
import 'package:my_moobox_app/features/shipping/presentation/selection_order_screen.dart';

class HomeTab extends StatefulWidget {
  final String rol;
  const HomeTab({super.key, required this.rol});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSavedPointsRealtime(),
            const SizedBox(height: 25),
            _buildActionButtons(),
            const SizedBox(height: 35),
            _buildVehicleCarouselRealtime(),
            const SizedBox(height: 40),
            _buildMissionBanner(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- 1. CABECERA ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.dividerGray.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionTitle("PUNTOS FRECUENTES"),
          _buildActionCircle(
            Icons.add,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SelectorUbicacionGratuito()),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. PUNTOS GUARDADOS (REALTIME) ---
  Widget _buildSavedPointsRealtime() {
    final userId = _supabase.auth.currentUser?.id;
    return SizedBox(
      height: 90,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('puntos_frecuentes')
            .stream(primaryKey: ['id_punto'])
            .eq('id_usuario', userId ?? '')
            .order('created_at'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyHint("No hay puntos guardados.");

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) => _buildPointChip(snapshot.data![i]),
          );
        },
      ),
    );
  }

  Widget _buildPointChip(Map<String, dynamic> point) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Center(
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              point['nombre_lugar'].toString().toUpperCase(),
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textBlack),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. BOTONES DE ACCIÓN ---
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _actionButton("Fast\nTransport", Icons.bolt_outlined, AppColors.accentCoral, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FastOrderScreen(capacidadSugerida: 0, idVehiculoPreseleccionado: null,)))),
          const SizedBox(width: 15),
          _actionButton("Por\nSelección", Icons.grid_view_rounded, AppColors.primaryBlue, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectionOrderScreen()))),
        ],
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, Color color, VoidCallback onTap) {
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
// --- 4. CARRUSEL DE VEHÍCULOS (REALTIME) ---
  Widget _buildVehicleCarouselRealtime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25), 
          child: _sectionTitle("FLOTA DISPONIBLE")
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 225, // Altura óptima para evitar cortes
          child: StreamBuilder<List<Map<String, dynamic>>>(
            // Cambiado a 'vehiculo' según tu esquema de base de datos
            stream: _supabase.from('vehiculos').stream(primaryKey: ['id_vehiculo']).order('capacidad_kg'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyHint("No hay unidades operativas disponibles.");
              }

              return PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _buildVehicleCard(snapshot.data![index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> data) {
    // Conversión segura de peso a toneladas
    final double capacidadKg = double.tryParse(data['capacidad_kg']?.toString() ?? '0') ?? 0;
    final double toneladas = capacidadKg / 1000;
    final String matricula = data['matricula']?.toString().toUpperCase() ?? "S/P";
    final String clasificacion = data['clasificacion_vehiculo']?.toUpperCase() ?? 'GENERAL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: AppColors.textBlack.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          // COLUMNA IZQUIERDA: ESPECIFICACIONES RÁPIDAS
          Expanded(
            flex: 6,
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
                Text("CAPACIDAD", style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                Text("${toneladas.toStringAsFixed(1)} TN", 
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textBlack, height: 1.1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 10, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text("PLACA: $matricula", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                // BOTÓN DE ACCIÓN INDUSTRIAL
                InkWell(
                  onTap: () => _mostrarDetallesVehiculo(data),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("MÁS DETALLES", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(width: 6),
                        const Icon(Icons.add_circle_outline, size: 12, color: AppColors.warningYellow),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // IMAGEN DEL VEHÍCULO
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildVehicleImage(data['foto_url']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL DE CONVERSIÓN DIRECTA ---
  void _mostrarDetallesVehiculo(Map<String, dynamic> data) {
    final double capTN = (double.tryParse(data['capacidad_kg']?.toString() ?? '0') ?? 0) / 1000;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("FICHA TÉCNICA MOOBOX"),
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
                    child: Text("CANCELAR", style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 12)),
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
          Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
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
    return const Icon(Icons.local_shipping_outlined, size: 40, color: AppColors.dividerGray);
  }
  return Image.network(url, fit: BoxFit.cover);
}

// --- 5. BANNER MISIÓN ---
  Widget _buildMissionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.textBlack, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.textBlack.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))]
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LOGÍSTICA MOOBOX", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.warningYellow, letterSpacing: 2.0)),
                const SizedBox(height: 12),
                Text("Seguridad y\nEficiencia Total", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(height: 20),
                _missionItem("Monitoreo de carga 24/7"),
                _missionItem("Seguros integrados por viaje"),
              ],
            ),
            Positioned(bottom: -15, right: -15, child: Opacity(opacity: 0.9, child: Image.asset('assets/images/LOGOsf.png', height: 130))),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _sectionTitle(String text) => Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: 1.5));

  Widget _missionItem(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.warningYellow),
      const SizedBox(width: 8),
      Text(text, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildEmptyHint(String text) => Padding(padding: const EdgeInsets.only(left: 25, top: 15), 
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)));

  Widget _buildActionCircle(IconData icon, {VoidCallback? onTap, bool small = false}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: EdgeInsets.all(small ? 6 : 10),
        decoration: const BoxDecoration(color: AppColors.accentCoral, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: small ? 14 : 20),
      ),
    );
  }
}