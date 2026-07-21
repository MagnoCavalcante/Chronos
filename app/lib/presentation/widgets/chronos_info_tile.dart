import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Widget reutilizável para exibição elegante de atributos ou metadados de entidades (Info Tile).
///
/// Ideal para detalhar dados de localização, capital, população, idioma ou períodos cronológicos.
class ChronosInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;

  const ChronosInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(ChronosSpacing.sm),
                decoration: BoxDecoration(
                  color: ChronosColors.surfaceLight,
                  borderRadius: BorderRadius.circular(ChronosSpacing.sm),
                ),
                child: Icon(
                  icon,
                  color: ChronosColors.accent,
                  size: 16,
                ),
              ),
              ChronosSpacing.hSizedBoxMD,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: ChronosTypography.labelSmall.copyWith(
                      color: ChronosColors.textMuted,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  ChronosSpacing.vSizedBoxXXS,
                  Text(
                    value,
                    style: ChronosTypography.bodyMedium.copyWith(
                      color: ChronosColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              ChronosSpacing.hSizedBoxMD,
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
