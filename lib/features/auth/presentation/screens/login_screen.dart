import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/app.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:my_moobox_app/data/repositories/auth_repository.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      final rol = await authRepo.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // El AuthWrapper detectará el cambio y redirigirá al dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar sesión"), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // LOGO OFICIAL DE MOOBOX
              Image.asset(
                'assets/images/LOGOsf.png', 
                height: 220, 
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40), // Espacio antes de los campos de texto
              
              // Título y Subtítulo
              Text(
                "MOOBOX", 
                style: GoogleFonts.quicksand(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primaryBlue
                )
              ),
              Text(
                "Donde vayas, llevamos tu mundo contigo !!.", 
                style: GoogleFonts.quicksand(
                  fontSize: 16, 
                  color: AppColors.textSecondary
                )
              ),
              const SizedBox(height: 40),

              // Campos de Texto
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                  prefixIcon: null, // Diseño limpio de la imagen
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  suffixIcon: Icon(Icons.mic, color: AppColors.textSecondary.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Login
              _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text("LOG IN"),
                    ),
                  ),
              
              const SizedBox(height: 20),

              // Links de Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {}, 
                    child: const Text("Forgot Password?", style: TextStyle(color: AppColors.textSecondary))
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    }, 
                    child: const Text("Create Account", style: TextStyle(color: AppColors.textSecondary))
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Botones Sociales
              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      text: "Sign in with Google", 
                      color: AppColors.primaryBlue, 
                      textColor: Colors.white,
                      icon: Icons.g_mobiledata,
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required String text, required Color color, required Color textColor, required IconData icon, bool hasBorder = false}) {
    return Container(
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
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}