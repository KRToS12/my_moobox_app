import 'package:flutter/material.dart';

class LandingData {
  // Hero Section
  static const String heroTitle = 'Mudanzas\nPremium.';
  static const String heroSubtitle = 'Logística inteligente para tu hogar y empresa. Conectamos tus sueños con su nuevo destino.';
  static const String heroCtaPrimary = 'Cotizar Ahora';
  static const String heroCtaSecondary = 'Nuestra Flota';

  // Stats
  static const List<Map<String, String>> stats = [
    {'value': '15k+', 'label': 'Viajes realizados'},
    {'value': '99%', 'label': 'Clientes felices'},
    {'value': '24/7', 'label': 'Soporte activo'},
  ];

  // Services
  static const List<Map<String, dynamic>> services = [
    {
      'title': 'Mudanza Residencial',
      'desc': 'Traslados locales y nacionales con cuidado extremo de tus pertenencias.',
      'icon': Icons.home_rounded,
      'features': ['Carga asegurada', 'Personal experto', 'Montaje incluido'],
    },
    {
      'title': 'Mudanza Comercial',
      'desc': 'Logística corporativa eficiente para minimizar el tiempo de inactividad de su negocio.',
      'icon': Icons.business_rounded,
      'features': ['Planificación 360', 'Equipamiento especial', 'Gestión documental'],
    },
  ];

  // Vehicles
  static const List<Map<String, dynamic>> vehicles = [
    {
      'name': 'Pickup Express',
      'capacity': '800 KG',
      'ideal': '1-2 Ambientes',
      'icon': Icons.shutter_speed_rounded,
    },
    {
      'name': 'Furgón Mediano',
      'capacity': '3.5 Tons',
      'ideal': '3-4 Ambientes',
      'icon': Icons.local_shipping_rounded,
    },
    {
      'name': 'Camión Pesado',
      'capacity': '10 Tons',
      'ideal': 'Casas / Oficinas grandes',
      'icon': Icons.fire_truck_rounded,
    },
  ];

  // Testimonials
  static const List<Map<String, String>> testimonials = [
    {
      'name': 'Roberto Mendez',
      'role': 'Gerente Comercial',
      'text': 'Excelente servicio, muy puntuales y cuidadosos con todo el mobiliario de la oficina.',
    },
    {
      'name': 'Camila Silva',
      'role': 'Diseñadora',
      'text': 'La mejor experiencia en mudanzas que he tenido. El color rosa salmon de la marca me encanta!',
    },
  ];
}
