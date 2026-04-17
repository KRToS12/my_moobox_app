import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screens/perfil_screen.dart';
import 'operator_home_tab.dart';

class OperatorHomeScreen extends StatefulWidget {
  final String rol;
  const OperatorHomeScreen({super.key, required this.rol});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  String? _fotoUrl;
  final _supabase = Supabase.instance.client;
  StreamSubscription? _avatarSubscription;

  @override
  void initState() {
    super.initState();
    _escucharCambiosPerfil();
  }

  void _escucharCambiosPerfil() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Los operadores podrían estar en una tabla diferente o en 'usuario'
    // Por ahora, intentamos escuchar 'usuario' como el estándar del app
    _avatarSubscription = _supabase
        .from('usuario')
        .stream(primaryKey: ['id_usuario'])
        .eq('id_usuario', user.id)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            setState(() {
              _fotoUrl = data.first['foto_url'];
            });
          }
        }, onError: (error) {
          debugPrint("Error Realtime Operator: $error");
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
      body: OperatorHomeTab(rol: widget.rol),
    );
  }
}
