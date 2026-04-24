import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';

/// Sección de galería fotorrealista con imágenes de mudanzas.
/// Grid 3 columnas (desktop) / 2 columnas (tablet) / 1 columna (mobile).
class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  static const List<_GalleryItem> _items = [
    _GalleryItem(
      imagePath: 'assets/images/gallery_truck.png',
      label: 'Flota Profesional',
      sublabel: 'Camiones equipados y asegurados',
    ),
    _GalleryItem(
      imagePath: 'assets/images/gallery_packing.png',
      label: 'Embalaje Experto',
      sublabel: 'Cada objeto protegido con cuidado',
    ),
    _GalleryItem(
      imagePath: 'assets/images/gallery_furniture.png',
      label: 'Manejo de Muebles',
      sublabel: 'Sin rasguños, sin daños',
    ),
    _GalleryItem(
      imagePath: 'assets/images/gallery_storage.png',
      label: 'Almacenamiento Seguro',
      sublabel: 'Bodega climatizada 24/7',
    ),
    _GalleryItem(
      imagePath: 'assets/images/gallery_team.png',
      label: 'Nuestro Equipo',
      sublabel: 'Profesionales certificados',
    ),
    _GalleryItem(
      imagePath: 'assets/images/gallery_delivery.png',
      label: 'Carga Optimizada',
      sublabel: 'Cada centímetro aprovechado',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: cs.surface,
      padding: EdgeInsets.only(bottom: isMobile ? 72 : 112),
      child: ContentWrapper(
        maxWidth: 1400,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
              child: AnimatedSection(
                sectionKey: 'gallery_header',
                child: Column(
                  children: [
                    Text('GALERÍA', style: AppTypography.overline),
                    const SizedBox(height: 16),
                    Text(
                      'Cada mudanza,\nuna historia de éxito',
                      style: AppTypography.h1Responsive(MediaQuery.of(context).size.width).copyWith(color: cs.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mira en acción a nuestro equipo y conoce la calidad de nuestro trabajo.',
                      style: AppTypography.bodyLarge.copyWith(color: cs.onSurface.withValues(alpha: 0.55)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isMobile ? 40 : 64),

            // Grid
            _buildGrid(context, isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: _items.asMap().entries.map((e) => Padding(
              padding: EdgeInsets.only(bottom: e.key < _items.length - 1 ? 16 : 0),
              child: AnimatedSection(
                sectionKey: 'gallery_${e.key}',
                delay: Duration(milliseconds: e.key * 80),
                child: _GalleryCard(item: e.value, height: 220),
              ),
            )).toList(),
      );
    }

    if (isTablet) {
      return Column(
        children: [
          _buildRow(_items.sublist(0, 2), [0, 1]),
          const SizedBox(height: 16),
          _buildRow(_items.sublist(2, 4), [2, 3]),
          const SizedBox(height: 16),
          _buildRow(_items.sublist(4, 6), [4, 5]),
        ],
      );
    }

    // Desktop: 3 columnas, 2 filas
    return Column(
      children: [
        _buildRow3(_items.sublist(0, 3), [0, 1, 2], height: 300),
        const SizedBox(height: 16),
        _buildRow3(_items.sublist(3, 6), [3, 4, 5], height: 280),
      ],
    );
  }

  Widget _buildRow(List<_GalleryItem> items, List<int> indices) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.asMap().entries.map((e) {
          final globalIdx = indices[e.key];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8, right: e.key == items.length - 1 ? 0 : 8),
              child: AnimatedSection(
                sectionKey: 'gallery_$globalIdx',
                delay: Duration(milliseconds: globalIdx * 80),
                child: _GalleryCard(item: e.value, height: 240),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow3(List<_GalleryItem> items, List<int> indices, {required double height}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final globalIdx = indices[e.key];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8, right: e.key == items.length - 1 ? 0 : 8),
            child: AnimatedSection(
              sectionKey: 'gallery_$globalIdx',
              delay: Duration(milliseconds: globalIdx * 80),
              child: _GalleryCard(item: e.value, height: height),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GalleryItem {
  final String imagePath;
  final String label;
  final String sublabel;
  const _GalleryItem({required this.imagePath, required this.label, required this.sublabel});
}

// ─────────────────────────────────────────────────────────────────────────────
class _GalleryCard extends StatefulWidget {
  final _GalleryItem item;
  final double height;
  const _GalleryCard({required this.item, required this.height});
  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              AnimatedScale(
                scale: _isHovered ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: Image.asset(
                  widget.item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryBlueDeep,
                    child: const Icon(Icons.image_rounded, color: Colors.white38, size: 48),
                  ),
                ),
              ),

              // Gradiente overlay siempre visible (abajo)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: widget.height * 0.55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              ),

              // Overlay azul al hover
              AnimatedOpacity(
                opacity: _isHovered ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(color: AppColors.primaryBlueDeep),
              ),

              // Texto
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSlide(
                        offset: _isHovered ? Offset.zero : const Offset(0, 0.2),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: Text(
                          widget.item.label,
                          style: AppTypography.h4.copyWith(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 20, height: 2,
                                color: AppColors.accentCoral,
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Text(
                                widget.item.sublabel,
                                style: AppTypography.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
