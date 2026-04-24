import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/trust_badge.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';
import '../data/landing_data.dart';

class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 120),
      child: ContentWrapper(
        maxWidth: 1200,
        child: Column(
          children: [
            // Header
            AnimatedSection(
              sectionKey: 'trust_header',
              child: Column(
                children: [
                  Text(
                    'CONFIANZA TOTAL',
                    style: AppTypography.overline.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Respaldo y Seguridad\nen cada kilómetro',
                    style: AppTypography.h1Responsive(width),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),

            // Badges Grid
            _buildBadges(context, isMobile),
            
            const SizedBox(height: 80),
            
            // Interactive Stats Strip
            _buildStatsStrip(context, isMobile, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(BuildContext context, bool isMobile) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        _SimpleTrustBadge(
          icon: Icons.verified_user_rounded,
          title: 'Carga Asegurada',
          desc: 'Protección total desde origen hasta destino.',
        ),
        _SimpleTrustBadge(
          icon: Icons.support_agent_rounded,
          title: 'Soporte 24/7',
          desc: 'Equipo dedicado para resolver tus dudas.',
        ),
        _SimpleTrustBadge(
          icon: Icons.security_update_good_rounded,
          title: 'Seguimiento GPS',
          desc: 'Monitorea tu mudanza en tiempo real.',
        ),
      ],
    );
  }

  Widget _buildStatsStrip(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.dividerLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 40, offset: const Offset(0, 10)),
        ],
      ),
      child: isMobile 
        ? Column(children: LandingData.stats.map((s) => _StatItem(value: s['value']!, label: s['label']!)).toList())
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: LandingData.stats.map((s) => _StatItem(value: s['value']!, label: s['label']!)).toList(),
          ),
    );
  }
}

class _SimpleTrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _SimpleTrustBadge({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentCoral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.accentCoral, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTypography.h4.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            desc,
            style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.display.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppColors.accentCoral,
              letterSpacing: -1.5,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
