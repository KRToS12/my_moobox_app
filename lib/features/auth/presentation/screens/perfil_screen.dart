import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../features/auth/presentation/widgets/auth_wrapper.dart';
import '../../../../app.dart'; // Para acceso al MyApp
import '../settings/perfil_detalle.dart'; // Asegúrate de que este nombre coincida con tu archivo
import '../settings/documentacion_detalle.dart';
import '../settings/ajuste_detalle.dart';
import '../settings/notificaciones_detalle.dart';
import '../settings/premios_detalle.dart';
import '../settings/direcciones_detalle.dart';

class PerfilScreen extends StatefulWidget {
  final String rol;
  const PerfilScreen({super.key, required this.rol});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestUserData();
  }

  // --- LÓGICA DE SINCRONIZACIÓN CON TABLA 'USUARIO' ---
  Future<void> _fetchLatestUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('usuario')
          .select()
          .eq('id_usuario', user.id)
          .single();

      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error cargando perfil: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraemos los datos de la tabla 'usuario'
    final String userName = _userData?['nombre'] ?? "Usuario Moobox";
    final String userEmail = _userData?['email'] ?? _supabase.auth.currentUser?.email ?? "sin-correo@moobox.com";
    final String? userPhoto = _userData?['foto_url'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : RefreshIndicator(
            onRefresh: _fetchLatestUserData, // Permite deslizar hacia abajo para actualizar
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  _buildProfileHeader(context, userPhoto, userName, userEmail),
                  const SizedBox(height: 35),

                  _buildSectionLabel(context, "GESTIÓN DE CUENTA"),
                  _buildMenuOption(context, Icons.person_outline_rounded, "Información Personal", () async {
                    // Al volver de la pantalla de ajustes, refrescamos los datos
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AjusteDetalleScreen()));
                    _fetchLatestUserData();
                  }),
                  _buildMenuOption(context, Icons.description_outlined, "Documentación Legal", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentacionLegalScreen()));
                  }),

                  const SizedBox(height: 25),
                  _buildSectionLabel(context, "MI ACTIVIDAD"),
                  _buildMenuOption(context, Icons.map_outlined, "Direcciones Guardadas", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DireccionesDetalleScreen()));
                  }),
                  _buildMenuOption(context, Icons.card_giftcard_rounded, "Referidos y Premios", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferidosPremiosScreen()));
                  }),

                  const SizedBox(height: 25),
                  _buildSectionLabel(context, "SOPORTE Y AJUSTES"),
                  _buildThemeSwitchOption(context),
                  _buildMenuOption(context, Icons.notifications_none_rounded, "Notificaciones", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferidosPremiosScreen()));
                  }),
                  _buildMenuOption(context, Icons.settings_outlined, "Ajustes de la App", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferidosPremiosScreen()));
                  }),

                  const SizedBox(height: 50),
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                  Text("Versión 1.0.0", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 10)),
                ],
              ),
            ),
          ),
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildProfileHeader(BuildContext context, String? photoUrl, String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          // Lógica de Foto Predeterminada vs Real
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) 
              ? NetworkImage(photoUrl) 
              : null,
          child: (photoUrl == null || photoUrl.isEmpty) 
              ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue) 
              : null,
        ),
        const SizedBox(height: 15),
        Text(name, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.displayLarge?.color)),
        Text(email, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: AppColors.accentCoral.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(
            widget.rol.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.accentCoral, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  // (Se mantienen el resto de los métodos _buildSectionLabel, _buildMenuOption, etc.)
  // ...
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("MI PERFIL", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildThemeSwitchOption(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SwitchListTile(
        activeColor: AppColors.primaryBlue,
        activeTrackColor: AppColors.accentCoral,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 15),
            Text("Modo Oscuro", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        value: isDark,
        onChanged: (val) {
          MyApp.of(context)?.changeTheme(val ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 15),
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.1),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text("CERRAR SESIÓN", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¿Cerrar Sesión?", style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text("Se cerrará el acceso seguro a tu cuenta Moobox.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              await AuthRepository().logout();
              if (context.mounted) {
                // Al cerrar sesión, lo enviamos de vuelta al AuthWrapper que sirve como portero
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                  (route) => false,
                );
              }
            },
            child: const Text("SÍ, SALIR", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}