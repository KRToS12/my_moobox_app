import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';
import '../data/landing_data.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 120),
      child: ContentWrapper(
        maxWidth: 1200,
        child: Column(
          children: [
            AnimatedSection(
              sectionKey: 'services_header',
              child: Column(
                children: [
                  Text(
                    'NUESTROS SERVICIOS',
                    style: AppTypography.overline.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Soluciones Logísticas\nHechas a Medida',
                    style: AppTypography.h1Responsive(MediaQuery.of(context).size.width),
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
      children: LandingData.services.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _ServiceCard(
              title: e.value['title'],
              desc: e.value['desc'],
              icon: e.value['icon'],
              features: e.value['features'],
              index: e.key,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      children: LandingData.services.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _ServiceCard(
          title: s['title'],
          desc: s['desc'],
          icon: s['icon'],
          features: s['features'],
          index: 0,
        ),
      )).toList(),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;
  final List<String> features;
  final int index;

  const _ServiceCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.features,
    required this.index,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isHovered ? AppColors.accentCoral : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.dividerLight),
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(color: AppColors.accentCoral.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 10))
            else
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _isHovered ? AppColors.accentCoral : AppColors.accentCoral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: _isHovered ? Colors.white : AppColors.accentCoral, size: 28),
            ),
            const SizedBox(height: 24),
            Text(widget.title, style: AppTypography.h3.copyWith(fontSize: 22)),
            const SizedBox(height: 12),
            Text(
              widget.desc,
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            ...widget.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.accentCoral, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f,
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
