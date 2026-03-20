import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'maps_shipping.dart';

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
  final TextEditingController _commentController = TextEditingController(); // CONTROLADOR DE COMENTARIOS

  // --- 3. VARIABLES DE CÁLCULO Y ESTADO ---
  double _distanciaKm = 0.0;
  double _precioEstimado = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // SOLUCIÓN AL ERROR DEL SLIDER:
    // .clamp(1.0, 30.0) asegura que si llega un 0 o un valor nulo, el valor sea forzado a estar entre 1 y 30.
    _pesoTN = (widget.capacidadSugerida ?? 1.0).clamp(1.0, 30.0);
  }

  @override
  void dispose() {
    _commentController.dispose(); // Limpieza de memoria
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
            _buildStepTitle("1", "DEFINIR RUTA"),
            const SizedBox(height: 15),
            _buildRouteCard(),
            
            const SizedBox(height: 30),
            
            _buildStepTitle("2", "DETALLES DE CARGA"),
            const SizedBox(height: 15),
            _buildCargoCard(),

            const SizedBox(height: 30),

            _buildStepTitle("3", "SERVICIOS ADICIONALES"),
            const SizedBox(height: 15),
            _buildExtraServicesCard(),

            const SizedBox(height: 30),

            // --- NUEVA SECCIÓN: COMENTARIOS Y ESPECIFICACIONES ---
            _buildStepTitle("4", "ESPECIFICACIONES DE CARGA"),
            const SizedBox(height: 15),
            _buildCommentField(),

            // --- SECCIÓN DE COSTOS ---
            const SizedBox(height: 40),
            if (_distanciaKm > 0) ...[
              _buildStepTitle("5", "ANÁLISIS DE COSTOS MOOBOX"),
              const SizedBox(height: 15),
              _buildPriceSummaryCard(),
            ],

            const SizedBox(height: 40),
            _buildConfirmButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: CAMPO DE COMENTARIOS TÉCNICOS ---
  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Cambiado a blanco para contraste
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.dividerGray.withOpacity(0.5)),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textBlack),
            decoration: InputDecoration(
              hintText: "Ej: Llevo 50 cajas de cerámica frágil, dimensiones 40x40...",
              hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.6)),
              contentPadding: const EdgeInsets.all(15),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildWarningBox("RECOMENDACIÓN: Indica si la carga es frágil o voluminosa."),
      ],
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

      // Inserción en la tabla ofertas_pedido incluyendo el id_vehiculo opcional
      await Supabase.instance.client.from('ofertas_pedido').insert({
        'id_usuario': user.id,
        'monto_ofertado': _precioEstimado,
        'comentario_oferta': _commentController.text,
        'estado_oferta': 'abierta',
        'id_vehiculo': widget.idVehiculoPreseleccionado, // Aquí se guarda el ID si existe
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
        'precio': _precioEstimado, // Mapeamos también a la columna precio si es necesario
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

  Widget _buildStepTitle(String step, String title) {
    return Row(
      children: [
        CircleAvatar(radius: 12, backgroundColor: AppColors.textBlack, child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.dividerGray.withOpacity(0.5))),
      child: Column(
        children: [
          _locationSelector(Icons.radio_button_checked, AppColors.primaryBlue, "RECOJO", _origen, () => _abrirMapa("origen")),
          Padding(padding: const EdgeInsets.only(left: 11), child: Align(alignment: Alignment.centerLeft, child: Container(width: 1, height: 25, color: AppColors.dividerGray))),
          _locationSelector(Icons.location_on, AppColors.accentCoral, "ENTREGA", _destino, () => _abrirMapa("destino")),
        ],
      ),
    );
  }

  Widget _locationSelector(IconData icon, Color color, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textBlack), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.dividerGray),
        ],
      ),
    );
  }

  Widget _buildCargoCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cargoInfoItem("PESO", "${_pesoTN.toStringAsFixed(1)} TN"),
              _cargoInfoItem("CATEGORÍA", _tipoCarga.toUpperCase()),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: _pesoTN, min: 1.0, max: 30.0,
            activeColor: AppColors.warningYellow, inactiveColor: Colors.white24,
            onChanged: (val) {
              setState(() => _pesoTN = val);
              _calcularPrecio();
            },
          ),
        ],
      ),
    );
  }

  Widget _cargoInfoItem(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w800)),
      Text(value, style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900)),
    ]);
  }

  Widget _buildExtraServicesCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.dividerGray.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _counterRow("Ayudantes", _ayudantes, (val) { setState(() => _ayudantes = val < 0 ? 0 : val); _calcularPrecio(); }),
          _buildSmartRecommendation(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: AppColors.dividerGray)),
          _counterRow("Pisos Origen", _pisosOrigen, (val) { setState(() => _pisosOrigen = val < 0 ? 0 : val); _calcularPrecio(); }),
          const SizedBox(height: 10),
          _counterRow("Pisos Destino", _pisosDestino, (val) { setState(() => _pisosDestino = val < 0 ? 0 : val); _calcularPrecio(); }),
        ],
      ),
    );
  }

  Widget _buildSmartRecommendation() {
    String rec = "Recomendado: ";
    if (_pesoTN <= 3) rec += "1 ayudante.";
    else if (_pesoTN <= 10) rec += "2-3 ayudantes.";
    else rec += "4+ ayudantes.";

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(rec, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryBlue))),
      ]),
    );
  }

  Widget _buildPriceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 15)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("RESUMEN DE TARIFA", style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900)),
              Text("${_distanciaKm.toStringAsFixed(1)} KM", style: const TextStyle(color: AppColors.warningYellow, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(_precioEstimado.toStringAsFixed(2), style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const Padding(padding: EdgeInsets.only(left: 8, bottom: 6), child: Text("BOB", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          _priceDetailRow("Combustible Diesel", "Tarifa: 9.8 BOB/L"),
          _priceDetailRow("Mano de Obra", "Ajustada por ${_pesoTN.toInt()} TN"),
        ],
      ),
    );
  }

  Widget _priceDetailRow(String label, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
          Text(detail, style: GoogleFonts.inter(color: AppColors.warningYellow, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
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

  Widget _counterRow(String label, int value, Function(int) onChanged) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
      Row(children: [
        _circleButton(Icons.remove, () => onChanged(value - 1)),
        SizedBox(width: 35, child: Center(child: Text("$value", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900)))),
        _circleButton(Icons.add, () => onChanged(value + 1)),
      ]),
    ]);
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.dividerGray)), child: Icon(icon, size: 16, color: AppColors.primaryBlue)));
  }

  Widget _buildWarningBox(String text) {
    return Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.warningYellow.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Row(children: [
      const Icon(Icons.info_outline, size: 12, color: AppColors.warningYellow),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
    ]));
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: _isSubmitting ? null : _crearPedidoFast,
        child: _isSubmitting 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text("PUBLICAR SOLICITUD", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textBlack), onPressed: () => Navigator.pop(context)), title: Text("FAST TRANSPORT", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)));
  }
}