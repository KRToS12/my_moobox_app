import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Aquí importarás tus pantallas más adelante

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session == null) {
          return const Text("Aquí irá tu LoginScreen()"); // Cambiar por tu LoginScreen
        } else {
          // Aquí llamaremos a una función para verificar el ROL en las tablas
          return const Text("Aquí irá tu Dashboard dinámico"); 
        }
      },
    );
  }
}