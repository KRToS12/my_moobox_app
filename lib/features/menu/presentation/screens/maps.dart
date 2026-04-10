import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // MOTOR UNIFICADO
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
  LatLng _puntoActual = const LatLng(-17.3935, -66.1570); // Cochabamba
  String _direccionDetectada = "Ubicación en el mapa";
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _searchResults = [];
  bool _isProcessing = false;
  bool _isValidRoad = true;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- LÓGICA: Búsqueda Photon (Komoot) ---
  Future<void> _buscarLugar(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    final url = Uri.parse(
        'https://photon.komoot.io/api/?q=$query&lat=${_puntoActual.latitude}&lon=${_puntoActual.longitude}&limit=10&lang=es');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _searchResults = data['features'] ?? []);
      }
    } catch (e) {
      debugPrint("Moobox Unify Map Search Error: $e");
    }
  }

  // --- LÓGICA: Snap to Road Parallelo (OSRM + Photon) ---
  Future<void> _ajustarAViaCercana(LatLng punto) async {
    setState(() => _isProcessing = true);
    
    // Lanzamos ambas peticiones en paralelo para optimizar tiempo
    Future<void> taskPhoton = _obtenerDireccionFallback(punto);
    
    Future<void> taskOsrm = () async {
      try {
        final urlOsrm = Uri.parse(
            'https://router.project-osrm.org/nearest/v1/driving/${punto.longitude},${punto.latitude}');

        final resOsrm = await http.get(urlOsrm).timeout(const Duration(seconds: 2));
        
        if (resOsrm.statusCode == 200) {
          final data = json.decode(resOsrm.body);
          if (data['waypoints'] != null && data['waypoints'].isNotEmpty) {
            final List location = data['waypoints'][0]['location'];
            LatLng puntoEnCalle = LatLng(location[1], location[0]);
            final String nombreCalle = data['waypoints'][0]['name'] ?? "";

            final distance = const Distance().as(LengthUnit.Meter, punto, puntoEnCalle);
            
            // --- CORRECCIÓN: SEGURIDAD DE VÍAS ---
            if (distance > 50) {
              setState(() => _isValidRoad = false);
            } else {
              setState(() {
                _isValidRoad = true;
                _puntoActual = puntoEnCalle;
              });

              // Forzamos el salto si no es un ajuste mínimo
              if (distance > 2) {
                _mapController.move(puntoEnCalle, _mapController.camera.zoom);
              }
            }

            if (nombreCalle.isNotEmpty) {
              setState(() => _direccionDetectada = _limpiarDireccion(nombreCalle));
            }
          } else {
            setState(() => _isValidRoad = false);
          }
        } else {
          setState(() => _isValidRoad = false);
        }
      } catch (e) {
        debugPrint("Moobox Unify OSRM Parallel Error: $e");
      }
    }();

    try {
      await Future.wait([taskPhoton, taskOsrm]);
    } catch (e) {
      debugPrint("Moobox Unify Parallel Exec Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _limpiarDireccion(String addr) {
    if (addr == "Calle detectada" || addr == "Ubicación detectada") return addr;
    return addr
      .replaceAll(", Bolivia", "")
      .replaceAll(", Cochabamba", "")
      .replaceAll("Cochabamba, ", "")
      .split(", Argentina")[0]
      .trim();
  }

  Future<void> _obtenerDireccionFallback(LatLng punto) async {
    try {
      final urlPhoton = Uri.parse(
          'https://photon.komoot.io/reverse?lat=${punto.latitude}&lon=${punto.longitude}');
      
      final resPhoton = await http.get(urlPhoton).timeout(const Duration(seconds: 3));
      
      if (resPhoton.statusCode == 200) {
        final data = json.decode(resPhoton.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final props = data['features'][0]['properties'];
          final String nombre = props['name'] ?? props['street'] ?? "Ubicación detectada";
          
          setState(() {
            _puntoActual = punto;
            _direccionDetectada = _limpiarDireccion(nombre);
          });
        }
      }
    } catch (e) {
      debugPrint("Moobox Unify Fallback Error: $e");
    }
  }

  void _onMapEvent(MapPosition position, bool hasGesture) {
    if (!hasGesture) return;

    final centro = position.center;
    if (centro == null) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _puntoActual,
              initialZoom: 16.0,
              minZoom: 4.0,
              maxZoom: 19.5,
              onPositionChanged: (camera, hasGesture) => _onMapEvent(camera, hasGesture),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                maxNativeZoom: 18,
                maxZoom: 20,
                retinaMode: true,
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
              elevation: 4,
              onPressed: _irAUbicacionActual,
              child: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue, size: 22),
            ),
          ),

          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildFineCentralPin() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isProcessing)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textBlack,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "BUSCANDO...",
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
              ),
            ),
          Container(
            padding: EdgeInsets.only(bottom: _isProcessing ? 0 : 35),
            child: CustomPaint(
              size: const Size(40, 60),
              painter: FinePinPainter(
                color: !_isValidRoad 
                    ? AppColors.error 
                    : (_isProcessing ? AppColors.accentCoral : AppColors.primaryBlue),
                isProcessing: _isProcessing,
              ),
            ),
          ),
        ],
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: AppColors.textBlack, fontSize: 13, fontWeight: FontWeight.w500),
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
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: AppColors.background, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 50, color: AppColors.dividerGray),
        itemBuilder: (context, index) {
          final feature = _searchResults[index];
          final props = feature['properties'];
          final coords = feature['geometry']['coordinates'];
          
          final String name = props['name'] ?? props['street'] ?? "Lugar sin nombre";
          final String contextStr = "${props['district'] ?? ''} ${props['city'] ?? ''} ${props['state'] ?? ''}".trim();

          return ListTile(
            leading: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceElevated,
              child: Icon(Icons.location_on_outlined, color: AppColors.primaryBlue, size: 16),
            ),
            title: Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textBlack), maxLines: 1),
            subtitle: contextStr.isNotEmpty 
              ? Text(contextStr, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), maxLines: 1)
              : null,
            onTap: () {
              final lon = coords[0] as double;
              final lat = coords[1] as double;
              LatLng destino = LatLng(lat, lon);
              _mapController.move(destino, 17.5);
              setState(() {
                _puntoActual = destino;
                _searchResults = [];
                _searchController.text = name;
                _direccionDetectada = name;
              });
              _ajustarAViaCercana(destino);
              FocusScope.of(context).unfocus();
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (!_isValidRoad ? AppColors.error : (_isProcessing ? AppColors.accentCoral : AppColors.primaryBlue)).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    !_isValidRoad ? Icons.warning_amber_rounded : (_isProcessing ? Icons.sync : Icons.location_on), 
                    color: !_isValidRoad ? AppColors.error : (_isProcessing ? AppColors.accentCoral : AppColors.primaryBlue), 
                    size: 14
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _isProcessing 
                    ? "LOCALIZANDO VÍA..." 
                    : (!_isValidRoad ? "UBICACIÓN NO ACCESIBLE" : "PUNTO DETECTADO"),
                  style: GoogleFonts.inter(
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    color: !_isValidRoad ? AppColors.error : (_isProcessing ? AppColors.accentCoral : AppColors.textSecondary), 
                    letterSpacing: 1.5
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isProcessing 
                ? "Ajustando posición..." 
                : (!_isValidRoad ? "Sitúa el pin más cerca de una calle" : _direccionDetectada),
              style: GoogleFonts.inter(
                fontSize: 14, 
                fontWeight: FontWeight.w700, 
                color: !_isValidRoad ? AppColors.error : AppColors.textBlack,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isProcessing || !_isValidRoad) ? null : () => _mostrarModalNombre(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.dividerGray,
                ),
                child: Text(
                  !_isValidRoad ? "CALLE NO DETECTADA" : "CONFIRMAR UBICACIÓN", 
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13, letterSpacing: 0.5)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalNombre(BuildContext context) {
    final LatLng lecturaFinal = _puntoActual;
    final TextEditingController nameController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 30, right: 30),
        decoration: const BoxDecoration(
          color: AppColors.background, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GUARDAR ESTE PUNTO COMO:", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              autofocus: true,
              style: GoogleFonts.inter(color: AppColors.textBlack, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Ej: Almacén Norte, Taller, etc.",
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: AppColors.dividerGray.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.dividerGray, width: 1)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.dividerGray, width: 1)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue, 
                  padding: const EdgeInsets.symmetric(vertical: 18), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  await Supabase.instance.client.from('puntos_frecuentes').insert({
                    'id_usuario': Supabase.instance.client.auth.currentUser!.id,
                    'nombre_lugar': nameController.text.trim(),
                    'latitud': lecturaFinal.latitude,
                    'longitud': lecturaFinal.longitude,
                    'direccion_texto': _direccionDetectada.isNotEmpty ? _direccionDetectada : "Ubicación fijada manualmente",
                  });
                  if (mounted) {
                    Navigator.pop(context); // Cierra Modal
                    Navigator.pop(this.context, true); // Cierra Mapa
                  }
                },
                child: Text("GUARDAR PUNTO", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
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
  final bool isProcessing;
  FinePinPainter({required this.color, this.isProcessing = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 2), 10, shadowPaint);

    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, isProcessing ? 12 : 10, mainPaint);
    canvas.drawCircle(center, 3, solidPaint);
    
    double lineSize = isProcessing ? 18 : 15;
    double gap = 6; 
    
    canvas.drawLine(Offset(center.dx, center.dy - gap), Offset(center.dx, center.dy - lineSize), mainPaint);
    canvas.drawLine(Offset(center.dx, center.dy + gap), Offset(center.dx, center.dy + lineSize), mainPaint);
    canvas.drawLine(Offset(center.dx + gap, center.dy), Offset(center.dx + lineSize, center.dy), mainPaint);
    canvas.drawLine(Offset(center.dx - gap, center.dy), Offset(center.dx - lineSize, center.dy), mainPaint);
    
    if (isProcessing) {
      final pulsePaint = Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 20, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}