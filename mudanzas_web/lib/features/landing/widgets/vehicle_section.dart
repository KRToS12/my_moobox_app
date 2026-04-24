import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';
import '../data/landing_data.dart';

class VehicleSection extends StatelessWidget {
  final VoidCallback onQuotePressed;
  const VehicleSection({super.key, required this.onQuotePressed});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF020617) : const Color(0xFF0F172A),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 120),
      child: ContentWrapper(
        maxWidth: 1200,
        child: Column(
          children: [
            AnimatedSection(
              sectionKey: 'vehicle_header',
              child: Column(
                children: [
                  Text(
                    'NUESTRA FLOTA',
                    style: AppTypography.overline.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Equipamiento de Vanguardia',
                    style: AppTypography.h1Responsive(MediaQuery.of(context).size.width).copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
            isMobile ? _buildMobileGrid() : _buildDesktopGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: LandingData.vehicles.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _VehicleCard(
              name: e.value['name'],
              capacity: e.value['capacity'],
              ideal: e.value['ideal'],
              icon: e.value['icon'],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      children: LandingData.vehicles.map((v) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _VehicleCard(
          name: v['name'],
          capacity: v['capacity'],
          ideal: v['ideal'],
          icon: v['icon'],
        ),
      )).toList(),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  final String name;
  final String capacity;
  final String ideal;
  final IconData icon;

  const _VehicleCard({required this.name, required this.capacity, required this.ideal, required this.icon});

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _isHovered ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isHovered ? AppColors.accentCoral : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              widget.name,
              style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'CAPACIDAD: ${widget.capacity}',
              style: AppTypography.overline.copyWith(color: AppColors.accentCoral, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              widget.ideal,
              style: AppTypography.bodySm.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
