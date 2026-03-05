import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/data/repositories/auth_repository.dart';
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

  // Lista de pantallas importadas
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(rol: widget.rol), // Pantalla de Inicio
      const RegistrosTab(),     // Pantalla de Registros
      const ChatTab(),          // Pantalla de Chat
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // SOLO OPCIONES SUPERIORES
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "MOOBOX",
          style: GoogleFonts.quicksand(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () => _showLogoutDialog(context),
              child: const Icon(Icons.account_circle, size: 40, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),

      // CUERPO: Muestra la pantalla seleccionada
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // SOLO OPCIONES INFERIORES
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'REGISTROS'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'CHAT'),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Deseas salir de Moobox?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              await AuthRepository().logout();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Sí", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}