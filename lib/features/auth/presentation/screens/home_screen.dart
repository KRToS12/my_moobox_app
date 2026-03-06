import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import para datos de usuario
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

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(rol: widget.rol), 
      const RegistrosTab(),     
      const ChatTab(),          
    ];
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
                style: GoogleFonts.inter( // Cambio a Inter para más seriedad
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerfilScreen(rol: widget.rol),
                      ),
                    ),
                    // INTEGRACIÓN: Avatar dinámico
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
        selectedItemColor: AppColors.primaryBlue, // Azul Moobox
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

  // --- LÓGICA DE AVATAR: Círculo con foto o icono predeterminado ---
  Widget _buildDynamicAvatar() {
    // Obtenemos el usuario actual de Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final String? userPhoto = user?.userMetadata?['avatar_url']; // URL de Google

    return CircleAvatar(
      radius: 20, // Tamaño consistente en la cabecera
      backgroundColor: AppColors.dividerGray.withOpacity(0.3),
      backgroundImage: userPhoto != null 
          ? NetworkImage(userPhoto) 
          : null,
      child: userPhoto == null
          ? const Icon(
              Icons.person_rounded, 
              size: 24, 
              color: AppColors.textBlack, // Negro Moobox
            )
          : null,
    );
  }
}