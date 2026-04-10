import 'dart:async';
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
  
  List<Map<String, dynamic>> _pedidos = [];
  List<Map<String, dynamic>> _ofertas = [];
  bool _isLoading = true;

  StreamSubscription? _subPedidos;
  StreamSubscription? _subOfertas;

  @override
  void initState() {
    super.initState();
    _iniciarSuscripcionesRealtime();
  }

  void _iniciarSuscripcionesRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint("Moobox Error: No hay usuario autenticado para registros");
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    debugPrint("Moobox Sync: Iniciando streams para usuario ${user.id}");

    _subPedidos = _supabase
        .from('pedidos')
        .stream(primaryKey: ['id_pedido'])
        .eq('id_usuario', user.id)
        .listen((data) {
          debugPrint("Moobox Sync: Recibidos ${data.length} pedidos");
          if (mounted) {
            setState(() {
              _pedidos = data.map((e) => {...e, 'tipo_registro': 'pedido'}).toList();
              _isLoading = false;
            });
          }
        }, onError: (error) {
          debugPrint("Moobox Error Stream Pedidos: $error");
          if (mounted) setState(() => _isLoading = false);
        });

    _subOfertas = _supabase
        .from('ofertas_pedido')
        .stream(primaryKey: ['id_oferta'])
        .eq('id_usuario', user.id)
        .listen((data) {
          debugPrint("Moobox Sync: Recibidas ${data.length} ofertas");
          if (mounted) {
            setState(() {
              _ofertas = data.map((e) => {...e, 'tipo_registro': 'oferta'}).toList();
              _isLoading = false;
            });
          }
        }, onError: (error) {
          debugPrint("Moobox Error Stream Ofertas: $error");
          if (mounted) setState(() => _isLoading = false);
        });
  }

  List<Map<String, dynamic>> get _listaCombinada {
    final lista = [..._pedidos, ..._ofertas];
    lista.sort((a, b) {
      final fechaA = DateTime.tryParse(a['fecha_solicitud'] ?? a['created_at'] ?? "") ?? DateTime(2000);
      final fechaB = DateTime.tryParse(b['fecha_solicitud'] ?? b['created_at'] ?? "") ?? DateTime(2000);
      return fechaB.compareTo(fechaA);
    });
    return lista;
  }

  @override
  void dispose() {
    _subPedidos?.cancel();
    _subOfertas?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registros = _listaCombinada;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
        : RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () async {
              setState(() => _isLoading = true);
              _subPedidos?.cancel();
              _subOfertas?.cancel();
              _iniciarSuscripcionesRealtime();
            },
            child: registros.isEmpty 
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                    _buildEmptyState(),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  itemCount: registros.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12), 
                  itemBuilder: (context, i) => _buildStealthCard(registros[i]),
                ),
          ),
    );
  }

  // --- UI: TARJETA PRINCIPAL (SLIM DESIGN) ---
  Widget _buildStealthCard(Map<String, dynamic> item) {
    final bool esPedido = item['tipo_registro'] == 'pedido';
    
    // Mapeo dinámico
    final String monto = esPedido 
        ? (item['costo_cotizado']?.toString() ?? "0") 
        : (item['monto_ofertado']?.toString() ?? "0");

    final String estado = esPedido 
        ? (item['estado_pedido'] ?? 'pendiente') 
        : (item['estado_oferta'] ?? 'abierta');

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _mostrarDetalles(item), 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerGray.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        esPedido ? Icons.assignment_rounded : Icons.local_offer_rounded,
                        size: 12,
                        color: esPedido ? AppColors.primaryBlue : AppColors.warningYellow,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        esPedido ? "SOLICITUD" : "OFERTA",
                        style: GoogleFonts.inter(
                          fontSize: 9, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1.2,
                          color: AppColors.textBlack.withOpacity(0.7)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBadgeEstado(estado),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      monto,
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textBlack),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "BOB",
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textBlack.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  // --- UI: MODAL CON TODOS LOS DATOS TÉCNICOS ---
  void _mostrarDetalles(Map<String, dynamic> item) {
    final bool esPedido = item['tipo_registro'] == 'pedido';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalHeader(esPedido, item),
              const Divider(height: 40, thickness: 0.5),
              
              Text("ESPECIFICACIONES DE CARGA", 
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.0)),
              const SizedBox(height: 20),
              
              _infoDetailRow("TIPO DE CARGA", item['tipo_carga'] ?? "Carga General"),
              if (!esPedido) ...[
                _infoDetailRow("ORIGEN", item['direccion_origen'] ?? "Punto de carga detectado"),
                _infoDetailRow("DESTINO", item['direccion_destino'] ?? "Punto de entrega detectado"),
              ],
              
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniDetailCard(Icons.groups_rounded, "ESTIBADORES", "${item['estibadores'] ?? 0}"),
                  _miniDetailCard(Icons.layers_rounded, "PISOS ORIGEN", "${item['piso_origen'] ?? 0}"),
                  _miniDetailCard(Icons.layers_rounded, "PISOS DESTINO", "${item['piso_destino'] ?? 0}"),
                ],
              ),

              if (!esPedido && item['comentario_oferta'] != null && item['comentario_oferta'].toString().isNotEmpty) ...[
                const SizedBox(height: 25),
                Text("COMENTARIO DEL TRANSPORTISTA", 
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                  child: Text(item['comentario_oferta'], style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
                ),
              ],
              
              const SizedBox(height: 35),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---

  Widget _buildModalHeader(bool esPedido, Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(esPedido ? "DETALLE DEL PEDIDO" : "DETALLE DE LA OFERTA", 
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text("REF ID: ${esPedido ? item['id_pedido'].toString().substring(0,8) : item['id_oferta'].toString().substring(0,8)}".toUpperCase(),
                style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(8)),
          child: Text(
            "${esPedido ? item['costo_cotizado'] : item['monto_ofertado']} BOB",
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        )
      ],
    );
  }

  Widget _buildBadgeEstado(String status) {
    Color c = AppColors.primaryBlue;
    if(status.contains('aceptada') || status.contains('completado')) c = Colors.green;
    if(status.contains('rechazada')) c = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: c)),
    );
  }

  Widget _infoDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
        ],
      ),
    );
  }

  Widget _miniDetailCard(IconData icon, String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.dividerGray.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textBlack)),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.textBlack, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => Navigator.pop(context),
        child: Text("CERRAR DETALLES", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("SIN MOVIMIENTOS RECIENTES", 
          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.dividerGray, letterSpacing: 2.0)),
    );
  }
}