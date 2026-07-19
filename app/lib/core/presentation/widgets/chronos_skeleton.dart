import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';

/// Componente de Esqueleto de Carregamento (Skeleton Loading) do CHRONOS.
///
/// Implementa uma animação cíclica suave de pulsação para representar
/// dados em fase de carregamento assíncrono.
class ChronosSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const ChronosSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircular = false,
  });

  @override
  State<ChronosSkeleton> createState() => _ChronosSkeletonState();
}

class _ChronosSkeletonState extends State<ChronosSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 16.0,
            decoration: BoxDecoration(
              color: ChronosColors.surfaceLight,
              shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircular
                  ? null
                  : (widget.borderRadius ?? ChronosRadius.borderRadiusSM),
            ),
          ),
        );
      },
    );
  }
}
