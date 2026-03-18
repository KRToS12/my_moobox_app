import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class AjusteDetalleScreen extends StatefulWidget {
  const AjusteDetalleScreen({super.key});

  @override
  State<AjusteDetalleScreen> createState() => _AjusteDetalleScreenState();
}

class _AjusteDetalleScreenState extends State<AjusteDetalleScreen> {
  final _supabase = Supabase.instance.client;
  final _nombreController = TextEditingController();
  final _numeroController = TextEditingController(); // Controlador para teléfono
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _email = "";
  double _calificacion = 5.0;
  String? _fotoUrl;
  Uint8List? _bytesNuevaFoto;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('usuario')
          .select()
          .eq('id_usuario', user.id)
          .single();

      setState(() {
        _email = data['email'] ?? user.email ?? "";
        _nombreController.text = data['nombre'] ?? "";
        _numeroController.text = data['numero'] ?? ""; // Carga el número
        _fotoUrl = data['foto_url'];
        _calificacion = (data['calificacion'] ?? 5.0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _notificar("Error al cargar datos: $e", esError: true);
    }
  }

  Future<void> _cambiarFoto() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _bytesNuevaFoto = bytes);
    }
  }

  Future<void> _guardar() async {
    if (_nombreController.text.trim().isEmpty) {
      _notificar("El nombre es obligatorio", esError: true);
      return;
    }

    setState(() => _isSaving = true);
    final userId = _supabase.auth.currentUser!.id;

    try {
      String? urlFinal = _fotoUrl;

      // 1. Subida al Bucket 'perfiles'
      if (_bytesNuevaFoto != null) {
        final path = 'avatars/$userId.jpg'; // Usamos una ruta fija por usuario para no llenar el storage
        
        await _supabase.storage.from('perfiles').uploadBinary(
          path, 
          _bytesNuevaFoto!,
          fileOptions: const FileOptions(upsert: true), // Sobrescribe la anterior
        );
        
        urlFinal = _supabase.storage.from('perfiles').getPublicUrl(path);
      }

      // 2. Actualización en Tabla 'usuario' con los campos correctos
      await _supabase.from('usuario').update({
        'nombre': _nombreController.text.trim(),
        'numero': _numeroController.text.trim(), // Guarda el teléfono
        'foto_url': urlFinal,
      }).eq('id_usuario', userId);

      setState(() {
        _fotoUrl = urlFinal;
        _bytesNuevaFoto = null;
      });

      _notificar("¡Moobox actualizado!", esError: false);
    } catch (e) {
      _notificar("Fallo al sincronizar: $e", esError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildFotoHeader(),
                const SizedBox(height: 15),
                _buildBadgeCalificacion(),
                const SizedBox(height: 45),
                _buildField("NOMBRE COMPLETO", _nombreController, enabled: true, icon: Icons.person_outline),
                _buildField("TELÉFONO MÓVIL", _numeroController, enabled: true, icon: Icons.phone_android),
                _buildField("CORREO ASOCIADO", TextEditingController(text: _email), enabled: false, icon: Icons.lock_outline),
                const SizedBox(height: 50),
                _buildBotonGuardar(),
              ],
            ),
          ),
    );
  }

  // --- COMPONENTES UI ---

  Widget _buildFotoHeader() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.textBlack,
            backgroundImage: _bytesNuevaFoto != null 
              ? MemoryImage(_bytesNuevaFoto!) // FIX PARA WEB
              : (_fotoUrl != null ? NetworkImage(_fotoUrl!) : null) as ImageProvider?,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: _cambiarFoto,
              child: const CircleAvatar(backgroundColor: AppColors.primaryBlue, radius: 18, child: Icon(Icons.camera_alt, color: Colors.white, size: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCalificacion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: AppColors.textBlack, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.warningYellow, size: 18),
          const SizedBox(width: 6),
          Text(_calificacion.toStringAsFixed(1), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {required bool enabled, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: enabled,
            style: GoogleFonts.inter(color: enabled ? AppColors.textBlack : Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
              filled: true,
              fillColor: enabled ? Colors.white : AppColors.dividerGray.withOpacity(0.15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.textBlack, padding: const EdgeInsets.all(22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _isSaving ? null : _guardar,
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text("GUARDAR CAMBIOS", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  void _notificar(String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: esError ? Colors.redAccent : AppColors.primaryBlue));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack), onPressed: () => Navigator.pop(context)),
      title: Text("DETALLES DE CUENTA", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textBlack)),
    );
  }
}