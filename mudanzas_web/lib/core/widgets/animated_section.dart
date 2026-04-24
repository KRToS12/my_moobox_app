import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedSection extends StatefulWidget {
  final Widget child;
  final String sectionKey;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final double visibilityThreshold;

  const AnimatedSection({
    super.key,
    required this.child,
    required this.sectionKey,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.slideOffset = const Offset(0, 40),
    this.visibilityThreshold = 0.15,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasAnimated && info.visibleFraction >= widget.visibilityThreshold) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.sectionKey),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: _slideAnimation.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Staggered animation for a list of children
class StaggeredSection extends StatelessWidget {
  final List<Widget> children;
  final String baseKey;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredSection({
    super.key,
    required this.children,
    required this.baseKey,
    this.staggerDelay = const Duration(milliseconds: 120),
    this.itemDuration = const Duration(milliseconds: 600),
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final staggered = children.asMap().entries.map((entry) {
      return AnimatedSection(
        sectionKey: '${baseKey}_${entry.key}',
        delay: staggerDelay * entry.key,
        duration: itemDuration,
        slideOffset: direction == Axis.horizontal
            ? const Offset(0, 30)
            : const Offset(30, 0),
        child: entry.value,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: 0,
        runSpacing: 0,
        children: staggered,
      );
    }
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: staggered,
    );
  }
}
