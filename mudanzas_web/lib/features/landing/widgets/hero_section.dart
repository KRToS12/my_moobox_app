import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/hover_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';
import '../data/landing_data.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onQuotePressed;
  final VoidCallback onServicesPressed;

  const HeroSection({
    super.key,
    required this.onQuotePressed,
    required this.onServicesPressed,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Breakpoints.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkSectionGradient : AppColors.heroGradientLight,
      ),
      child: Stack(
        children: [
          // Background abstract element (grid/dots)
          Positioned(
            right: -100,
            top: -50,
            child: _GridPattern(color: AppColors.accentCoral.withValues(alpha: 0.05)),
          ),
          
          ContentWrapper(
            maxWidth: 1320,
            child: Padding(
              padding: EdgeInsets.only(
                top: isMobile ? 120 : 180,
                bottom: isMobile ? 80 : 140,
              ),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: isMobile 
                    ? _buildMobileLayout(context, width) 
                    : _buildDesktopLayout(context, width),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: _buildMainContent(context, width),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 5,
          child: _buildVisualSection(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainContent(context, width),
        const SizedBox(height: 60),
        Center(child: _buildVisualSection(context)),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, double width) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentCoral.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.2)),
          ),
          child: Text(
            'INTELIGENCIA LOGÍSTICA',
            style: AppTypography.overline.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          LandingData.heroTitle,
          style: AppTypography.displayResponsive(width).copyWith(
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            height: 1.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          LandingData.heroSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            HoverButton(
              label: LandingData.heroCtaPrimary,
              variant: HoverButtonVariant.coral,
              onPressed: widget.onQuotePressed,
              height: 56,
            ),
            HoverButton(
              label: LandingData.heroCtaSecondary,
              variant: HoverButtonVariant.outline,
              onPressed: widget.onServicesPressed,
              height: 56,
            ),
          ],
        ),
        const SizedBox(height: 64),
        _buildStats(context),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: LandingData.stats.map((s) => Padding(
        padding: const EdgeInsets.only(right: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s['value']!,
              style: AppTypography.h2.copyWith(
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              s['label']!,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildVisualSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative ring
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.1), width: 1),
          ),
        ),
        // Main abstract graphic
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.accentCoral.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.local_shipping_outlined, size: 100, color: AppColors.accentCoral.withValues(alpha: 0.8)),
          ),
        ),
        // Floating element
        Positioned(
          top: 20,
          right: 20,
          child: _FloatingCard(
            icon: Icons.verified_rounded,
            label: 'Seguro Activo',
            color: AppColors.statusSuccess,
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          child: _FloatingCard(
            icon: Icons.access_time_filled_rounded,
            label: 'Tiempo Real',
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.dividerLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GridPattern extends StatelessWidget {
  final Color color;
  const _GridPattern({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 600,
      child: CustomPaint(
        painter: _DotPainter(color: color),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final Color color;
  _DotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double i = 0; i < size.width; i += 30) {
      for (double j = 0; j < size.height; j += 30) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
