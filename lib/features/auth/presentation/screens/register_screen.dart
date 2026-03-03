import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para capturar la información
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa los campos obligatorios")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      // Registramos al usuario en Supabase y en la tabla 'usuario'
      await authRepo.registrarCliente(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nombre: _nombreController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Regresa al Login tras el éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cuenta creada con éxito. ¡Inicia sesión!"),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Título principal
              Text(
                "Crea tu cuenta",
                style: GoogleFonts.quicksand(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 50),

              // Campo: Nombre Completo
              _buildInputField(
                controller: _nombreController,
                hint: "Nombre completo",
              ),
              const SizedBox(height: 15),

              // Campo: Correo electrónico
              _buildInputField(
                controller: _emailController,
                hint: "Correo electrónico",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Campo: Teléfono
              _buildInputField(
                controller: _phoneController,
                hint: "Teléfono",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // Campo: Contraseña (con ojo para ver/ocultar)
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Contraseña",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Botón Registrarse
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text("Registrarse"),
                      ),
                    ),
              
              const SizedBox(height: 30),

              // Footer: Iniciar sesión
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.quicksand(color: AppColors.primaryBlue, fontSize: 16),
                    children: const [
                      TextSpan(text: "¿Ya tienes cuenta? "),
                      TextSpan(
                        text: "Inicia sesión",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para mantener el diseño limpio de los inputs
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}