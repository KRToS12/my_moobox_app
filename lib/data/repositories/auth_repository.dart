import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  // 1. OBTENER ROL (Lógica centralizada)
  // Se usa tanto en el login como en el AuthWrapper
  Future<String?> getUsuarioRol(String uid) async {
    try {
      // Primero verificamos si es Operador (prioridad de negocio)
      final operador = await _supabase
          .from('operador')
          .select()
          .eq('id_operador', uid)
          .maybeSingle();
      if (operador != null) return 'OPERADOR';

      // Si no es operador, buscamos en la tabla de usuarios (clientes)
      final cliente = await _supabase
          .from('usuario')
          .select()
          .eq('id_usuario', uid)
          .maybeSingle();
      if (cliente != null) return 'CLIENTE';

      return null;
    } catch (e) {
      return null;
    }
  }

  // 2. LOGIN UNIVERSAL
  // Autentica y devuelve el rol para la navegación inicial
  Future<String> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email, 
      password: password
    );
    
    if (res.user == null) throw Exception("Error de autenticación");

    final rol = await getUsuarioRol(res.user!.id);
    if (rol == null) throw Exception("Usuario no registrado en tablas de Moobox");

    return rol;
  }

  // 3. REGISTRO (Solo para Clientes)
  // Recuerda: Los operadores solo los crea el admin desde la web
  Future<void> registrarCliente({
    required String email, 
    required String password, 
    required String nombre
  }) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    
    if (res.user != null) {
      await _supabase.from('usuario').insert({
        'id_usuario': res.user!.id,
        'nombre': nombre,
        'email': email,
      });
    }
  }

  // 4. CERRAR SESIÓN
  Future<void> logout() async => await _supabase.auth.signOut();
}