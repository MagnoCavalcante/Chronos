import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../widgets/chronos_image_banner.dart';
import '../../widgets/browser/entity_card.dart';

/// Componente de cabeçalho unificado para a tela de detalhes do CHRONOS.
///
/// Exibe imagem, título, subtítulo, período, categoria e cor de identificação da Era.
class EntityDetailsHeader extends StatelessWidget {
  final ChronosEntityDisplay display;

  const EntityDetailsHeader({
    super.key,
    required this.display,
  });

  @override
  Widget build(BuildContext context) {
    final Color eraColor = display.color ?? ChronosColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagem de destaque (Hero Banner)
        Hero(
          tag: 'entity-image-${display.id}',
          child: ChronosImageBanner(
            imageUrl: display.imageUrl,
            aspectRatio: 21 / 9,
            borderRadius: BorderRadius.circular(ChronosRadius.md),
          ),
        ),
        ChronosSpacing.vSizedBoxMD,

        // Categoria e Tipo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (display.type != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ChronosSpacing.sm,
                  vertical: ChronosSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: eraColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(ChronosRadius.sm),
                  border: Border.all(color: eraColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  display.type!.toUpperCase(),
                  style: ChronosTypography.labelSmall.copyWith(
                    color: eraColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            if (display.category != null)
              Text(
                display.category!,
                style: ChronosTypography.labelSmall.copyWith(
                  color: ChronosColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        ChronosSpacing.vSizedBoxSM,

        // Título Principal
        Text(
          display.title,
          style: ChronosTypography.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: ChronosColors.textPrimary,
          ),
        ),
        ChronosSpacing.vSizedBoxXXS,

        // Subtítulo
        Text(
          display.subtitle,
          style: ChronosTypography.titleMedium.copyWith(
            color: ChronosColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        // Período Cronológico
        if (display.chronology != null) ...[
          ChronosSpacing.vSizedBoxXS,
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: eraColor),
              ChronosSpacing.hSizedBoxXS,
              Text(
                display.chronology!,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: eraColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
        ChronosSpacing.vSizedBoxMD,
      ],
    );
  }
}
