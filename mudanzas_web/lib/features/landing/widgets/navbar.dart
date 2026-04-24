import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/hover_button.dart';
import '../../../../responsive/breakpoints.dart';

class _NavItem {
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.label, this.onTap);
}

class LandingNavbar extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onServicesPressed;
  final VoidCallback onHowItWorksPressed;
  final VoidCallback onTestimonialsPressed;
  final VoidCallback onContactPressed;
  final VoidCallback onQuotePressed;

  const LandingNavbar({
    super.key,
    required this.scrollController,
    required this.onServicesPressed,
    required this.onHowItWorksPressed,
    required this.onTestimonialsPressed,
    required this.onContactPressed,
    required this.onQuotePressed,
  });

  @override
  State<LandingNavbar> createState() => _LandingNavbarState();
}

class _LandingNavbarState extends State<LandingNavbar> {
  bool _isScrolled = false;
  int _hoveredIndex = -1;
  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = [
      _NavItem('Servicios', widget.onServicesPressed),
      _NavItem('Cómo funciona', widget.onHowItWorksPressed),
      _NavItem('Testimonios', widget.onTestimonialsPressed),
      _NavItem('Contacto', widget.onContactPressed),
    ];
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final scrolled = widget.scrollController.offset > 40;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: Breakpoints.horizontalPadding(context),
        vertical: _isScrolled ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: _isScrolled
            ? AppColors.backgroundDark.withValues(alpha: 0.98)
            : Colors.transparent,
        boxShadow: _isScrolled
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(
        children: [
          _MooboxLogo(),
          const Spacer(),

          // Nav items (desktop)
          if (!isMobile)
            Row(
              children: _navItems.asMap().entries.map((e) {
                final isHovered = _hoveredIndex == e.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredIndex = e.key),
                    onExit: (_) => setState(() => _hoveredIndex = -1),
                    child: GestureDetector(
                      onTap: e.value.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.value.label,
                              style: AppTypography.navItem.copyWith(
                                color: isHovered ? AppColors.accentCoral : AppColors.white.withValues(alpha: 0.85),
                                fontWeight: isHovered ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 2,
                              width: isHovered ? 28 : 0,
                              decoration: BoxDecoration(
                                color: AppColors.accentCoral,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(width: 8),

          // ── Toggle de tema (sol / luna) ──────────────────────────
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) {
              final isLight = mode == ThemeMode.light;
              return Tooltip(
                message: isLight ? 'Activar modo oscuro' : 'Activar modo claro',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: themeNotifier.toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          if (!isMobile)
            HoverButton(
              label: 'Cotizar Ahora',
              variant: HoverButtonVariant.coral,
              height: 44,
              borderRadius: 10,
              onPressed: widget.onQuotePressed,
            )
          else
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.white, size: 26),
              onPressed: () => _showMobileMenu(context),
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _MooboxLogo(),
              const SizedBox(height: 28),
              ..._navItems.map((item) => _MobileNavItem(
                    label: item.label,
                    onTap: () { Navigator.pop(ctx); item.onTap(); },
                  )),
              const SizedBox(height: 16),
              // Toggle en móvil
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) {
                  final isLight = mode == ThemeMode.light;
                  return GestureDetector(
                    onTap: themeNotifier.toggle,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: AppColors.accentCoral, size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isLight ? 'Cambiar a modo oscuro' : 'Cambiar a modo claro',
                            style: AppTypography.body.copyWith(
                              color: AppColors.white, fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              HoverButton(
                label: 'Cotizar Ahora',
                variant: HoverButtonVariant.coral,
                width: double.infinity,
                icon: Icons.arrow_forward_rounded,
                onPressed: () { Navigator.pop(ctx); widget.onQuotePressed(); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MooboxLogo extends StatelessWidget {
  const _MooboxLogo();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(4),
          child: Image.asset('assets/images/LOGOsf.png', fit: BoxFit.contain, filterQuality: FilterQuality.high),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Moobox', style: AppTypography.h3.copyWith(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.0)),
            Text('Mudanzas & Logística', style: AppTypography.caption.copyWith(color: AppColors.accentCoral, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MobileNavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _MobileNavItem({required this.label, required this.onTap});
  @override
  State<_MobileNavItem> createState() => _MobileNavItemState();
}
class _MobileNavItemState extends State<_MobileNavItem> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.white.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(widget.label, style: AppTypography.h4.copyWith(color: _isHovered ? AppColors.accentCoral : AppColors.white, fontSize: 17)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, color: _isHovered ? AppColors.accentCoral : AppColors.white.withValues(alpha: 0.4), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
