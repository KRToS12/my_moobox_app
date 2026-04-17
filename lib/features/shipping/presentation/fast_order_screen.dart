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
import '../domain/pricing_engine.dart';


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
  double? _precioManual;
  bool _isSubmitting = false;
  bool _isLoadingPrice = false;

  final PricingEngine _pricingEngine = PricingEngine();


  @override
  void initState() {
    super.initState();
    _pesoTN = (widget.capacidadSugerida ?? 1.0).clamp(1.0, 30.0);
    _initPricing();
  }

  Future<void> _initPricing() async {
    await _pricingEngine.fetchConfig();
    if (mounted) _calcularPrecio();
  }


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              pinned: false,
              centerTitle: true,
              automaticallyImplyLeading: false, // Quita la flecha
              title: Text(
                "PREPARAR ENVÍO", 
                style: GoogleFonts.inter(
                  fontSize: 14, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 2.0,
                  color: AppColors.primaryBlue,
                )
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader("1", "DEFINIR RUTA ENVÍO"),
                  FastOrderRouteCard(
                    origen: _origen,
                    destino: _destino,
                    onTapOrigen: () => _abrirMapa("origen"),
                    onTapDestino: () => _abrirMapa("destino"),
                  ),
                  
                  const SizedBox(height: 35),
                  _buildSectionHeader("2", "DETALLES TÉCNICOS DE CARGA"),
                  FastOrderCargoCard(
                    pesoTN: _pesoTN,
                    tipoCarga: _tipoCarga,
                    isLocked: widget.idVehiculoPreseleccionado != null,
                    onPesoChanged: (val) {
                      setState(() => _pesoTN = val);
                      _precioManual = null; // Reset manual price if tonnage changes
                      _calcularPrecio();
                    },
                  ),
  
                  const SizedBox(height: 35),
                  _buildSectionHeader("3", "LOGÍSTICA Y SERVICIOS"),
                  FastOrderServicesCard(
                    ayudantes: _ayudantes,
                    pisosOrigen: _pisosOrigen,
                    pisosDestino: _pisosDestino,
                    pesoTN: _pesoTN,
                    onAyudantesChanged: (val) {
                      setState(() => _ayudantes = val < 0 ? 0 : val);
                      _precioManual = null;
                      _calcularPrecio();
                    },
                    onPisosOrigenChanged: (val) {
                      setState(() => _pisosOrigen = val < 0 ? 0 : val);
                      _precioManual = null;
                      _calcularPrecio();
                    },
                    onPisosDestinoChanged: (val) {
                      setState(() => _pisosDestino = val < 0 ? 0 : val);
                      _precioManual = null;
                      _calcularPrecio();
                    },
                  ),
  
                  const SizedBox(height: 35),
                  _buildSectionHeader("4", "REQUERIMIENTOS ESPECIALES"),
                  FastOrderCommentField(commentController: _commentController),
  
                  if (_distanciaKm > 0) ...[
                    const SizedBox(height: 40),
                    _buildSectionHeader("5", "ANÁLISIS DE COSTOS MOOBOX"),
                    FastOrderPriceSummary(
                      distanciaKm: _distanciaKm,
                      precioEstimado: _precioManual ?? _precioEstimado,
                      pesoTN: _pesoTN,
                      isLoading: _isLoadingPrice,
                      onPriceChanged: _showPriceInputDialog,
                    ),

                  ],
  
                  const SizedBox(height: 50),
                  FastOrderConfirmButton(
                    isSubmitting: _isSubmitting,
                    onPressed: _crearPedidoFast,
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String step, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, left: 4),
      child: FastOrderStepTitle(step: step, title: title),
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

      // 1. CREAR LA OFERTA Y OBTENER SU ID
      final Map<String, dynamic> offerResponse = await Supabase.instance.client.from('ofertas_pedido').insert({
        'id_usuario': user.id,
        'monto_ofertado': _precioManual ?? _precioEstimado,
        'comentario_oferta': _commentController.text,
        'estado_oferta': 'abierta',
        'id_vehiculo': widget.idVehiculoPreseleccionado,
        'estibadores': _ayudantes,
        'piso_origen': _pisosOrigen,
        'piso_destino': _pisosDestino,
        'peso_carga': _pesoTN,
        'tipo_carga': _tipoCarga,
        'precio': _precioManual ?? _precioEstimado, 
      }).select('id_oferta').single();

      final String idOferta = offerResponse['id_oferta'];

      // 2. CREAR LAS DIRECCIONES RELACIONADAS
      await Supabase.instance.client.from('direcciones').insert([
        {
          'id_oferta': idOferta,
          'tipo_direccion': 'origen',
          'calle': _origen,
          'ciudad': 'Cochabamba',
          'latitud': _posOrigen!.latitude,
          'longitud': _posOrigen!.longitude,
        },
        {
          'id_oferta': idOferta,
          'tipo_direccion': 'destino',
          'calle': _destino,
          'ciudad': 'Cochabamba',
          'latitud': _posDestino!.latitude,
          'longitud': _posDestino!.longitude,
        }
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("¡Flete publicado con éxito!"), 
          backgroundColor: AppColors.primaryBlue
        ));
        Navigator.pop(context, true);
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
    if (_posOrigen == null || _posDestino == null || _distanciaKm == 0) return;

    final double total = _pricingEngine.calcularCotizacion(
      distanciaKm: _distanciaKm,
      volumenTon: _pesoTN,
      numPisosTotal: _pisosOrigen + _pisosDestino,
      numEstibadores: _ayudantes,
    );

    setState(() {
      _precioEstimado = total;
    });
  }

  void _showPriceInputDialog() {
    final controller = TextEditingController(text: (_precioManual ?? _precioEstimado).toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.textBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "OFERTAR PRECIO", 
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ingresa el monto que deseas ofertar por este servicio.",
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: "BOB",
                suffixStyle: const TextStyle(color: AppColors.primaryBlue),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: GoogleFonts.inter(color: Colors.white54, fontWeight: FontWeight.w800)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                setState(() => _precioManual = newPrice);
                Navigator.pop(context);
              }
            },
            child: Text("CONFIRMAR", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }


  void _abrirMapa(String tipo) async {
    final dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const MapsShippingScreen()));
    if (result != null && mounted) {
      LatLng? newPos;
      setState(() {
        if (tipo == "origen") {
          _origen = result['address'];
          _posOrigen = LatLng(result['lat'], result['lng']);
          newPos = _posOrigen;
        } else {
          _destino = result['address'];
          _posDestino = LatLng(result['lat'], result['lng']);
          newPos = _posDestino;
        }
      });

      // Si tenemos ambos puntos, calculamos primero una distancia lineal de respaldo
      if (_posOrigen != null && _posDestino != null) {
        // Cálculo síncrono de respaldo (distancia lineal)
        const Distance distanceCalc = Distance();
        double linearDistance = distanceCalc.as(LengthUnit.Kilometer, _posOrigen!, _posDestino!);
        
        setState(() {
          _distanciaKm = linearDistance;
          _isLoadingPrice = true;
        });
        _calcularPrecio();

        // Luego intentamos refinar con la distancia real de ORS
        try {
          final double realDistance = await _pricingEngine.getRouteDistance(_posOrigen!, _posDestino!);
          if (mounted && realDistance > 0) {
            setState(() {
              _distanciaKm = realDistance;
            });
            _calcularPrecio();
          }
        } catch (e) {
          debugPrint("Error refinando distancia con ORS: $e");
        } finally {
          if (mounted) setState(() => _isLoadingPrice = false);
        }
      }
    }
  }
}
  