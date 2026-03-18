import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIAssistantService {
  // CORRECCIÓN: Usamos el nombre de la variable definida en tu .env
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ""; 
  late final GenerativeModel _model;

  AIAssistantService(String contextoFlota) {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1,
      ),
      systemInstruction: Content.system(
        "Eres el Especialista Logístico de Moobox en Bolivia. "
        "Ayuda al usuario a elegir entre estos vehículos disponibles:\n$contextoFlota\n\n"
        "REGLAS: Diesel 9.8 BOB/L. Estibadores: <3TN (50 BOB), 3-10TN (85 BOB), >10TN (125 BOB). "
        "Si el usuario decide una carga, responde SIEMPRE incluyendo al final un JSON así: "
        "[[[ { 'vehiculo_ideal': '...', 'peso_tn': 0.0, 'estibadores': 0, 'justificacion': '...' } ]]]"
      ),
    );
  }

  // Iniciar una sesión de chat
  ChatSession startChat() => _model.startChat();
}