import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/chronos_animation.dart';
import '../../theme/chronos_colors.dart';

/// Widget de microinteração para ícones animados (favoritar, salvar, etc).
///
/// Exibe uma animação de escala + bounce ao ser acionado.
class ChronosAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final bool hapticFeedback;

  const ChronosAnimatedIcon({
    super.key,
    required this.icon,
    this.activeIcon,
    this.isActive = false,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.size = 24,
    this.hapticFeedback = true,
  });

  @override
  State<ChronosAnimatedIcon> createState() => _ChronosAnimatedIconState();
}

class _ChronosAnimatedIconState extends State<ChronosAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ChronosAnimation.normal,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: ChronosAnimation.sharpCurve));
  }

  @override
  void didUpdateWidget(covariant ChronosAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isActive ? (widget.activeIcon ?? widget.icon) : widget.icon,
          size: widget.size,
          color: widget.isActive
              ? (widget.activeColor ?? ChronosColors.accent)
              : (widget.inactiveColor ?? ChronosColors.textMuted),
        ),
      ),
    );
  }
}
