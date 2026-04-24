import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';
import '../data/landing_data.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.backgroundDark : Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 120),
      child: ContentWrapper(
        maxWidth: 1000,
        child: Column(
          children: [
            AnimatedSection(
              sectionKey: 'testimonials_header',
              child: Column(
                children: [
                  Text(
                    'TESTIMONIOS',
                    style: AppTypography.overline.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'La Experiencia Moobox',
                    style: AppTypography.h1Responsive(MediaQuery.of(context).size.width),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),

            SizedBox(
              height: isMobile ? 400 : 320,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: LandingData.testimonials.length,
                itemBuilder: (context, i) {
                  final t = LandingData.testimonials[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _TestimonialCard(
                      name: t['name']!,
                      role: t['role']!,
                      text: t['text']!,
                      isActive: i == _currentIndex,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: LandingData.testimonials.asMap().entries.map((e) {
                final isActive = e.key == _currentIndex;
                return GestureDetector(
                  onTap: () => _goTo(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isActive ? 32 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accentCoral : (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String text;
  final bool isActive;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.text,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isActive ? AppColors.accentCoral : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.dividerLight),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.1 : 0.02),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.accentCoral, size: 48),
          const SizedBox(height: 24),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Text(name, style: AppTypography.h4.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            role,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
