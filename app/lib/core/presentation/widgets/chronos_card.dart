import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';
import '../../theme/chronos_shadows.dart';

/// Card unificado e altamente customizável do ecossistema CHRONOS.
///
/// Substitui o uso direto de [Card] do Material, garantindo que
/// bordas, cores, sombras e espaçamentos derivem dos Design Tokens oficiais.
class ChronosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ChronosCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadows,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? ChronosRadius.borderRadiusMD;
    final effectiveColor = color ?? ChronosColors.surface;
    final effectiveShadows = shadows ?? ChronosShadows.md;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: effectiveShadows,
        border: Border.all(
          color: borderColor ?? ChronosColors.border,
          width: borderWidth ?? 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: cardContent,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }
}
