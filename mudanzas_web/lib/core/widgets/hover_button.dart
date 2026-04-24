import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum HoverButtonVariant { primary, outline, ghost, coral }

class HoverButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final HoverButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double? height;
  final double borderRadius;

  const HoverButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HoverButtonVariant.primary,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  (Color bg, Color fg, Border? border) _getColors() {
    switch (widget.variant) {
      case HoverButtonVariant.primary:
        return (
          _isHovered
              ? AppColors.primaryBlueLight
              : AppColors.primaryBlue,
          AppColors.white,
          null
        );
      case HoverButtonVariant.coral:
        return (
          _isHovered
              ? const Color(0xFFFF6B5B)
              : AppColors.accentCoral,
          AppColors.white,
          null
        );
      case HoverButtonVariant.outline:
        return (
          _isHovered
              ? AppColors.white.withOpacity(0.15)
              : Colors.transparent,
          AppColors.white,
          Border.all(color: AppColors.white, width: 2)
        );
      case HoverButtonVariant.ghost:
        return (
          _isHovered
              ? AppColors.primaryBlue.withOpacity(0.08)
              : Colors.transparent,
          AppColors.primaryBlue,
          null
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _getColors();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.97 : _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: widget.width,
                height: widget.height ?? 56,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: border,
                  boxShadow: _isHovered && widget.variant != HoverButtonVariant.outline
                      ? [
                          BoxShadow(
                            color: (widget.variant == HoverButtonVariant.coral
                                    ? AppColors.accentCoral
                                    : AppColors.primaryBlue)
                                .withOpacity(0.35),
                            blurRadius: _elevationAnimation.value * 2,
                            offset: Offset(0, _elevationAnimation.value / 2),
                            spreadRadius: 0,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fg, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(widget.label, style: AppTypography.buttonPrimary.copyWith(color: fg)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
