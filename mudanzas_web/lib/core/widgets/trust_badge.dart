import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TrustBadge extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool compact;

  const TrustBadge({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.iconColor,
    this.backgroundColor,
    this.compact = false,
  });

  @override
  State<TrustBadge> createState() => _TrustBadgeState();
}

class _TrustBadgeState extends State<TrustBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.backgroundColor ?? cs.surface;
    final iconColor = widget.iconColor ?? AppColors.accentCoral;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 160),
        padding: widget.compact
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.primaryBlue : bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.primaryBlue : Theme.of(context).dividerColor,
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))]
              : [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: widget.compact ? _buildCompact(iconColor, cs) : _buildFull(iconColor, cs),
      ),
    );
  }

  Widget _buildCompact(Color iconColor, ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, color: _isHovered ? AppColors.accentCoral : iconColor, size: 20),
        const SizedBox(width: 10),
        Text(
          widget.title,
          style: AppTypography.h4.copyWith(
            fontSize: 14,
            color: _isHovered ? AppColors.white : cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFull(Color iconColor, ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.accentCoral.withValues(alpha: 0.15) : iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: _isHovered ? AppColors.accentCoral : iconColor, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: AppTypography.h4.copyWith(
            color: _isHovered ? AppColors.white : cs.onSurface,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            style: AppTypography.bodySm.copyWith(
              color: _isHovered ? AppColors.white.withValues(alpha: 0.75) : cs.onSurface.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
