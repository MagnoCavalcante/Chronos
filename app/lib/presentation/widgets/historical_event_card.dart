import 'package:flutter/material.dart';
import 'package:chronos/core/theme/theme.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';
import '../../domain/entities/era.dart';
import '../../domain/entities/event.dart';
import '../../data/models/historical_event_model.dart';

/// Card de exibição altamente polido de um Evento Histórico.
///
/// Encapsula de forma modular a renderização visual das propriedades da entidade [HistoricalEvent]
/// e as propriedades ricas adicionais caso a instância seja do tipo [HistoricalEventModel].
class HistoricalEventCard extends StatelessWidget {
  /// O evento histórico a ser exibido.
  final HistoricalEvent event;

  /// Mapa de Eras disponíveis para resolução de vínculos e identidades visuais de cores.
  final Map<String, Era> erasMap;

  /// Callback opcional de navegação acionado ao pressionar o card.
  final VoidCallback? onTap;

  const HistoricalEventCard({
    super.key,
    required this.event,
    required this.erasMap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tenta obter as informações mais ricas do modelo de persistência se disponível
    final model = event is HistoricalEventModel ? event as HistoricalEventModel : null;

    // Resgata a Era correspondente para aplicar o design contextualizado
    final Era? era = erasMap[event.eraId];

    // Converte e extrai a cor da Era para estilização dinâmica
    Color? eraColor;
    if (era != null) {
      try {
        final cleanHex = era.corHex.replaceFirst('#', '');
        if (cleanHex.length == 6) {
          eraColor = Color(int.parse('FF$cleanHex', radix: 16));
        } else if (cleanHex.length == 8) {
          eraColor = Color(int.parse(cleanHex, radix: 16));
        }
      } catch (_) {
        // Ignora falhas de parse de cores e usa fallback
      }
    }
    // Cor de destaque oficial (fallback para azul ciano/ouro se não houver Era)
    final Color accentColor = eraColor ?? Colors.amber;

    // Formatação amigável de anos e intervalos temporais
    final int startYear = event.anoOcorrencia;
    final int? endYear = model?.endYear;

    String formatYear(int year) {
      return year < 0 ? '${year.abs()} a.C.' : '$year d.C.';
    }

    final String periodLabel = endYear != null && endYear != startYear
        ? '${formatYear(startYear)} — ${formatYear(endYear)}'
        : formatYear(startYear);

    // Mapeia o tipo de classificação temática do evento
    final String eventType = model?.eventType ?? 'other';
    final _EventTypeData typeData = _getEventTypeData(eventType);

    // Mapeia a pontuação de relevância (1 a 5)
    final int importance = model?.importanceScore ?? 3;

    return ChronosCard(
      margin: const EdgeInsets.symmetric(vertical: ChronosSpacing.sm, horizontal: ChronosSpacing.xxs),
      onTap: onTap,
      borderColor: accentColor.withOpacity(0.35),
      borderWidth: 1.5,
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: Categoria, Título e Badge de Publicação
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone temático correspondente
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  typeData.icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: ChronosSpacing.md),
              // Título e subsegmento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.nome,
                      semanticsLabel: 'Título do evento: ${event.nome}',
                      style: ChronosTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ChronosSpacing.xxs),
                    Text(
                      typeData.label.toUpperCase(),
                      style: ChronosTypography.labelSmall.copyWith(
                        color: accentColor.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ChronosSpacing.sm),
              // Badge de status de publicação
              StatusBadge(status: event.publicationStatus.value),
            ],
          ),
          const SizedBox(height: ChronosSpacing.md),

          // Descrição do Evento
          Text(
            model?.descricaoResumida.isNotEmpty == true
                ? model!.descricaoResumida
                : event.descricao,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: ChronosTypography.bodyMedium,
          ),
          const SizedBox(height: ChronosSpacing.lg),

          // Separador sutil
          const ChronosDivider(),
          const SizedBox(height: ChronosSpacing.md),

          // Rodapé: Período Cronológico, Vínculo de Era e Estrelas de Importância
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Metadados temporais e Era
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cronologia
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: ChronosColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            periodLabel,
                            style: ChronosTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Vínculo da Era correspondente
                    Row(
                      children: [
                        const Icon(Icons.history_edu_rounded, size: 13, color: ChronosColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Era: ${era?.nome ?? "Desconhecida"}',
                            style: ChronosTypography.bodySmall.copyWith(
                              color: accentColor.withOpacity(0.75),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Indicador de Importância por estrelas
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < importance ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < importance ? ChronosColors.accent : ChronosColors.textMuted.withOpacity(0.3),
                    size: 15,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retorna as definições visuais mapeadas para o tipo de classificação do evento.
  _EventTypeData _getEventTypeData(String type) {
    switch (type.toLowerCase()) {
      case 'political':
        return _EventTypeData(Icons.gavel_rounded, 'Político');
      case 'military':
        return _EventTypeData(Icons.shield_rounded, 'Militar');
      case 'social':
        return _EventTypeData(Icons.people_alt_rounded, 'Social');
      case 'cultural':
        return _EventTypeData(Icons.palette_rounded, 'Cultural');
      case 'scientific':
        return _EventTypeData(Icons.science_rounded, 'Científico');
      case 'religious':
        return _EventTypeData(Icons.church_rounded, 'Religioso');
      default:
        return _EventTypeData(Icons.event_note_rounded, 'Geral');
    }
  }
}

/// Dados auxiliares de ícone e label para categorização de eventos.
class _EventTypeData {
  final IconData icon;
  final String label;
  const _EventTypeData(this.icon, this.label);
}
