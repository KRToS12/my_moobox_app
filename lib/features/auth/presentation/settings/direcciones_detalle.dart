import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/menu/presentation/screens/maps.dart';

class DireccionesDetalleScreen extends StatefulWidget {
  const DireccionesDetalleScreen({super.key});

  @override
  State<DireccionesDetalleScreen> createState() => _DireccionesDetalleScreenState();
}

class _DireccionesDetalleScreenState extends State<DireccionesDetalleScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _puntosFrecuentes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarPuntosDelUsuario();
  }

  // --- LÓGICA: CARGAR PUNTOS POR ID_USUARIO ---
  Future<void> _cargarPuntosDelUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('puntos_frecuentes')
          .select()
          .eq('id_usuario', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _puntosFrecuentes = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _notificar("Error al obtener tus direcciones: $e", esError: true);
    }
  }

  // --- LÓGICA: DIÁLOGO DE CONFIRMACIÓN ANTES DE BORRAR ---
  void _confirmarBorrado(String idPunto, String nombreLugar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¿Eliminar dirección?", 
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text("Estás por eliminar '$nombreLugar'. Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              Navigator.pop(context);
              _eliminarPunto(idPunto);
            },
            child: const Text("SÍ, ELIMINAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA: ELIMINAR PUNTO Y ACTUALIZAR LISTA ---
  Future<void> _eliminarPunto(String idPunto) async {
    try {
      await _supabase.from('puntos_frecuentes').delete().eq('id_punto', idPunto);
      await _cargarPuntosDelUsuario(); 
      _notificar("Punto frecuente eliminado.");
    } catch (e) {
      _notificar("Error al eliminar: $e", esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      // MODIFICACIÓN: Botón "+" que navega a SelectorUbicacionGratuito
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textBlack,
        onPressed: () async {
          // Navegamos al mapa y esperamos a que termine el proceso de guardado allá
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectorUbicacionGratuito()),
          );
          // Al regresar, refrescamos la lista automáticamente
          _cargarPuntosDelUsuario();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : RefreshIndicator(
            onRefresh: _cargarPuntosDelUsuario,
            child: _puntosFrecuentes.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _puntosFrecuentes.length,
                  itemBuilder: (context, i) => _buildCardDireccion(_puntosFrecuentes[i]),
                ),
          ),
    );
  }

  // --- COMPONENTES DE DISEÑO ---

  Widget _buildCardDireccion(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Icon(_getIconData(p['tipo_icono']), color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['nombre_lugar'], style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(p['direccion_texto'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _abrirFormulario(punto: p)),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), 
            onPressed: () => _confirmarBorrado(p['id_punto'], p['nombre_lugar']) 
          ),
        ],
      ),
    );
  }

  Widget _buildBotonGuardar(Map<String, dynamic>? punto, TextEditingController n, TextEditingController d, String ico) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textBlack, 
          padding: const EdgeInsets.all(18), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        onPressed: _isSaving ? null : () async {
          final userId = _supabase.auth.currentUser?.id;
          if (userId == null) return;

          setState(() => _isSaving = true);

          try {
            final payload = {
              'nombre_lugar': n.text.trim(),
              'direccion_texto': d.text.trim(),
              'tipo_icono': ico,
              'id_usuario': userId,
            };

            if (punto == null) {
              await _supabase.from('puntos_frecuentes').insert(payload);
            } else {
              await _supabase.from('puntos_frecuentes').update(payload).eq('id_punto', punto['id_punto']);
            }
            
            if (mounted) Navigator.pop(context);
            await _cargarPuntosDelUsuario(); 
            _notificar("Cambio guardado en Moobox");
          } catch (e) {
            _notificar("Error: $e", esError: true);
          } finally {
            if (mounted) setState(() => _isSaving = false);
          }
        },
        child: _isSaving 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text("GUARDAR EN MOOBOX", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
      ),
    );
  }

  void _abrirFormulario({Map<String, dynamic>? punto}) {
    final nombreController = TextEditingController(text: punto?['nombre_lugar'] ?? "");
    final direccionController = TextEditingController(text: punto?['direccion_texto'] ?? "");
    String iconoSeleccionado = punto?['tipo_icono'] ?? "home";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 25, right: 25, top: 25
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(punto == null ? "NUEVO PUNTO FRECUENTE" : "EDITAR PUNTO", 
                style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primaryBlue)),
            const SizedBox(height: 20),
            _buildInputField("Nombre del lugar (ej: Casa, Oficina)", nombreController),
            _buildInputField("Dirección descriptiva", direccionController),
            const SizedBox(height: 25),
            _buildBotonGuardar(punto, nombreController, direccionController, iconoSeleccionado),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String? type) {
    switch (type) {
      case 'work': return Icons.work_outline;
      case 'home': return Icons.home_outlined;
      default: return Icons.location_on_outlined;
    }
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 50, color: AppColors.dividerGray),
          const SizedBox(height: 15),
          Text("No tienes puntos guardados", style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  void _notificar(String m, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: esError ? Colors.redAccent : AppColors.primaryBlue));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack), onPressed: () => Navigator.pop(context)),
      title: Text("DIRECCIONES FRECUENTES", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
    );
  }
}