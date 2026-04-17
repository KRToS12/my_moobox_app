import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/operador_model.dart';
import '../widgets/driver_order_card.dart';

class OperatorHomeTab extends StatefulWidget {
  final String rol;
  const OperatorHomeTab({super.key, required this.rol});

  @override
  State<OperatorHomeTab> createState() => _OperatorHomeTabState();
}

class _OperatorHomeTabState extends State<OperatorHomeTab> {
  final _supabase = Supabase.instance.client;
  bool isOnline = false;
  String driverName = "Conductor";
  String? idVehiculo;
  double vehicleCapacityTN = 0.0;
  String? activeTaskTitle;
  double earningsToday = 0.0;
  List<Map<String, dynamic>> recentHistory = [];
  bool _loading = true;
  Position? _currentPosition;
  
  // Real-time synchronization for orders with directions
  StreamSubscription? _offersSubscription;
  List<Map<String, dynamic>> _availableOrders = [];
  bool _fetchingOrders = false;

  @override
  void initState() {
    super.initState();
    _fetchOperatorData();
    _determinePosition();
    _initOffersStream();
  }

  @override
  void dispose() {
    _offersSubscription?.cancel();
    super.dispose();
  }

  void _initOffersStream() {
    // Listen for any change in ofertas_pedido and trigger a full fetch with joins
    _offersSubscription = _supabase
        .from('ofertas_pedido')
        .stream(primaryKey: ['id_oferta'])
        // Escuchamos cambios generales para re-sincronizar el feed del conductor
        .listen((_) => _fetchOrdersWithDirections());
  }

  Future<void> _fetchOrdersWithDirections() async {
    if (_fetchingOrders) return;
    setState(() => _fetchingOrders = true);

    try {
      final data = await _supabase
          .from('ofertas_pedido')
          .select('*, direcciones(*)')
          .eq('estado_oferta', 'abierta');
      
      if (mounted) {
        setState(() {
          _availableOrders = List<Map<String, dynamic>>.from(data);
          _fetchingOrders = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching orders with directions: $e");
      if (mounted) setState(() => _fetchingOrders = false);
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() => _currentPosition = position);
    }
  }

  Future<void> _fetchOperatorData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Obtener datos del operador
      final opDataRaw = await _supabase.from('operador').select().eq('id_operador', user.id).maybeSingle();
      
      OperadorModel? opModel;
      if (opDataRaw != null) {
        opModel = OperadorModel.fromJson(opDataRaw);
      }
      
      // 1.5 Obtener capacidad del vehículo si existe
      double capacity = 0.0;
      if (opModel?.idVehiculo != null) {
        final vData = await _supabase.from('vehiculos').select('capacidad_kg').eq('id_vehiculo', opModel!.idVehiculo!).maybeSingle();
        if (vData != null) {
          capacity = (double.tryParse(vData['capacidad_kg']?.toString() ?? '0') ?? 0) / 1000;
        }
      }
      
      // 2. Obtener tarea activa (si existe)
      final activeTask = await _supabase
          .from('pedidos')
          .select()
          .eq('id_operador', user.id)
          .eq('estado_pedido', 'aceptado')
          .maybeSingle();

      // 3. Obtener ingresos de hoy y historial reciente
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      
      final history = await _supabase
          .from('pedidos')
          .select()
          .eq('id_operador', user.id)
          .eq('estado_pedido', 'completado') // o el estado que sea para finalizado
          .order('fecha_servicio', ascending: false)
          .limit(3);

      if (mounted) {
        setState(() {
          if (opModel != null) {
            driverName = opModel.nombre;
            isOnline = opModel.estado == 'activo';
            idVehiculo = opModel.idVehiculo;
            vehicleCapacityTN = capacity;
          }
          
          if (activeTask != null) {
            activeTaskTitle = "Viaje en curso"; 
          }

          recentHistory = List<Map<String, dynamic>>.from(history);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching operator home data: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptOrder(Map<String, dynamic> order) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      // 1. Crear el pedido oficial
      await _supabase.from('pedidos').insert({
        'id_usuario': order['id_usuario'],
        'id_operador': user.id,
        'descripcion': "Envío ${order['tipo_carga']}",
        'costo_cotizado': order['monto_ofertado'],
        'estado_pedido': 'aceptado',
        'id_oferta_vinculada': order['id_oferta'],
      });

      // 2. Actualizar la oferta
      await _supabase.from('ofertas_pedido').update({
        'estado_oferta': 'aceptada'
      }).eq('id_oferta', order['id_oferta']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Viaje aceptado con éxito. ¡Buen camino!"),
          backgroundColor: Colors.green,
        ));
        _fetchOperatorData();
      }
    } catch (e) {
      debugPrint("Error aceptando pedido: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final newStatus = !isOnline;
    try {
      await _supabase.from('operador').update({
        'estado': newStatus ? 'activo' : 'inactivo'
      }).eq('id_operador', user.id);
      
      setState(() => isOnline = newStatus);
    } catch (e) {
      debugPrint("Error toggling status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by parent or theme
      body: Column(
        children: [
          _buildDriverHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeTaskTitle != null)
                    _buildCurrentTaskCard(context)
                  else if (isOnline)
                    _buildAvailableOrdersList(context)
                  else
                    _buildOfflinePlaceholder(context),
                  
                  const SizedBox(height: 35),
                  Text(
                    "ÚLTIMOS VIAJES",
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (recentHistory.isEmpty)
                    Text("No hay viajes recientes", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3), fontSize: 12))
                  else
                    ...recentHistory.map((h) => _buildMiniHistoryTile(
                      context,
                      h['descripcion'] ?? "Servicio Moobox", 
                      "${h['costo_final'] ?? h['costo_cotizado'] ?? 0} BOB"
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Modo Conductor", style: TextStyle(color: textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("¡Buen turno, ${driverName.split(' ')[0]}!", 
                style: GoogleFonts.inter(color: textTheme.displayLarge?.color, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
          InkWell(
            onTap: _toggleStatus,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.statusSuccess.withOpacity(0.12) : colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isOnline ? AppColors.statusSuccess.withOpacity(0.4) : colorScheme.onSurface.withOpacity(0.1))
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: isOnline ? AppColors.statusSuccess : colorScheme.onSurface.withOpacity(0.3), radius: 4),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? "EN LÍNEA" : "OFFLINE", 
                    style: TextStyle(
                      color: isOnline ? AppColors.statusSuccess : colorScheme.onSurface.withOpacity(0.6), 
                      fontWeight: FontWeight.w900, 
                      fontSize: 10,
                      letterSpacing: 0.5
                    )
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOfflinePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.power_settings_new_rounded, size: 50, color: Theme.of(context).dividerColor),
          const SizedBox(height: 20),
          Text(
            "ESTÁS OFFLINE",
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Text(
            "Conéctate para empezar a recibir solicitudes de carga en tiempo real.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersList(BuildContext context) {
    if (_fetchingOrders && _availableOrders.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
      ));
    }

    // Ya no filtramos por capacidad, mostramos TODAS las ofertas abiertas
    final filteredOrders = List<Map<String, dynamic>>.from(_availableOrders);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text("NO HAY PEDIDOS DISPONIBLES", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
        ),
      );
    }

    // --- LÓGICA DE ORDENAMIENTO DE PRIORIDAD ---
    filteredOrders.sort((a, b) {
      // 1. Prioridad: Coincidencia de ID de vehículo
      final bool aIsSpecial = idVehiculo != null && a['id_vehiculo'] == idVehiculo;
      final bool bIsSpecial = idVehiculo != null && b['id_vehiculo'] == idVehiculo;
      
      if (aIsSpecial && !bIsSpecial) return -1;
      if (!aIsSpecial && bIsSpecial) return 1;

      // 2. Prioridad: Distancia (si tenemos GPS)
      if (_currentPosition != null) {
        double distA = _getDistanceToOrder(a);
        double distB = _getDistanceToOrder(b);
        return distA.compareTo(distB);
      }

      return 0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.warningYellow, size: 16),
            const SizedBox(width: 8),
            Text(
              "SOLICITUDES EN TU ZONA",
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.primaryBlue),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...filteredOrders.map((order) {
          final bool isSpecial = idVehiculo != null && order['id_vehiculo'] == idVehiculo;
              return DriverOrderCard(
                order: order,
                isSpecial: isSpecial,
                currentPosition: _currentPosition,
                vehicleCapacity: vehicleCapacityTN,
                onAccept: () => _acceptOrder(order),
              );
        }),
      ],
    );
  }

  double _getDistanceToOrder(Map<String, dynamic> order) {
    if (_currentPosition == null) return 9999.0;
    final directions = order['direcciones'] as List?;
    if (directions == null || directions.isEmpty) return 9999.0;
    
    final origin = directions.firstWhere((d) => d['tipo_direccion'] == 'origen', orElse: () => null);
    if (origin == null) return 9999.0;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      origin['latitud'],
      origin['longitud'],
    );
  }

  Widget _buildCurrentTaskCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
              Text("HOY: ${earningsToday.toStringAsFixed(0)} BOB", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 25),
          const Text("ESTADO ACTUAL", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(
            activeTaskTitle ?? (isOnline ? "Esperando solicitudes..." : "Conéctate para recibir viajes"), 
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.2)
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: activeTaskTitle != null ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                disabledBackgroundColor: Colors.white.withOpacity(0.1)
              ),
              child: Text(
                activeTaskTitle != null ? "ACTUALIZAR ESTADO" : "SIN TAREAS", 
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 12, 
                  letterSpacing: 0.5,
                  color: activeTaskTitle != null ? AppColors.primaryBlue : Colors.white38
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniHistoryTile(BuildContext context, String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title, 
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(price, style: const TextStyle(color: AppColors.statusSuccess, fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }
}
