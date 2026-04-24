import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const List<_StepData> _steps = [
    _StepData(
      number: '01',
      icon: Icons.request_quote_rounded,
      title: 'Solicita tu Cotización',
      description:
          'Completa nuestro formulario en línea o llámanos. En menos de 24 horas recibirás una cotización detallada y sin compromisos.',
      highlight: 'Respuesta en 24h',
    ),
    _StepData(
      number: '02',
      icon: Icons.calendar_month_rounded,
      title: 'Programamos tu Mudanza',
      description:
          'Coordinamos fecha, hora y logística según tus necesidades. Nuestro equipo planifica cada detalle para una mudanza perfecta.',
      highlight: 'Agenda flexible',
    ),
    _StepData(
      number: '03',
      icon: Icons.local_shipping_rounded,
      title: 'Nos Encargamos de Todo',
      description:
          'El día de la mudanza, nuestro equipo profesional se encarga del embalaje, transporte y montaje. Tú solo relájate.',
      highlight: 'Servicio completo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFF141414),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 72 : 112),
      child: ContentWrapper(
        maxWidth: 1320,
        child: Column(
          children: [
            AnimatedSection(
              sectionKey: 'how_header',
              child: Column(
                children: [
                  Text(
                    'CÓMO FUNCIONA',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.accentCoral,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu mudanza en\n3 simples pasos',
                    style: AppTypography.h1Responsive(
                      MediaQuery.of(context).size.width,
                    ).copyWith(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 56 : 80),

            // Steps
            isMobile
                ? _buildMobileSteps()
                : _buildDesktopSteps(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSteps(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _steps.asMap().entries.map((e) {
        final isLast = e.key == _steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedSection(
                  sectionKey: 'step_${e.key}',
                  delay: Duration(milliseconds: e.key * 150),
                  child: _StepCard(
                    data: e.value,
                    index: e.key,
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.accentCoral.withValues(alpha: 0.5),
                    size: 28,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileSteps() {
    return Column(
      children: _steps.asMap().entries.map((e) {
        final isLast = e.key == _steps.length - 1;
        return Column(
          children: [
            AnimatedSection(
              sectionKey: 'step_mobile_${e.key}',
              delay: Duration(milliseconds: e.key * 120),
              child: _StepCard(data: e.value, index: e.key),
            ),
            if (!isLast) ...[
              const SizedBox(height: 12),
              const Icon(
                Icons.arrow_downward_rounded,
                color: AppColors.accentCoral,
                size: 24,
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      }).toList(),
    );
  }
}

class _StepData {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final String highlight;

  const _StepData({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.highlight,
  });
}

class _StepCard extends StatefulWidget {
  final _StepData data;
  final int index;

  const _StepCard({required this.data, required this.index});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.white.withValues(alpha: 0.12)
              : AppColors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AppColors.accentCoral.withValues(alpha: 0.5)
                : AppColors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.data.number,
                  style: AppTypography.display.copyWith(
                    fontSize: 56,
                    color: AppColors.accentCoral.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accentCoral.withValues(alpha: 
                      _isHovered ? 0.25 : 0.15,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: AppColors.accentCoral,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.data.title,
              style: AppTypography.h3.copyWith(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.data.description,
              style: AppTypography.body.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),

            // Highlight chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.accentCoral.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.data.highlight,
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentCoral,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
