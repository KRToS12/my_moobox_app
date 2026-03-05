import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  // 1. OBTENER ROL (Lógica centralizada)
  Future<String?> getUsuarioRol(String uid) async {
    try {
      // Prioridad: Operadores (Conductores)
      final operador = await _supabase
          .from('operador')
          .select()
          .eq('id_operador', uid)
          .maybeSingle();
      if (operador != null) return 'OPERADOR';

      // Segunda opción: Usuarios (Clientes)
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

  // 2. LOGIN CON GOOGLE (Móvil Nativo)
  Future<String> signInWithGoogleMobile() async {
    // Obtenemos el ID de forma segura desde el archivo .env
    final String webClientId = dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');

    if (webClientId.isEmpty) {
      throw Exception("Error: GOOGLE_WEB_CLIENT_ID no configurado en el archivo .env");
    }

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId, // El ID Web actúa como puente de validación
    );
    
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception("Inicio de sesión cancelado");

    final googleAuth = await googleUser.authentication;

    // Autenticación en Supabase con el token de Google
    final res = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    if (res.user == null) throw Exception("Error al conectar con Supabase");

    // Identificación de rol tras el login exitoso
    final rol = await getUsuarioRol(res.user!.id);
    return rol ?? 'CLIENTE'; 
  }

  // 3. LOGIN TRADICIONAL (Email/Password)
  Future<String> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email, 
      password: password
    );
    
    if (res.user == null) throw Exception("Error de autenticación");

    final rol = await getUsuarioRol(res.user!.id);
    if (rol == null) throw Exception("Usuario no registrado en Moobox");

    return rol;
  }

  // 4. REGISTRO MANUAL (Solo Clientes)
  Future<void> registrarCliente({
    required String email, 
    required String password, 
    required String nombre,
  }) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    
    if (res.user != null) {
      // Inserción manual en la tabla de usuarios de negocio
      await _supabase.from('usuario').insert({
        'id_usuario': res.user!.id,
        'nombre': nombre,
        'email': email,
      });
    }
  }

  // 5. CERRAR SESIÓN
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut(); // Limpia la sesión de Google en el dispositivo
    } catch (_) {}
    await _supabase.auth.signOut();
  }
}