import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class SelectionOrderScreen extends StatefulWidget {
  const SelectionOrderScreen({super.key});
  @override
  State<SelectionOrderScreen> createState() => _SelectionOrderScreenState();
}

class _SelectionOrderScreenState extends State<SelectionOrderScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoadingIA = true;
  bool _isSending = false;
  ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    _inicializarSistema();
  }

  Future<void> _inicializarSistema() async {
    try {
      // 1. Cargamos datos de vehículos desde Supabase
      final data = await Supabase.instance.client.from('vehiculos').select();
      String flotaContexto = data.map((v) => "- ${v['nombre']} (${v['capacidad_tn']} TN)").join("\n");

      // 2. Cargamos API Key correctamente del .env
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
      if (apiKey.isEmpty) throw "Error: API Key no encontrada.";

      // 3. Iniciamos el modelo con instrucciones de Moobox
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: apiKey,
        systemInstruction: Content.system(
          "Eres el Experto de Moobox Bolivia. Flota disponible:\n$flotaContexto\n\n"
          "Diesel: 9.8 BOB/L. Responde con JSON [[[...]]] si hay recomendación."
        ),
      );

      setState(() {
        _chatSession = model.startChat();
        _isLoadingIA = false;
        _messages.add(ChatMessage(text: "¡Hola! Ya conozco nuestra flota. ¿Qué necesitas mover?", isUser: false));
      });
    } catch (e) {
      setState(() => _isLoadingIA = false);
      debugPrint("Fallo al iniciar: $e");
    }
  }

  Future<void> _enviarMensaje({Uint8List? imageBytes}) async {
    if (_controller.text.isEmpty && imageBytes == null) return;
    if (_chatSession == null) return;

    final prompt = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: prompt, isUser: true, imageBytes: imageBytes));
      _isSending = true;
      _controller.clear();
    });

    try {
      final content = imageBytes != null 
        ? Content.multi([TextPart(prompt.isEmpty ? "Analiza esta carga" : prompt), DataPart('image/jpeg', imageBytes)])
        : Content.text(prompt);

      final response = await _chatSession!.sendMessage(content);
      
      setState(() {
        _messages.add(ChatMessage(text: response.text ?? "No obtuve respuesta.", isUser: false));
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      _messages.add(ChatMessage(text: "Error técnico: $e", isUser: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("MOOBOX IA CHAT")),
      body: _isLoadingIA 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) => _buildBubble(_messages[i]),
                ),
              ),
              _buildInput(),
            ],
          ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primaryBlue : AppColors.textBlack,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.imageBytes != null) 
              Image.memory(msg.imageBytes!, height: 150, fit: BoxFit.cover), // FUNCIONA EN WEB
            Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.camera_alt), onPressed: () async {
            final f = await _picker.pickImage(source: ImageSource.camera);
            if (f != null) _enviarMensaje(imageBytes: await f.readAsBytes());
          }),
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Pregunta a Moobox..."))),
          IconButton(icon: const Icon(Icons.send), onPressed: () => _enviarMensaje()),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final Uint8List? imageBytes;
  ChatMessage({required this.text, required this.isUser, this.imageBytes});
}