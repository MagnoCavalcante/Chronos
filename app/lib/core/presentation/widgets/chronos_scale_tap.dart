import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/chronos_animation.dart';

/// Widget que aplica uma microinteração de escala ao toque.
///
/// Comprime levemente o child ao pressionar e volta ao normal ao soltar.
/// Ideal para botões, cards e itens de lista.
class ChronosScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleMinValue;
  final bool hapticFeedback;

  const ChronosScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleMinValue = 0.96,
    this.hapticFeedback = false,
  });

  @override
  State<ChronosScaleTap> createState() => _ChronosScaleTapState();
}

class _ChronosScaleTapState extends State<ChronosScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ChronosAnimation.fast,
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: widget.scaleMinValue,
    ).animate(CurvedAnimation(parent: _controller, curve: ChronosAnimation.defaultCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  void _onTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap != null ? _onTap : null,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
