import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  final String rol;
  const HomeScreen({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Moobox - Panel de $rol"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          )
        ],
      ),
      body: Center(child: Text("Bienvenido $rol, aquí verás tus fletes.")),
    );
  }
}