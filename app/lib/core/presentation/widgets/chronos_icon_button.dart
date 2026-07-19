import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';

/// Botão de Ícone padronizado do ecossistema CHRONOS.
///
/// Substitui o uso de [IconButton] com suporte a estilos modernos como outline,
/// fill e variações de tamanho consistentes com o sistema.
class ChronosIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final bool hasBorder;
  final double size;

  const ChronosIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.hasBorder = false,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onPressed == null
        ? ChronosColors.textMuted
        : (color ?? ChronosColors.accent);

    final double paddingValue = size * 0.45;
    final double totalSize = size + (paddingValue * 2);

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: ChronosRadius.borderRadiusCircular,
      child: Container(
        width: totalSize,
        height: totalSize,
        decoration: BoxDecoration(
          color: backgroundColor ?? (hasBorder ? ChronosColors.transparent : null),
          shape: BoxShape.circle,
          border: hasBorder
              ? Border.all(color: ChronosColors.border, width: 1.0)
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: size,
            color: effectiveColor,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
