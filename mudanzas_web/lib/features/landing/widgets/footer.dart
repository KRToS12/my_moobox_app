import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static const List<_FooterLink> _services = [
    _FooterLink('Mudanza Residencial', '#'),
    _FooterLink('Mudanza Comercial', '#'),
  ];

  static const List<_FooterLink> _company = [
    _FooterLink('Nosotros', '#'),
    _FooterLink('Cotización', '#'),
    _FooterLink('Blog', '#'),
    _FooterLink('Trabaja con nosotros', '#'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFF141414), // Fondo oscuro neutral
      child: Column(
        children: [
          // Main footer content
          ContentWrapper(
            maxWidth: 1320,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 56 : 80),
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),

          // Bottom bar
          ContentWrapper(
            maxWidth: 1320,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '© ${DateTime.now().year} Moobox. Todos los derechos reservados.',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _FooterTextLink(label: 'Privacidad'),
                      const SizedBox(width: 20),
                      _FooterTextLink(label: 'Términos'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column
        Expanded(
          flex: 4,
          child: _buildBrandColumn(),
        ),
        const SizedBox(width: 40),

        // Services
        Expanded(
          flex: 2,
          child: _buildLinkColumn('Servicios', _services),
        ),

        // Company
        Expanded(
          flex: 2,
          child: _buildLinkColumn('Empresa', _company),
        ),

        // Contact
        Expanded(
          flex: 3,
          child: _buildContactColumn(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandColumn(),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLinkColumn('Servicios', _services)),
            const SizedBox(width: 24),
            Expanded(child: _buildLinkColumn('Empresa', _company)),
          ],
        ),
        const SizedBox(height: 40),
        _buildContactColumn(),
      ],
    );
  }

  Widget _buildBrandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/images/LOGOsf.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moobox',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Mudanzas & Logística',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentCoral,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Plataforma de logística y transporte. Mudanzas residenciales y comerciales con la tranquilidad que mereces.',
          style: AppTypography.body.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),

        // Social icons
        Row(
          children: [
            _SocialIcon(
              icon: Icons.facebook_rounded,
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            _SocialIcon(
              icon: Icons.camera_alt_outlined,
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            _SocialIcon(
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkColumn(String title, List<_FooterLink> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.white,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FooterTextLink(label: l.label),
            )),
      ],
    );
  }

  Widget _buildContactColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacto',
          style: AppTypography.h4.copyWith(
            color: AppColors.white,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        _ContactRow(icon: Icons.phone_rounded, text: '+56 9 1234 5678'),
        const SizedBox(height: 12),
        _ContactRow(icon: Icons.email_rounded, text: 'contacto@moobox.cl'),
        const SizedBox(height: 12),
        _ContactRow(
          icon: Icons.location_on_rounded,
          text: 'Santiago, Chile',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentCoral.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.accentCoral,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Lun–Sáb, 8:00 – 20:00',
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentCoral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink {
  final String label;
  final String href;

  const _FooterLink(this.label, this.href);
}

class _FooterTextLink extends StatefulWidget {
  final String label;

  const _FooterTextLink({required this.label});

  @override
  State<_FooterTextLink> createState() => _FooterTextLinkState();
}

class _FooterTextLinkState extends State<_FooterTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: AppTypography.body.copyWith(
          color: _isHovered
              ? AppColors.accentCoral
              : Colors.white.withValues(alpha: 0.55),
          fontSize: 14,
        ),
        child: Text(widget.label),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialIcon({required this.icon, required this.onPressed});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.accentCoral
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? AppColors.accentCoral
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            widget.icon,
            color: AppColors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentCoral, size: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: AppTypography.body.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
