import 'package:flutter/material.dart';
import 'package:my_moobox_app/features/menu/presentation/screens/maps.dart';
import '../../../../../core/theme/app_colors.dart';
import 'home_section_title.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onPointAdded;

  const HomeHeader({super.key, required this.onPointAdded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.dividerGray.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const HomeSectionTitle("PUNTOS FRECUENTES"),
          _buildActionCircle(
            Icons.add,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SelectorUbicacionGratuito()),
              );
              onPointAdded();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, {VoidCallback? onTap, bool small = false}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: EdgeInsets.all(small ? 6 : 10),
        decoration: const BoxDecoration(color: AppColors.accentCoral, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: small ? 14 : 20),
      ),
    );
  }
}
