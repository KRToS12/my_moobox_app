import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _obscurePassword = true;


  // 1. FUNCIÓN PARA LOGIN CON GOOGLE
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      await authRepo.signInWithGoogleMobile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      await authRepo.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al iniciar sesión"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/LOGOsf.png', height: 270, fit: BoxFit.contain),
              const SizedBox(height: 40),
              Text("MOOBOX", style: GoogleFonts.quicksand(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              Text("Donde vayas, llevamos tu mundo contigo !!.", style: GoogleFonts.quicksand(fontSize: 22, color: AppColors.textSecondary)),
              const SizedBox(height: 40),

              // Campos de Texto
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword ?? true,

                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      (_obscurePassword ?? true) ? Icons.visibility_outlined : Icons.visibility_off_outlined,

                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              (_isLoading ?? false) 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _handleLogin, child: const Text("LOG IN")),
                  ),
              
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () {}, child: const Text("Forgot Password?", style: TextStyle(color: AppColors.textSecondary))),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())), 
                    child: const Text("Create Account", style: TextStyle(color: AppColors.textSecondary))
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // BOTONES SOCIALES FUNCIONALES
              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      text: "Google", 
                      color: AppColors.primaryBlue, 
                      textColor: Colors.white,
                      icon: Icons.g_mobiledata,
                      onTap: _handleGoogleLogin, // <--- Conexión con la lógica
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
                      onTap: () {}, // Por implementar
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

  // Widget _socialButton actualizado con GestureDetector
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
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}