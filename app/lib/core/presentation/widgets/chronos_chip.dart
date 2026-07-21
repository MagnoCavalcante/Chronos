import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_typography.dart';
import '../../theme/chronos_radius.dart';

/// Chip de seleção, filtro ou tag do ecossistema CHRONOS.
///
/// Oferece estados interativos (selecionado/não selecionado) e suporte a ícones.
class ChronosChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const ChronosChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onTap != null;

    final Color bgColor = isSelected
        ? ChronosColors.accent.withOpacity(0.15)
        : ChronosColors.surface;

    final Color fgColor = isSelected
        ? ChronosColors.accent
        : ChronosColors.textSecondary;

    final Color borderColor = isSelected
        ? ChronosColors.accent
        : ChronosColors.border;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: ChronosRadius.borderRadiusSM,
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 14, color: fgColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: ChronosTypography.bodySmall.copyWith(
              color: fgColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onTrailingTap,
              child: Icon(trailingIcon, size: 14, color: fgColor.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );

    if (isInteractive) {
      return InkWell(
        onTap: onTap,
        borderRadius: ChronosRadius.borderRadiusSM,
        child: content,
      );
    }

    return content;
  }
}
