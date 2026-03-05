import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeTab extends StatelessWidget {
  final String rol;
  const HomeTab({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping, size: 80, color: AppColors.primaryBlue),
          Text("Panel de $rol", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}