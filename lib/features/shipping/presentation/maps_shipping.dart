import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';

class MapsShippingScreen extends StatefulWidget {
  const MapsShippingScreen({super.key});

  @override
  State<MapsShippingScreen> createState() => _MapsShippingScreenState();
}

class _MapsShippingScreenState extends State<MapsShippingScreen> {
  LatLng _puntoActual = const LatLng(-17.3935, -66.1570); // Cochabamba
  String _direccionDetectada = "Ubicación en el mapa";
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _searchResults = [];
  bool _isProcessing = false;
  Timer? _debounce;

  // --- LÓGICA: Búsqueda con Prioridad por Cercanía ---
  Future<void> _buscarLugar(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    double bias = 0.05; 
    String viewbox = "${_puntoActual.longitude - bias},${_puntoActual.latitude + bias},${_puntoActual.longitude + bias},${_puntoActual.latitude - bias}";

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1&viewbox=$viewbox&bounded=0&countrycodes=bo');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'moobox_app'});
      if (response.statusCode == 200) {
        setState(() => _searchResults = json.decode(response.body));
      }
    } catch (e) {
      debugPrint("Error en búsqueda: $e");
    }
  }

  // --- LÓGICA: Snap to Road + Reverse Geocoding (Para obtener el nombre de la calle) ---
  Future<void> _ajustarAViaCercana(LatLng punto) async {
    setState(() => _isProcessing = true);
    try {
      // 1. Ajuste a la calle (OSRM)
      final urlOsrm = Uri.parse(
          'https://router.project-osrm.org/nearest/v1/driving/${punto.longitude},${punto.latitude}');

      final resOsrm = await http.get(urlOsrm);
      if (resOsrm.statusCode == 200) {
        final data = json.decode(resOsrm.body);
        if (data['waypoints'] != null && data['waypoints'].isNotEmpty) {
          final List location = data['waypoints'][0]['location'];
          final String nombreCalle = data['waypoints'][0]['name'] ?? "Calle no identificada";
          
          LatLng puntoEnCalle = LatLng(location[1], location[0]);
          _mapController.move(puntoEnCalle, _mapController.camera.zoom);
          
          setState(() {
            _puntoActual = puntoEnCalle;
            _direccionDetectada = nombreCalle;
          });
        }
      }
    } catch (e) {
      debugPrint("Error en ajuste: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _onMapEvent(MapPosition position, bool hasGesture) {
    if (!hasGesture) return;

    final centro = position.center;
    if (centro == null) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _ajustarAViaCercana(centro);
    });
  }

  Future<void> _irAUbicacionActual() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition();
    LatLng miPos = LatLng(position.latitude, position.longitude);
    _mapController.move(miPos, 16.5);
    _ajustarAViaCercana(miPos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _puntoActual,
              initialZoom: 16.0,
              onPositionChanged: (camera, hasGesture) => _onMapEvent(camera, hasGesture),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.moobox.app',
              ),
            ],
          ),

          _buildFloatingSearchBar(),
          _buildFineCentralPin(),

          Positioned(
            right: 20,
            bottom: 250,
            child: FloatingActionButton(
              backgroundColor: AppColors.background,
              elevation: 2,
              onPressed: _irAUbicacionActual,
              child: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue, size: 20),
            ),
          ),

          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildFineCentralPin() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 35),
        child: CustomPaint(
          size: const Size(40, 80),
          painter: FinePinPainter(
            color: _isProcessing ? AppColors.accentCoral : AppColors.textBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: AppColors.textBlack, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Buscar dirección cercana...",
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 600), () => _buscarLugar(val));
                },
              ),
            ),
            if (_searchResults.isNotEmpty) _buildSearchDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final place = _searchResults[index];
          return ListTile(
            dense: true,
            title: Text(place['display_name'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.textBlack), maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              final lat = double.parse(place['lat']);
              final lon = double.parse(place['lon']);
              LatLng destino = LatLng(lat, lon);
              _mapController.move(destino, 17.0);
              setState(() {
                _puntoActual = destino;
                _searchResults = [];
                _searchController.text = place['display_name'];
                _direccionDetectada = place['display_name'];
              });
              _ajustarAViaCercana(destino);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 25, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isProcessing ? "LOCALIZANDO VÍA..." : "PUNTO DETECTADO",
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: _isProcessing ? AppColors.accentCoral : AppColors.textSecondary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () {
                  // NO GUARDAMOS EN SUPABASE AQUÍ. Retornamos los datos a la pantalla anterior
                  Navigator.pop(context, {
                    'lat': _puntoActual.latitude,
                    'lng': _puntoActual.longitude,
                    'address': _direccionDetectada,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text("CONFIRMAR UBICACIÓN", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinePinPainter extends CustomPainter {
  final Color color;
  FinePinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 4, paint);
    canvas.drawLine(Offset(center.dx, center.dy - 15), Offset(center.dx, center.dy + 15), paint);
    canvas.drawLine(Offset(center.dx - 15, center.dy), Offset(center.dx + 15, center.dy), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}