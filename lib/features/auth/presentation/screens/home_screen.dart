import 'dart:async';
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
  String? _fotoUrl;
  final _supabase = Supabase.instance.client;

  // Key para acceder al estado de la pestaña de registros y forzar refrescos
  final GlobalKey<RegistrosTabState> _registrosKey = GlobalKey<RegistrosTabState>();


  // --- 1. SUBSCRIPCIÓN ROBUSTA ---
  StreamSubscription? _avatarSubscription;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(rol: widget.rol), 
      RegistrosTab(key: _registrosKey),     
      const ChatTab(),           
    ];

    _escucharCambiosPerfil(); 
  }

  void _escucharCambiosPerfil() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Escucha la tabla 'usuario' filtrando por el ID actual
    // Importante: primaryKey debe coincidir con el nombre exacto en tu DB
    _avatarSubscription = _supabase
        .from('usuario')
        .stream(primaryKey: ['id_usuario'])
        .eq('id_usuario', user.id)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            setState(() {
              // Si la URL cambia o es nula, el widget se reconstruirá solo
              _fotoUrl = data.first['foto_url'];
              debugPrint("Moobox Sync: Foto actualizada en tiempo real");
            });
          }
        }, onError: (error) {
          debugPrint("Error Realtime Moobox: $error");
        });
  }

  @override
  void dispose() {
    _avatarSubscription?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
                  onTap: () {
                    // No necesitas refrescar manualmente al volver porque el Stream está vivo
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PerfilScreen(rol: widget.rol)),
                    );
                  },
                  child: _buildDynamicAvatar(),
                ),
              ),
            ],
          ),
        ],
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // Si el usuario cambia a la pestaña de REGISTROS (índice 1), forzamos el refresco
          if (index == 1) {
            _registrosKey.currentState?.fetchRegistros();
          }
        },

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

  Widget _buildDynamicAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 1),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.dividerGray.withOpacity(0.3),
        // Agregamos una Key única para forzar el refresco de la imagen si la URL cambia
        key: ValueKey(_fotoUrl), 
        backgroundImage: (_fotoUrl != null && _fotoUrl!.isNotEmpty) 
            ? NetworkImage(_fotoUrl!) 
            : null,
        child: (_fotoUrl == null || _fotoUrl!.isEmpty)
            ? const Icon(Icons.person_rounded, size: 24, color: AppColors.textBlack)
            : null,
      ),
    );
  }
}