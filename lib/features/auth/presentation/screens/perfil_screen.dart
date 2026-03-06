import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/auth_repository.dart';

// Importa aquí tus nuevas pantallas cuando las crees

class PerfilScreen extends StatelessWidget {
  final String rol;
  PerfilScreen({super.key, required this.rol});

  final User? user = Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    final String userName = user?.userMetadata?['full_name'] ?? "Usuario Moobox";
    final String userEmail = user?.email ?? "sin-correo@moobox.com";
    final String? userPhoto = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: AppColors.background, // Unificación de blancos
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "MI PERFIL",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textBlack,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            _buildProfileHeader(userPhoto, userName, userEmail),
            const SizedBox(height: 35),

            _buildSectionLabel("GESTIÓN DE CUENTA"),
            _buildMenuOption(Icons.person_outline_rounded, "Información Personal", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilDetalleScreen()));
            }),
            _buildMenuOption(Icons.description_outlined, "Documentación Legal", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentacionLegalScreen()));
            }),

            const SizedBox(height: 25),

            // --- SECCIÓN: ACTIVIDAD ---
            _buildSectionLabel("MI ACTIVIDAD"),
            _buildMenuOption(Icons.map_outlined, "Direcciones Guardadas", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const DireccionesGuardadasScreen()));
            }),
            _buildMenuOption(Icons.card_giftcard_rounded, "Referidos y Premios", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferidosPremiosScreen()));
            }),

            const SizedBox(height: 25),

            // --- SECCIÓN: SOPORTE Y AJUSTES ---
            _buildSectionLabel("SOPORTE Y AJUSTES"),
            _buildMenuOption(Icons.notifications_none_rounded, "Notificaciones", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificacionesScreen()));
            }),
            _buildMenuOption(Icons.shield_outlined, "Seguridad y Privacidad", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const SeguridadPrivacidadScreen()));
            }),
            _buildMenuOption(Icons.help_outline_rounded, "Ayuda y Soporte", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const AyudaSoporteScreen()));
            }),
            _buildMenuOption(Icons.settings_outlined, "Ajustes de la App", () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const AjustesAppScreen()));
            }),

            const SizedBox(height: 50),

            _buildLogoutButton(context),
            const SizedBox(height: 20),
            Text("Versión 1.0.0", style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 10)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String? photoUrl, String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null 
              ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue) 
              : null,
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textBlack),
        ),
        Text(
          email,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentCoral.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            rol.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.accentCoral, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerGray.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
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
          backgroundColor: AppColors.textBlack, // Negro técnico para autoridad
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          "CERRAR SESIÓN",
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 1.0),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¿Cerrar Sesión?", style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
        content: const Text("Se cerrará el acceso seguro a tu cuenta Moobox."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              await AuthRepository().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text("SÍ, SALIR", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}