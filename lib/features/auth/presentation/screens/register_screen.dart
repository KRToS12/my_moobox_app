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
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Lógica para registro con Google
  void _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    try {
      await AuthRepository().signInWithGoogleMobile();
      // El AuthWrapper se encargará de redirigir al Dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error con Google: $e"), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      await authRepo.registrarCliente(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nombre: _nombreController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
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
      backgroundColor: AppColors.background,
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
              const SizedBox(height: 10),
              Text(
                "Crea tu cuenta",
                style: GoogleFonts.quicksand(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 40),

              _buildInputField(controller: _nombreController, hint: "Nombre completo"),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _emailController, 
                hint: "Correo electrónico", 
                keyboardType: TextInputType.emailAddress
              ),
              const SizedBox(height: 15),
              _buildInputField(
                controller: _phoneController, 
                hint: "Teléfono", 
                keyboardType: TextInputType.phone
              ),
              const SizedBox(height: 15),
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
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text("Registrarse"),
                      ),
                    ),
              
              const SizedBox(height: 25),

              // SECCIÓN SOCIAL
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("O regístrate con", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      text: "Google", 
                      color: AppColors.primaryBlue, 
                      textColor: Colors.white,
                      icon: Icons.g_mobiledata,
                      onTap: _handleGoogleRegister,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _socialButton(
                      text: "Apple", 
                      color: Colors.white, 
                      textColor: AppColors.primaryBlue,
                      icon: Icons.apple,
                      hasBorder: true,
                      onTap: () {}, // Implementar Apple login si es necesario
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Footer: Regresar al Login
              TextButton(
                onPressed: () {
                  // Navigator.pop devuelve al usuario a la pantalla anterior (LoginScreen)
                  Navigator.pop(context); 
                },
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.quicksand(
                      color: AppColors.primaryBlue, 
                      fontSize: 16
                    ),
                    children: const [
                      TextSpan(text: "¿Ya tienes cuenta? "),
                      TextSpan(
                        text: "Inicia sesión",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, 
                        ),
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

  // Widget auxiliar para botones sociales
  Widget _socialButton({
    required String text, 
    required Color color, 
    required Color textColor, 
    required IconData icon, 
    required VoidCallback onTap,
    bool hasBorder = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: AppColors.primaryBlue.withOpacity(0.2)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

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