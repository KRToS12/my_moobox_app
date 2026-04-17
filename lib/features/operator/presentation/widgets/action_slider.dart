import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ActionSlider extends StatefulWidget {
  final String label;
  final VoidCallback onAction;
  final Color baseColor;

  const ActionSlider({
    super.key,
    required this.label,
    required this.onAction,
    this.baseColor = AppColors.primaryBlue,
  });

  @override
  State<ActionSlider> createState() => _ActionSliderState();
}

class _ActionSliderState extends State<ActionSlider> {
  double _dragValue = 0.0;
  final double _threshold = 0.85; // 85% to trigger
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double handleSize = 60.0;
        final double maxDrag = width - handleSize - 8;

        return Container(
          height: 68,
          width: width,
          decoration: BoxDecoration(
            color: widget.baseColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.baseColor.withOpacity(0.2)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Texto de fondo
              Opacity(
                opacity: 1.0 - (_dragValue / maxDrag).clamp(0.0, 1.0),
                child: Text(
                  widget.label.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: widget.baseColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // Track de progreso
              Positioned(
                left: 4,
                child: Container(
                  width: _dragValue + handleSize,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.baseColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // El Handle deslizante
              Positioned(
                left: 4 + _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_completed) return;
                    setState(() {
                      _dragValue += details.delta.dx;
                      if (_dragValue < 0) _dragValue = 0;
                      if (_dragValue > maxDrag) _dragValue = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_completed) return;
                    if (_dragValue >= maxDrag * _threshold) {
                      setState(() {
                        _dragValue = maxDrag;
                        _completed = true;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onAction();
                    } else {
                      setState(() {
                        _dragValue = 0;
                      });
                    }
                  },
                  child: Container(
                    width: handleSize,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.baseColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.baseColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
