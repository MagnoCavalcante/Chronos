import 'package:flutter/material.dart';

import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';

/// Efeito Shimmer para loading states.
///
/// Cria um gradiente animado que se move horizontalmente, indicando carregamento.
class ChronosShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const ChronosShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  /// Factory para criar shimmer de texto (linha).
  const factory ChronosShimmer.line({
    Key? key,
    double width,
    double height,
  }) = _ShimmerLine;

  /// Factory para criar shimmer de card.
  const factory ChronosShimmer.card({
    Key? key,
    double height,
  }) = _ShimmerCard;

  /// Factory para criar shimmer circular (avatar).
  const factory ChronosShimmer.circle({
    Key? key,
    double size,
  }) = _ShimmerCircle;

  @override
  State<ChronosShimmer> createState() => _ChronosShimmerState();
}

class _ChronosShimmerState extends State<ChronosShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _gradientAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 16,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? ChronosRadius.borderRadiusSM,
            gradient: LinearGradient(
              begin: Alignment(_gradientAnimation.value - 1, 0),
              end: Alignment(_gradientAnimation.value + 1, 0),
              colors: const [
                ChronosColors.surface,
                ChronosColors.surfaceLight,
                ChronosColors.surface,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerLine extends ChronosShimmer {
  const _ShimmerLine({
    super.key,
    double width = double.infinity,
    double height = 14,
  }) : super(width: width, height: height);
}

class _ShimmerCard extends ChronosShimmer {
  const _ShimmerCard({
    super.key,
    double height = 120,
  }) : super(height: height, borderRadius: ChronosRadius.borderRadiusMD);
}

class _ShimmerCircle extends ChronosShimmer {
  const _ShimmerCircle({
    super.key,
    double size = 48,
  }) : super(width: size, height: size, borderRadius: ChronosRadius.borderRadiusCircular);
}
