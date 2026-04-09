import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart'; // MOTOR VECTORIAL GPU ACELERADO
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
  LatLng _puntoVisual = const LatLng(-17.3935, -66.1570); 
  MaplibreMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isSnapping = false; // ESCUDO ANTI-BUCLES
  Timer? _debounce;
  Timer? _snapDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _snapDebounce?.cancel();
    super.dispose();
  }

  // --- BUSCADOR ULTRA-RÁPIDO (Photon API) ---
  Future<void> _buscarLugar(String query) async {
    if (query.trim().length < 3) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }
    if (mounted) setState(() => _isSearching = true);
    try {
      final url = Uri.parse('https://photon.komoot.io/api/?q=$query&lat=${_puntoVisual.latitude}&lon=${_puntoVisual.longitude}&limit=5');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() => _searchResults = data['features'] ?? []);
      }
    } catch (e) {
      debugPrint("Error en Photon Search: $e");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // --- ANCLAJE A CALLES OSRM (Snap to Road Seguro) ---
  Future<void> _ajustarAViaCercana(LatLng punto) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
          'https://router.project-osrm.org/nearest/v1/driving/${punto.longitude},${punto.latitude}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['waypoints'] != null && data['waypoints'].isNotEmpty) {
          final List<dynamic> location = data['waypoints'][0]['location'] as List<dynamic>;
          double lng = (location[0] as num).toDouble();
          double lat = (location[1] as num).toDouble();
          LatLng puntoEnCalle = LatLng(lat, lng);

          // Levantamos el escudo antes del salto
          _isSnapping = true; 
          _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: puntoEnCalle, zoom: _mapController?.cameraPosition?.zoom ?? 16.5, tilt: 0.0)
          ));
          setState(() => _puntoVisual = puntoEnCalle);
        }
      }
    } catch (e) {
      debugPrint("Error OSRM: $e");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _puntoVisual = position.target;
  }

  void _onCameraIdle() {
    if (_isSnapping) {
      // Si llegamos aquí gracias a un salto automático, apagamos el escudo y terminamos, evitando el loop infinito.
      _isSnapping = false;
      return;
    }
    
    // Si llegamos aquí porque el HUMANO soltó el mapa, esperamos 1.5 segs y lanzamos el imán magnético a la calle.
    if (_snapDebounce?.isActive ?? false) _snapDebounce!.cancel();
    _snapDebounce = Timer(const Duration(milliseconds: 1500), () {
      final LatLng? centro = _mapController?.cameraPosition?.target;
      if (centro != null) {
        _ajustarAViaCercana(centro);
      }
    });
  }

  Future<void> _irAUbicacionActual() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng miPos = LatLng(position.latitude, position.longitude);
      
      // Como esto es un salto explícito, levantamos el escudo
      _isSnapping = true;
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: miPos, zoom: 16.5, tilt: 0.0)
      ));
      
      // Ajustamos a calle también
      _ajustarAViaCercana(miPos);
    } catch (e) {
      debugPrint("Error GPS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. EL NUEVO MAPA VECTORIAL: Estilo Positron (Gris y Blanco) en estricto 2D
          MaplibreMap(
            styleString: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
            initialCameraPosition: CameraPosition(
              target: _puntoVisual,
              zoom: 15.0,
              tilt: 0.0, // Bloqueado a 2D
            ),
            onMapCreated: (MaplibreMapController controller) {
              _mapController = controller;
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle, 
            compassEnabled: false,
            myLocationEnabled: true,
            trackCameraPosition: true,
          ),

          // 2. BUSCADOR SUPERIOR
          _buildFloatingSearchBar(),

          // 3. PIN CENTRAL ESTÁTICO PREMIUM
          _buildStaticCenterPin(),

          // 4. BOTÓN GPS
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

          // 5. PANEL INFERIOR DE CONFIRMACIÓN
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildStaticCenterPin() {
    return Center(
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.only(bottom: 40),
          child: CustomPaint(
            size: const Size(40, 80),
            painter: StaticPinPainter(
              color: _isSearching ? AppColors.accentCoral : AppColors.textBlack,
            ),
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
                color: Colors.white, // Contrasta hermosamente con el mapa oscuro
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: AppColors.textBlack, fontSize: 13, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Escribe tu ciudad o calle...",
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                  suffixIcon: _isSearching 
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))) 
                    : (_searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults.clear());
                            })
                        : null),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                ),
                onChanged: (val) {
                  setState(() {}); 
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () => _buscarLugar(val));
                },
              ),
            ),
            if (_searchResults.isNotEmpty) _buildSearchResultsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.dividerGray),
        itemBuilder: (context, index) {
          final place = _searchResults[index];
          final props = place['properties'] ?? {};
          final geometry = place['geometry'] ?? {};
          
          final String title = props['name'] ?? props['city'] ?? "Ubicación";
          final String subtitle = [props['street'], props['city'], props['state']].where((e) => e != null).join(', ');

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            leading: const Icon(Icons.location_on_outlined, color: AppColors.primaryBlue),
            title: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textBlack), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: subtitle.isNotEmpty 
                ? Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            onTap: () {
              final List<dynamic> coords = geometry['coordinates'];
              if (coords.length == 2) {
                double lon = (coords[0] as num).toDouble();
                double lat = (coords[1] as num).toDouble();
                LatLng target = LatLng(lat, lon);

                _isSnapping = true;
                _mapController?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: target, zoom: 16.5, tilt: 0.0)
                ));
                _ajustarAViaCercana(target);

                setState(() {
                  _searchResults.clear();
                  _searchController.text = title;
                });
                FocusScope.of(context).unfocus();
              }
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
          color: Colors.white.withOpacity(0.95), // Adaptado al dark theme exterior
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isSearching ? "ANCLANDO A CALLE..." : "MUEVE EL MAPA PARA APUNTAR",
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: _isSearching ? AppColors.accentCoral : AppColors.primaryBlue, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSearching ? null : () => _mostrarModalNombre(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text("CONFIRMAR UBICACIÓN", style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalNombre(BuildContext context) {
    final LatLng lecturaFinal = _mapController?.cameraPosition?.target ?? _puntoVisual;
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
                    'direccion_texto': _searchController.text.isNotEmpty ? _searchController.text : "Ubicación fijada manualmente",
                  });
                  final rootContext = this.context;
                  if (mounted) {
                    Navigator.pop(context); // Cierra Modal
                    if (rootContext.mounted) {
                      Navigator.pop(rootContext, true); // Cierra Mapa
                    }
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

// --- VISUAL GRAPHICS ---
class StaticPinPainter extends CustomPainter {
  final Color color;
  StaticPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final crossHairPaint = Paint()
      ..color = color.withOpacity(0.8) // Crosshair blanco brillante o Coral 
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.primaryBlue // Azul central
      ..style = PaintingStyle.fill;

    // Linea horizontal y vertical
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx, center.dy + 12), crossHairPaint);
    canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 12, center.dy), crossHairPaint);
    
    // Circulo intenso céntrico
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant StaticPinPainter oldDelegate) => oldDelegate.color != color;
}