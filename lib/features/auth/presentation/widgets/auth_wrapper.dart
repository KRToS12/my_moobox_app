import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../screens/login_screen.dart';
import '../../presentation/screens/home_screen.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();

    return StreamBuilder<AuthState>(
      // Escucha cambios en el estado de autenticación (Login/Logout)
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mostramos carga mientras se recupera la sesión inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        // CASO 1: No hay sesión activa -> Pantalla de Login
        if (session == null) {
          return const LoginScreen();
        }

        // CASO 2: Hay sesión -> Consultamos el ROL en las tablas de Supabase
        return FutureBuilder<String?>(
          future: authRepo.getUsuarioRol(session.user.id),
          builder: (context, rolSnapshot) {
            // Mostramos carga mientras se consulta la base de datos (Operador vs Cliente)
            if (rolSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Si se identifica el rol, enviamos al HomeScreen con su interfaz personalizada
            if (rolSnapshot.hasData && rolSnapshot.data != null) {
              return HomeScreen(rol: rolSnapshot.data!);
            }

            // Si hay sesión de Auth pero el usuario no existe en nuestras tablas, 
            // lo mandamos a Login (posiblemente para que termine su registro).
            return const LoginScreen();
          },
        );
      },
    );
  }
}