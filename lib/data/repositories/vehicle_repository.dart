import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleRepository {
  final _supabase = Supabase.instance.client;

  // Lógica centralizada para obtener vehículos activos
  Future<List<Map<String, dynamic>>> getActiveVehicles() async {
    try {
      final data = await _supabase
          .from('vehiculos')
          .select()
          .eq('estado_servicio', true); // Filtro por estado de servicio
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error al cargar vehículos: $e');
    }
  }
}