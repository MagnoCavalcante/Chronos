import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_typography.dart';

/// Título de Seção padronizado do CHRONOS.
///
/// Oferece um visual sofisticado com borda de destaque e suporte a subtítulos.
class ChronosSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showAccentLine;

  const ChronosSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showAccentLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barra de destaque vertical (Amber Accent)
          if (showAccentLine) ...[
            Container(
              width: 4,
              height: subtitle != null ? 36 : 22,
              decoration: BoxDecoration(
                color: ChronosColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ChronosTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: ChronosTypography.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
