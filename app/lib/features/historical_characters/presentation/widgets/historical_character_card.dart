import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_card.dart';
import 'package:chronos/core/presentation/widgets/chronos_badge.dart';
import 'package:chronos/core/presentation/widgets/chronos_divider.dart';
import 'package:chronos/core/presentation/widgets/status_badge.dart';
import 'package:chronos/core/theme/chronos_colors.dart';
import 'package:chronos/core/theme/chronos_icons.dart';
import 'package:chronos/core/theme/chronos_radius.dart';
import 'package:chronos/core/theme/chronos_typography.dart';
import 'package:chronos/domain/entities/era.dart';
import '../../domain/entities/historical_character.dart';

/// Card de exibição para um Personagem Histórico alinhado ao CHRONOS Design System.
class HistoricalCharacterCard extends StatelessWidget {
  final HistoricalCharacter item;
  final Era? era;
  final VoidCallback? onTap;

  const HistoricalCharacterCard({
    super.key,
    required this.item,
    this.era,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor = ChronosColors.accent;
    if (era != null) {
      try {
        final cleanHex = era!.corHex.replaceFirst('#', '');
        if (cleanHex.length == 6) {
          accentColor = Color(int.parse('FF$cleanHex', radix: 16));
        } else if (cleanHex.length == 8) {
          accentColor = Color(int.parse(cleanHex, radix: 16));
        }
      } catch (_) {}
    }

    final birthYear = item.dataNascimento.year;
    final birthLabel = birthYear < 0 ? '${birthYear.abs()} a.C.' : '$birthYear d.C.';
    final deathYear = item.dataMorte?.year;
    final periodLabel = deathYear != null
        ? '$birthLabel — ${deathYear < 0 ? '${deathYear.abs()} a.C.' : '$deathYear d.C.'}'
        : 'Nascido(a) em $birthLabel';

    final description = item.descricaoResumida.isNotEmpty ? item.descricaoResumida : item.descricao;

    return ChronosCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      borderColor: accentColor.withValues(alpha: 0.35),
      borderWidth: 1.2,
      borderRadius: ChronosRadius.borderRadiusMD,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeadingWidget(accentColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (item.titulo != null && item.titulo!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.titulo!,
                        style: ChronosTypography.bodySmall.copyWith(
                          color: ChronosColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (item.ocupacaoPrincipal != null && item.ocupacaoPrincipal!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.ocupacaoPrincipal!.toUpperCase(),
                        style: ChronosTypography.labelSmall.copyWith(
                          color: accentColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: item.publicationStatus.value),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 14),
          const ChronosDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(ChronosIcons.hourglass, size: 14, color: ChronosColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            periodLabel,
                            style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(ChronosIcons.era, size: 14, color: ChronosColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Era: ${era?.nome ?? 'Desconhecida'}',
                            style: ChronosTypography.labelSmall.copyWith(color: accentColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildGenderBadge(item.sexo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingWidget(Color fallbackColor) {
    if (item.imagemPrincipal != null && item.imagemPrincipal!.isNotEmpty) {
      return ClipRRect(
        borderRadius: ChronosRadius.borderRadiusSM,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Image.network(
            item.imagemPrincipal!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(fallbackColor),
          ),
        ),
      );
    }
    return _buildAvatarFallback(fallbackColor);
  }

  Widget _buildAvatarFallback(Color color) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ChronosRadius.borderRadiusSM,
      ),
      child: Icon(
        ChronosIcons.character,
        color: color,
        size: 26,
      ),
    );
  }

  Widget _buildGenderBadge(String sexo) {
    return ChronosBadge(
      text: sexo.toUpperCase(),
      style: ChronosBadgeStyle.neutral,
    );
  }
}
