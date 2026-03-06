import 'dart:convert';
import 'dart:async'; // Para el debouncer
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';

class SelectorUbicacionGratuito extends StatefulWidget {
  const SelectorUbicacionGratuito({super.key});

  @override
  State<SelectorUbicacionGratuito> createState() => _SelectorUbicacionGratuitoState();
}

class _SelectorUbicacionGratuitoState extends State<SelectorUbicacionGratuito> {
  LatLng _puntoActual = const LatLng(-17.3935, -66.1570); 
  final MapController _mapController = MapController();
  bool _isProcessing = false;
  Timer? _debounce; // Evita peticiones excesivas mientras mueves el mapa

  // --- LÓGICA: Ajustar el punto a la calle más cercana (OSRM) ---
  Future<void> _ajustarAViaCercana(LatLng punto) async {
    setState(() => _isProcessing = true);
    try {
      // Usamos el servicio 'nearest' de OSRM para encontrar el asfalto más cercano
      final url = Uri.parse(
        'http://router.project-osrm.org/nearest/v1/driving/${punto.longitude},${punto.latitude}'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['waypoints'] != null && data['waypoints'].isNotEmpty) {
          final List location = data['waypoints'][0]['location'];
          LatLng puntoEnCalle = LatLng(location[1], location[0]);

          // Movemos el mapa suavemente a la calle
          _mapController.move(puntoEnCalle, _mapController.camera.zoom);
          setState(() => _puntoActual = puntoEnCalle);
        }
      }
    } catch (e) {
      debugPrint("Error ajustando a vía: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- LÓGICA: Debouncer para no saturar la API mientras el usuario desliza ---
  void _onMapEvent(MapPosition position, bool hasGesture) {
    if (hasGesture) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        if (position.center != null) {
          _ajustarAViaCercana(position.center!);
        }
      });
    }
  }

  Future<void> _irAUbicacionActual() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      LatLng miPos = LatLng(position.latitude, position.longitude);
      _mapController.move(miPos, 16.0);
      _ajustarAViaCercana(miPos); // Ajustamos al llegar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _puntoActual,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) => _onMapEvent(position, hasGesture),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.moobox.app',
              ),
            ],
          ),

          // PIN CENTRAL CON EFECTO DE PROCESAMIENTO
          Center(
            child: Padding(
              padding: const EdgeInsets.all(45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on, 
                    color: _isProcessing ? AppColors.accentCoral : AppColors.textBlack, 
                    size: 50
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isProcessing ? 20 : 8, height: 4,
                    decoration: BoxDecoration(
                      color: _isProcessing ? AppColors.accentCoral.withOpacity(0.5) : Colors.black26,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: 240,
            child: FloatingActionButton(
              backgroundColor: AppColors.white,
              mini: true,
              elevation: 4,
              onPressed: _irAUbicacionActual,
              child: const Icon(Icons.my_location, color: AppColors.primaryBlue),
            ),
          ),

          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 25, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isProcessing ? "AJUSTANDO A LA CALLE..." : "UBICACIÓN VÁLIDA",
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: FontWeight.w900, 
                color: _isProcessing ? AppColors.accentCoral : AppColors.textSecondary, 
                letterSpacing: 1.5
              ),
            ),
            const SizedBox(height: 15),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _mostrarModalNombre(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textBlack,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text("CONFIRMAR PUNTO", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }

  void _mostrarModalNombre(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30, 
          top: 25, left: 25, right: 25
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "¿CÓMO LLAMAREMOS A ESTE LUGAR?", 
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textBlack)
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Ej: Almacén Norte, Oficina...",
                filled: true,
                fillColor: AppColors.dividerGray.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            _buildBotonGuardarFinal(context, nameController),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonGuardarFinal(context, controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue, 
          padding: const EdgeInsets.symmetric(vertical: 18), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        onPressed: () async {
          if (controller.text.isEmpty) return;
          
          await Supabase.instance.client.from('puntos_frecuentes').insert({
            'id_usuario': Supabase.instance.client.auth.currentUser!.id,
            'nombre_lugar': controller.text,
            'latitud': _puntoActual.latitude,
            'longitud': _puntoActual.longitude,
            'direccion_texto': "Ajustado automáticamente a vía pública",
          });

          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
        child: const Text("GUARDAR PUNTO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "MAPA DE CARGA", 
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textBlack, letterSpacing: 1.5)
      ),
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textBlack), 
        onPressed: () => Navigator.pop(context)
      ),
    );
  }
}