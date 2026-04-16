import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PricingConfig {
  final double tarifaBaseB0;
  final double precioDieselLitro;
  final double consumoKmLitro;
  final double costoEstibadorBase;
  final double factorPisoEscalera;
  final double coeficienteVolumenTon;
  final double margenContingencia;

  PricingConfig({
    required this.tarifaBaseB0,
    required this.precioDieselLitro,
    required this.consumoKmLitro,
    required this.costoEstibadorBase,
    required this.factorPisoEscalera,
    required this.coeficienteVolumenTon,
    required this.margenContingencia,
  });

  factory PricingConfig.fromMap(Map<String, dynamic> map) {
    return PricingConfig(
      tarifaBaseB0: (map['tarifa_base_b0'] as num).toDouble(),
      precioDieselLitro: (map['precio_diesel_litro'] as num).toDouble(),
      consumoKmLitro: (map['consumo_km_litro'] as num).toDouble(),
      costoEstibadorBase: (map['costo_estibador_base'] as num).toDouble(),
      factorPisoEscalera: (map['factor_piso_escalera'] as num).toDouble(),
      coeficienteVolumenTon: (map['coeficiente_volumen_ton'] as num).toDouble(),
      margenContingencia: (map['margen_contingencia'] as num).toDouble(),
    );
  }
}

class PricingEngine {
  final _supabase = Supabase.instance.client;
  final String _orsApiKey = dotenv.env['ORS_API_KEY'] ?? "";
  
  PricingConfig? _config;

  /// Fetches the pricing configuration from Supabase 'configuracion' table.
  Future<void> fetchConfig() async {
    try {
      final data = await _supabase
          .from('configuracion')
          .select()
          .eq('id', 1)
          .single();
      _config = PricingConfig.fromMap(data);
    } catch (e) {
      print('Error fetching PricingConfig: $e');
      // Fallback defaults if table is empty or error
      _config = PricingConfig(
        tarifaBaseB0: 150.0,
        precioDieselLitro: 9.8,
        consumoKmLitro: 0.15,
        costoEstibadorBase: 80.0,
        factorPisoEscalera: 15.0,
        coeficienteVolumenTon: 50.0,
        margenContingencia: 1.10,
      );
    }
  }

  Future<double> getRouteDistance(LatLng start, LatLng end) async {
    if (_orsApiKey.isEmpty) return 0.0;

    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _orsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "coordinates": [
            [start.longitude, start.latitude],
            [end.longitude, end.latitude]
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double distanceMeters = data['routes'][0]['summary']['distance'];
        return distanceMeters / 1000.0;
      } else {
        print('ORS Error: ${response.body}');
        return 0.0;
      }
    } catch (e) {
      print('Error calling ORS: $e');
      return 0.0;
    }
  }

  double calcularCotizacion({
    required double distanciaKm,
    required double volumenTon,
    required int numPisosTotal, // Sum of origin and destination floors
    required int numEstibadores,
  }) {
    if (_config == null) return 0.0;

    double costoTransporte = distanciaKm * (_config!.precioDieselLitro * _config!.consumoKmLitro);


    double costoManoObra = (numEstibadores * _config!.costoEstibadorBase) + 
                          (numPisosTotal * _config!.factorPisoEscalera);

    double subtotal = _config!.tarifaBaseB0 + 
                      costoTransporte + 
                      (volumenTon * _config!.coeficienteVolumenTon) + 
                      costoManoObra;

    double total = subtotal * _config!.margenContingencia;

    return double.parse(total.toStringAsFixed(2));
  }
}
