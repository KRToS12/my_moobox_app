import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'maps_shipping.dart';

import 'widgets/fast_order/fast_order_step_title.dart';
import 'widgets/fast_order/fast_order_route_card.dart';
import 'widgets/fast_order/fast_order_cargo_card.dart';
import 'widgets/fast_order/fast_order_services_card.dart';
import 'widgets/fast_order/fast_order_comment_field.dart';
import 'widgets/fast_order/fast_order_price_summary.dart';
import 'widgets/fast_order/fast_order_confirm_button.dart';

class FastOrderScreen extends StatefulWidget {
  // Aseguramos que recibimos los datos del vehículo correctamente
  final double? capacidadSugerida;
  final String? idVehiculoPreseleccionado;

  const FastOrderScreen({
    super.key, 
    this.capacidadSugerida, 
    this.idVehiculoPreseleccionado
  });

  @override
  State<FastOrderScreen> createState() => _FastOrderScreenState();
}

class _FastOrderScreenState extends State<FastOrderScreen> {
  // --- 1. ESTADO DE LA SOLICITUD ---
  String _origen = "Seleccionar origen";
  String _destino = "Seleccionar destino";
  String _tipoCarga = "General";
  
  // CORRECCIÓN: Usamos 'late' para inicializarlo con seguridad en el initState
  late double _pesoTN; 
  
  LatLng? _posOrigen;
  LatLng? _posDestino;

  // --- 2. VARIABLES DE SERVICIO Y COMENTARIOS ---
  int _ayudantes = 0;
  int _pisosOrigen = 0;
  int _pisosDestino = 0;
  final TextEditingController _commentController = TextEditingController();

  // --- 3. VARIABLES DE CÁLCULO Y ESTADO ---
  double _distanciaKm = 0.0;
  double _precioEstimado = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pesoTN = (widget.capacidadSugerida ?? 1.0).clamp(1.0, 30.0);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FastOrderStepTitle(step: "1", title: "DEFINIR RUTA"),
            const SizedBox(height: 15),
            FastOrderRouteCard(
              origen: _origen,
              destino: _destino,
              onTapOrigen: () => _abrirMapa("origen"),
              onTapDestino: () => _abrirMapa("destino"),
            ),
            
            const SizedBox(height: 30),
            
            const FastOrderStepTitle(step: "2", title: "DETALLES DE CARGA"),
            const SizedBox(height: 15),
            FastOrderCargoCard(
              pesoTN: _pesoTN,
              tipoCarga: _tipoCarga,
              onPesoChanged: (val) {
                setState(() => _pesoTN = val);
                _calcularPrecio();
              },
            ),

            const SizedBox(height: 30),

            const FastOrderStepTitle(step: "3", title: "SERVICIOS ADICIONALES"),
            const SizedBox(height: 15),
            FastOrderServicesCard(
              ayudantes: _ayudantes,
              pisosOrigen: _pisosOrigen,
              pisosDestino: _pisosDestino,
              pesoTN: _pesoTN,
              onAyudantesChanged: (val) {
                setState(() => _ayudantes = val < 0 ? 0 : val);
                _calcularPrecio();
              },
              onPisosOrigenChanged: (val) {
                setState(() => _pisosOrigen = val < 0 ? 0 : val);
                _calcularPrecio();
              },
              onPisosDestinoChanged: (val) {
                setState(() => _pisosDestino = val < 0 ? 0 : val);
                _calcularPrecio();
              },
            ),

            const SizedBox(height: 30),

            const FastOrderStepTitle(step: "4", title: "ESPECIFICACIONES DE CARGA"),
            const SizedBox(height: 15),
            FastOrderCommentField(commentController: _commentController),

            const SizedBox(height: 40),
            if (_distanciaKm > 0) ...[
              const FastOrderStepTitle(step: "5", title: "ANÁLISIS DE COSTOS MOOBOX"),
              const SizedBox(height: 15),
              FastOrderPriceSummary(
                distanciaKm: _distanciaKm,
                precioEstimado: _precioEstimado,
                pesoTN: _pesoTN,
              ),
            ],

            const SizedBox(height: 40),
            FastOrderConfirmButton(
              isSubmitting: _isSubmitting,
              onPressed: _crearPedidoFast,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE ENVÍO A SUPABASE ACTUALIZADA ---
  void _crearPedidoFast() async {
    if (_posOrigen == null || _posDestino == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes definir la ruta completa.")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Sesión no válida.");

      await Supabase.instance.client.from('ofertas_pedido').insert({
        'id_usuario': user.id,
        'monto_ofertado': _precioEstimado,
        'comentario_oferta': _commentController.text,
        'estado_oferta': 'abierta',
        'id_vehiculo': widget.idVehiculoPreseleccionado,
        'estibadores': _ayudantes,
        'piso_origen': _pisosOrigen,
        'piso_destino': _pisosDestino,
        'lat_origen': _posOrigen!.latitude,
        'lng_origen': _posOrigen!.longitude,
        'lat_destino': _posDestino!.latitude,
        'lng_destino': _posDestino!.longitude,
        'direccion_origen': _origen,
        'direccion_destino': _destino,
        'peso_carga': _pesoTN,
        'tipo_carga': _tipoCarga,
        'precio': _precioEstimado, 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("¡Flete publicado con éxito!"), 
          backgroundColor: AppColors.primaryBlue
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${e.toString()}"), 
          backgroundColor: AppColors.error
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _calcularPrecio() {
    if (_posOrigen == null || _posDestino == null) return;
    const Distance distance = Distance();
    _distanciaKm = distance.as(LengthUnit.Kilometer, _posOrigen!, _posDestino!);

    double dieselPrice = 9.8;
    double eficiencia = _pesoTN <= 5 ? 8.5 : (_pesoTN <= 15 ? 5.5 : 3.5);
    double costoCombustible = (_distanciaKm / eficiencia) * dieselPrice;
    double tarifaAyudante = _pesoTN <= 5 ? 50.0 : (_pesoTN <= 15 ? 80.0 : 120.0);
    double costoAyudantes = _ayudantes * tarifaAyudante;
    double costoVehiculo = 60.0 + (_pesoTN * 25.0);
    double costoPisos = (_pisosOrigen + _pisosDestino) * 30.0;

    setState(() {
      _precioEstimado = costoCombustible + costoVehiculo + costoAyudantes + costoPisos;
    });
  }

  void _abrirMapa(String tipo) async {
    final dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const MapsShippingScreen()));
    if (result != null && mounted) {
      setState(() {
        if (tipo == "origen") {
          _origen = result['address'];
          _posOrigen = LatLng(result['lat'], result['lng']);
        } else {
          _destino = result['address'];
          _posDestino = LatLng(result['lat'], result['lng']);
        }
        _calcularPrecio();
      });
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, 
      elevation: 0, 
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textBlack), onPressed: () => Navigator.pop(context)), 
      title: Text("FAST TRANSPORT", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5))
    );
  }
}