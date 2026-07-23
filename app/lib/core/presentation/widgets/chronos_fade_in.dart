import 'package:flutter/material.dart';

import '../../theme/chronos_animation.dart';

/// Widget que aplica uma animação de fade + slide ao aparecer.
///
/// Usado para microinterações suaves ao abrir detalhes, trocar filtros, etc.
class ChronosFadeIn extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Duration delay;
  final Offset? slideOffset;
  final Curve? curve;

  const ChronosFadeIn({
    super.key,
    required this.child,
    this.duration,
    this.delay = Duration.zero,
    this.slideOffset,
    this.curve,
  });

  @override
  State<ChronosFadeIn> createState() => _ChronosFadeInState();
}

class _ChronosFadeInState extends State<ChronosFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? ChronosAnimation.normal,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? ChronosAnimation.enterCurve,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: widget.slideOffset ?? ChronosAnimation.slideFromBottom,
      end: Offset.zero,
    ).animate(curve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
