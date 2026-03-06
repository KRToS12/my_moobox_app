import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  // 1. OBTENER ROL (Lógica centralizada para redirección)
  Future<String?> getUsuarioRol(String uid) async {
    try {
      // Prioridad 1: Verificar si es un Operador/Conductor
      final operador = await _supabase
          .from('operador')
          .select()
          .eq('id_operador', uid)
          .maybeSingle();
      if (operador != null) return 'OPERADOR';

      // Prioridad 2: Verificar si es un Cliente
      final cliente = await _supabase
          .from('usuario')
          .select()
          .eq('id_usuario', uid)
          .maybeSingle();
      if (cliente != null) return 'CLIENTE';

      return null;
    } catch (e) {
      return null; // En caso de error de red o permisos
    }
  }

  // 2. REGISTRO MANUAL (Solo para Clientes)
  // Optimizamos para que el TRIGGER de Supabase haga el trabajo pesado
  Future<void> registrarCliente({
    required String email, 
    required String password, 
    required String nombre,
    required String telefono,
  }) async {
    try {
      // Al usar 'data', enviamos metadatos que el Trigger de SQL leerá
      // Esto crea el usuario en Auth y en la tabla 'usuario' en un solo paso
      final res = await _supabase.auth.signUp(
        email: email, 
        password: password,
        data: {
          'full_name': nombre,
          'phone': telefono, // Esta clave la usa el Trigger para llenar la columna 'numero'
        },
      );
      
      if (res.user == null) {
        throw Exception("No se pudo completar el registro en el servidor.");
      }
      
      // NOTA: No hacemos .from('usuario').insert() aquí para evitar el Error 500
      // por llave duplicada (Duplicate Key), ya que el Trigger lo hace solo.
      
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  // 3. LOGIN TRADICIONAL (Email/Password)
  Future<String> login(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email, 
        password: password
      );
      
      if (res.user == null) throw Exception("Credenciales inválidas.");

      final rol = await getUsuarioRol(res.user!.id);
      if (rol == null) throw Exception("Perfil de usuario no encontrado.");

      return rol;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 4. LOGIN CON GOOGLE (Móvil Nativo)
  Future<String> signInWithGoogleMobile() async {
    try {
      final String webClientId = dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');

      if (webClientId.isEmpty) {
        throw Exception("Error de configuración: ID de Google no encontrado en .env");
      }

      final googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception("Operación cancelada por el usuario");

      final googleAuth = await googleUser.authentication;

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (res.user == null) throw Exception("Fallo en la conexión con Supabase");

      // Verificamos si ya existe el perfil en la tabla 'usuario'
      final rol = await getUsuarioRol(res.user!.id);
      
      // Si el usuario de Google es nuevo, el Trigger de SQL debería haberlo creado.
      // Si por alguna razón no existe, lo creamos preventivamente:
      if (rol == null) {
        await _supabase.from('usuario').insert({
          'id_usuario': res.user!.id,
          'nombre': res.user!.userMetadata?['full_name'] ?? 'Usuario Google',
          'email': res.user!.email,
          'numero': '', 
        });
        return 'CLIENTE';
      }
      
      return rol;
    } catch (e) {
      throw Exception("Error en Google Sign-In: $e");
    }
  }

  // 5. CERRAR SESIÓN
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut(); 
    } catch (_) {}
    await _supabase.auth.signOut();
  }
}