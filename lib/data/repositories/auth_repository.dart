import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  // Registro solo para Clientes
  Future<void> registrarCliente({required String email, required String password, required String nombre}) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    if (res.user != null) {
      await _supabase.from('usuario').insert({
        'id_usuario': res.user!.id,
        'nombre': nombre,
        'email': email,
      });
    }
  }

  // Login Universal
  Future<String> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(email: email, password: password);
    final String uid = res.user!.id;

    // 1. Buscamos si es Operador
    final operador = await _supabase.from('operador').select().eq('id_operador', uid).maybeSingle();
    if (operador != null) return 'OPERADOR';

    // 2. Si no, es Cliente
    return 'CLIENTE';
  }

  // Cerrar sesión
  Future<void> logout() async => await _supabase.auth.signOut();
}