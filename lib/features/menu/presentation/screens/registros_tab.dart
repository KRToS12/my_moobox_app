import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class RegistrosTab extends StatefulWidget {
  const RegistrosTab({super.key});

  @override
  State<RegistrosTab> createState() => _RegistrosTabState();
}

class _RegistrosTabState extends State<RegistrosTab> {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _obtenerActividadUnificada() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final respuestas = await Future.wait([
        _supabase.from('pedidos').select().eq('id_usuario', user.id),
        _supabase.from('ofertas_pedido').select().eq('id_usuario', user.id),
      ]);

      final List<Map<String, dynamic>> pedidos = List<Map<String, dynamic>>.from(respuestas[0]);
      final List<Map<String, dynamic>> ofertas = List<Map<String, dynamic>>.from(respuestas[1]);

      final listaUnificada = [
        ...pedidos.map((e) => {...e, 'tipo_registro': 'pedido'}),
        ...ofertas.map((e) => {...e, 'tipo_registro': 'oferta'}),
      ];

      listaUnificada.sort((a, b) {
        final fechaA = DateTime.tryParse(a['created_at'] ?? "") ?? DateTime(2000);
        final fechaB = DateTime.tryParse(b['created_at'] ?? "") ?? DateTime(2000);
        return fechaB.compareTo(fechaA);
      });

      return listaUnificada;
    } catch (e) {
      debugPrint("Error Moobox: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerActividadUnificada(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10), 
            itemBuilder: (context, i) => _buildStealthCard(snapshot.data![i]),
          );
        },
      ),
    );
  }

  // --- UI: DISEÑO STEALTH (GRIS, SIN UBICACIONES NI IDS) ---
  Widget _buildStealthCard(Map<String, dynamic> item) {
    final bool esPedido = item['tipo_registro'] == 'pedido';
    
    final String monto = esPedido 
        ? (item['monto']?.toString() ?? "0") 
        : (item['monto_ofertado']?.toString() ?? "0");

    final String descripcion = esPedido 
        ? (item['descripcion'] ?? "Flete") 
        : (item['tipo_carga'] ?? "Oferta");

    final String estado = esPedido 
        ? (item['estado'] ?? 'pendiente') 
        : (item['estado_oferta'] ?? 'abierta');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        // Tono más gris para que no se funda con el fondo blanco/claro
        color: const Color.fromARGB(255, 214, 214, 214), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          // LADO IZQUIERDO: TIPO Y DESCRIPCIÓN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esPedido ? "PEDIDO" : "OFERTA",
                  style: GoogleFonts.inter(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: esPedido ? AppColors.primaryBlue : AppColors.warningYellow,
                    letterSpacing: 1.0
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                ),
              ],
            ),
          ),

          // CENTRO: ESTADO SIMPLIFICADO
          _buildStatusDot(estado),

          const SizedBox(width: 20),

          // LADO DERECHO: PRECIO
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                monto,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textBlack),
              ),
              Text(
                "BOB",
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String status) {
    Color color = Colors.blueGrey;
    if (status.contains('abierta') || status.contains('pendiente')) color = AppColors.primaryBlue;
    if (status.contains('aceptada') || status.contains('completado')) color = Colors.green;
    if (status.contains('rechazada')) color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "HISTORIAL VACÍO",
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.dividerGray, letterSpacing: 2.0),
      ),
    );
  }
}