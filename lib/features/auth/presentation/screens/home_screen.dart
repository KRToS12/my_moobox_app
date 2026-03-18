import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/features/auth/presentation/screens/perfil_screen.dart';
import 'package:my_moobox_app/features/menu/presentation/screens/home_tab.dart';
import 'package:my_moobox_app/features/menu/presentation/screens/registros_tab.dart';
import 'package:my_moobox_app/features/menu/presentation/screens/chat_tab.dart';

class HomeScreen extends StatefulWidget {
  final String rol;
  const HomeScreen({super.key, required this.rol});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  
  // Variables para el estado del usuario
  String? _fotoUrl;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(rol: widget.rol), 
      const RegistrosTab(),     
      const ChatTab(),           
    ];
    _fetchAvatarActual(); // Carga inicial
  }

  // --- LÓGICA DE SINCRONIZACIÓN: Obtener foto de la tabla 'usuario' ---
  Future<void> _fetchAvatarActual() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('usuario')
          .select('foto_url')
          .eq('id_usuario', user.id)
          .single();

      if (mounted) {
        setState(() {
          _fotoUrl = data['foto_url'];
        });
      }
    } catch (e) {
      debugPrint("Error al sincronizar avatar en Home: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              floating: true, 
              snap: true,    
              centerTitle: false,
              title: Text(
                "MOOBOX",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  letterSpacing: 1.5,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(29),
                    onTap: () async {
                      // Al volver de PerfilScreen, refrescamos el avatar por si hubo cambios
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilScreen(rol: widget.rol),
                        ),
                      );
                      _fetchAvatarActual(); // Refresco tras volver
                    },
                    child: _buildDynamicAvatar(),
                  ),
                ),
              ],
            ),
          ];
        },
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primaryBlue, 
        unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
        showUnselectedLabels: true,
        backgroundColor: AppColors.background,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'REGISTROS'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'CHAT'),
        ],
      ),
    );
  }

  // --- WIDGET AVATAR: Prioriza foto de DB sobre icono predeterminado ---
  Widget _buildDynamicAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 1),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.dividerGray.withOpacity(0.3),
        // Sincronización con la URL de la base de datos
        backgroundImage: (_fotoUrl != null && _fotoUrl!.isNotEmpty) 
            ? NetworkImage(_fotoUrl!) 
            : null,
        child: (_fotoUrl == null || _fotoUrl!.isEmpty)
            ? const Icon(
                Icons.person_rounded, 
                size: 24, 
                color: AppColors.textBlack,
              )
            : null,
      ),
    );
  }
}