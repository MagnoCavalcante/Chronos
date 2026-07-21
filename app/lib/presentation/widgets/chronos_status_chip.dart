import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_radius.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Tag ou Chip estilizado que representa o estado de publicação (Publication Status) de uma entidade no CHRONOS.
///
/// Suporta nativamente os estados: [draft], [review], [published] e [archived].
/// Mapeia automaticamente as cores semânticas oficiais da paleta sem valores hardcoded.
class ChronosStatusChip extends StatelessWidget {
  final String status;

  const ChronosStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (normalizedStatus) {
      case 'published':
      case 'publicado':
        backgroundColor = ChronosColors.success.withOpacity(0.1);
        textColor = ChronosColors.success;
        icon = Icons.check_circle_rounded;
        label = 'Publicado';
        break;
      case 'review':
      case 'revisão':
      case 'analise':
        backgroundColor = ChronosColors.warning.withOpacity(0.1);
        textColor = ChronosColors.warning;
        icon = Icons.rate_review_rounded;
        label = 'Em Revisão';
        break;
      case 'archived':
      case 'arquivado':
        backgroundColor = ChronosColors.textMuted.withOpacity(0.1);
        textColor = ChronosColors.textMuted;
        icon = Icons.archive_rounded;
        label = 'Arquivado';
        break;
      case 'draft':
      case 'rascunho':
      default:
        backgroundColor = ChronosColors.info.withOpacity(0.1);
        textColor = ChronosColors.info;
        icon = Icons.edit_note_rounded;
        label = 'Rascunho';
        break;
    }

    return Semantics(
      label: 'Status de Publicação',
      value: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ChronosSpacing.sm,
          vertical: ChronosSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: ChronosRadius.borderRadiusCircular,
          border: Border.all(
            color: textColor.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 12,
              color: textColor,
            ),
            ChronosSpacing.hSizedBoxXXS,
            Text(
              label.toUpperCase(),
              style: ChronosTypography.labelSmall.copyWith(
                color: textColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
