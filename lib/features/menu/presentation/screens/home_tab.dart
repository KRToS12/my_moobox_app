import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/vehicle_repository.dart';
import 'package:my_moobox_app/features/menu/presentation/screens/maps.dart';
import 'package:my_moobox_app/features/shipping/presentation/fast_order_screen.dart';
import 'package:my_moobox_app/features/shipping/presentation/selection_order_screen.dart';

class HomeTab extends StatefulWidget {
  final String rol;
  const HomeTab({super.key, required this.rol});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  final VehicleRepository _vehicleRepo = VehicleRepository();
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Unificación total
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABECERA CON ACCIÓN DE MAPA
            _buildHeaderSection(),

            // 2. LISTA HORIZONTAL DE PUNTOS GUARDADOS (Nuevo)
            _buildSavedPointsSection(),

            const SizedBox(height: 25),

            // 3. BOTONES DE ACCIÓN PRINCIPAL
            _buildActionButtons(),

            const SizedBox(height: 35),

            // 4. CARRUSEL DE VEHÍCULOS
            _buildVehicleCarouselSection(),

            const SizedBox(height: 40),

            // 5. SECCIÓN MISIÓN / EXPERIENCIA
            _buildMissionSection(),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- CABECERA: Navegación al Mapa Gratuito ---
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.dividerGray.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "PUNTOS FRECUENTES",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack, // Negro ejecutivo
              letterSpacing: 1.5,
            ),
          ),
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

  // --- NUEVA SECCIÓN: Visualización de Sitios de Supabase ---
  Widget _buildSavedPointsSection() {
    return SizedBox(
      height: 100,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        // Filtramos por el ID del usuario actual
        future: _supabase.from('puntos_frecuentes').select().eq('id_usuario', _supabase.auth.currentUser!.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyPointsHint();
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildPointChip(snapshot.data![index]),
          );
        },
      ),
    );
  }

  Widget _buildPointChip(Map<String, dynamic> point) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            point['nombre_lugar'].toString().toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPointsHint() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 15),
      child: Text(
        "No tienes puntos guardados aún.",
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
    );
  }

  // --- COMPONENTES REUTILIZABLES ---

  Widget _buildActionCircle(IconData icon, {VoidCallback? onTap, bool small = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(small ? 8 : 10),
        decoration: const BoxDecoration(
          color: AppColors.accentCoral,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: small ? 16 : 22),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _actionButton(
            "Fast\nTransport", 
            Icons.bolt_outlined, 
            AppColors.accentCoral, // Identidad base
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FastOrderScreen())),
          ),
          const SizedBox(width: 15),
          _actionButton(
            "Por\nSelección", 
            Icons.grid_view_rounded, 
            AppColors.primaryBlue, // Azul corporativo
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectionOrderScreen())),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTE: Botón Individual Estilizado ---
  Widget _actionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Radio técnico de 16px
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter( // Fuente Inter para autoridad
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCarouselSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            "FLOTA DISPONIBLE", 
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textBlack, letterSpacing: 1.0),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _vehicleRepo.getActiveVehicles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              return PageView.builder(
                controller: _pageController,
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) => _buildVehicleCard(snapshot.data![index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> data) {
    final double toneladas = (data['capacidad_kg'] ?? 0) / 1000;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("CAPACIDAD MÁXIMA", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                Text("${toneladas.toStringAsFixed(1)} TN", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textBlack)),
                Text(data['clasificacion_vehiculo']?.toUpperCase() ?? 'CARGA GENERAL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const Spacer(),
                _buildActionCircle(Icons.arrow_forward_rounded, small: true),
              ],
            ),
          ),
          Expanded(flex: 4, child: _buildVehicleImage(data['foto_url'])),
        ],
      ),
    );
  }

  Widget _buildVehicleImage(String? url) {
    return url != null 
      ? Image.network(url, fit: BoxFit.contain)
      : const Icon(Icons.local_shipping_outlined, size: 55, color: AppColors.textBlack);
  }

  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LOGÍSTICA MOOBOX", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.warningYellow, letterSpacing: 2.5)),
                const SizedBox(height: 12),
                Text("Seguridad y\nEficiencia Total", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(height: 20),
                _buildMissionPoint("Monitoreo de carga 24/7"),
                _buildMissionPoint("Seguros integrados por viaje"),
              ],
            ),
            Positioned(bottom: 0, right: 0, child: Opacity(opacity: 1, child: Image.asset('assets/images/LOGOsf.png', height: 170))),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.warningYellow),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}