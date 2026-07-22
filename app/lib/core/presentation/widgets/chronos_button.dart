import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_typography.dart';
import '../../theme/chronos_radius.dart';

enum ChronosButtonVariant { primary, secondary, outline, text }

/// Botão padronizado e responsivo do ecossistema CHRONOS.
///
/// Substitui o uso de [ElevatedButton], [OutlinedButton] e [TextButton] diretos do Material.
class ChronosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ChronosButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? customColor;

  const ChronosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ChronosButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    // Definição dinâmica de estilo baseada na variante escolhida
    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ChronosButtonVariant.primary:
        bgColor = customColor ?? ChronosColors.accent;
        fgColor = ChronosColors.textOnAccent;
        break;
      case ChronosButtonVariant.secondary:
        bgColor = customColor ?? ChronosColors.primaryLight;
        fgColor = ChronosColors.textPrimary;
        break;
      case ChronosButtonVariant.outline:
        bgColor = ChronosColors.transparent;
        fgColor = customColor ?? ChronosColors.accent;
        borderSide = BorderSide(color: customColor ?? ChronosColors.accent, width: 1.5);
        break;
      case ChronosButtonVariant.text:
        bgColor = ChronosColors.transparent;
        fgColor = customColor ?? ChronosColors.textSecondary;
        break;
    }

    if (isDisabled) {
      bgColor = variant == ChronosButtonVariant.primary || variant == ChronosButtonVariant.secondary
          ? ChronosColors.primaryLight.withValues(alpha: 0.5)
          : ChronosColors.transparent;
      fgColor = ChronosColors.textMuted;
      borderSide = borderSide != BorderSide.none
          ? BorderSide(color: ChronosColors.border, width: 1.5)
          : BorderSide.none;
    }

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: ChronosTypography.labelLarge.copyWith(color: fgColor),
        ),
      ],
    );

    Widget rawButton = OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        side: borderSide,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: ChronosRadius.shapeMD,
        elevation: variant == ChronosButtonVariant.primary && !isDisabled ? 2 : 0,
      ),
      child: buttonContent,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: rawButton,
      );
    }

    return rawButton;
  }
}
