import 'package:flutter/material.dart';
import '../widgets/hero_section.dart';
import '../widgets/gallery_section.dart';
import '../widgets/services_section.dart';
import '../widgets/vehicle_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/trust_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/quote_form_section.dart';
import '../widgets/footer.dart';
import '../widgets/navbar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  // GlobalKeys para cada sección
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _vehicleKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _trustKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _quoteKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Contenido scrollable ─────────────────────────────────────────
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // 1. Hero
                KeyedSubtree(key: _heroKey, child: HeroSection(onQuotePressed: () => _scrollTo(_quoteKey), onServicesPressed: () => _scrollTo(_servicesKey))),

                // 2. Galería de imágenes (justo bajo el hero)
                const GallerySection(),

                // 3. Servicios
                KeyedSubtree(key: _servicesKey, child: const ServicesSection()),

                // 4. Selección de vehículos (sección de marca, siempre oscura)
                KeyedSubtree(key: _vehicleKey, child: VehicleSection(onQuotePressed: () => _scrollTo(_quoteKey))),

                // 5. Cómo funciona
                KeyedSubtree(key: _howItWorksKey, child: const HowItWorksSection()),

                // 6. Confianza
                KeyedSubtree(key: _trustKey, child: const TrustSection()),

                // 7. Testimonios
                KeyedSubtree(key: _testimonialsKey, child: const TestimonialsSection()),

                // 8. Formulario de cotización
                KeyedSubtree(key: _quoteKey, child: const QuoteFormSection()),

                // 9. Footer
                const FooterSection(),
              ],
            ),
          ),

          // ── Navbar sticky ────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: LandingNavbar(
              scrollController: _scrollController,
              onServicesPressed: () => _scrollTo(_servicesKey),
              onHowItWorksPressed: () => _scrollTo(_howItWorksKey),
              onTestimonialsPressed: () => _scrollTo(_testimonialsKey),
              onContactPressed: () => _scrollTo(_quoteKey),
              onQuotePressed: () => _scrollTo(_quoteKey),
            ),
          ),

          // ── FAB WhatsApp ─────────────────────────────────────────────────
          Positioned(
            bottom: 32, right: 32,
            child: _WhatsAppFab(onPressed: () => _scrollTo(_quoteKey)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _WhatsAppFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _WhatsAppFab({required this.onPressed});
  @override
  State<_WhatsAppFab> createState() => _WhatsAppFabState();
}

class _WhatsAppFabState extends State<_WhatsAppFab> {
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
          padding: EdgeInsets.symmetric(horizontal: _isHovered ? 20 : 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: const Color(0xFF25D366).withValues(alpha: 0.35), blurRadius: _isHovered ? 20 : 12, offset: const Offset(0, 6))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _isHovered
                    ? const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('Chateanos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
