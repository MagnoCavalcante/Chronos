import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../domain/entities/era.dart';
import '../../widgets/chronos_section_header.dart';
import '../../engine/entity_renderer.dart';
import '../../engine/entity_view.dart';
import '../details/entity_details_page.dart';
import 'timeline_controller.dart';
import 'timeline_item.dart';

/// Renderizador da lista de itens da Linha do Tempo.
///
/// Suporta dois modos de exibição dinâmicos com base nas configurações do controlador:
/// 1. **Fluxo Contínuo**: Lista única ordenada cronologicamente de Eras e Eventos.
/// 2. **Agrupado por Era**: Seções dedicadas por Era, contendo seus respectivos eventos vinculados.
class TimelineList extends StatelessWidget {
  final TimelineController controller;

  const TimelineList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.groupByEra) {
      return _buildGroupedTimeline(context);
    } else {
      return _buildContinuousTimeline(context);
    }
  }

  /// Constrói a visualização agrupada por Era com cabeçalhos elegantes.
  Widget _buildGroupedTimeline(BuildContext context) {
    final entries = controller.groupedFilteredItems.entries.toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final Era era = entry.key;
        final List<TimelineDisplayItem> events = entry.value;

        final Color eraColor = _parseHexColor(era.corHex);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da Era
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ChronosSpacing.lg,
                vertical: ChronosSpacing.md,
              ),
              child: ChronosCard(
                borderColor: eraColor.withValues(alpha: 0.4),
                borderWidth: 2.0,
                padding: const EdgeInsets.all(ChronosSpacing.md),
                onTap: () => _showDetails(context, TimelineDisplayItem.fromEra(era, eraColor)),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 48,
                      decoration: BoxDecoration(
                        color: eraColor,
                        borderRadius: BorderRadius.circular(ChronosRadius.xs),
                      ),
                    ),
                    ChronosSpacing.hSizedBoxMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ERA HISTÓRICA',
                            style: ChronosTypography.labelSmall.copyWith(
                              color: eraColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            era.nome,
                            style: ChronosTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${era.inicioAno.abs()}${era.inicioAno < 0 ? " a.C." : " d.C."} — ${era.fimAno.abs()}${era.fimAno < 0 ? " a.C." : " d.C."}',
                            style: ChronosTypography.bodySmall.copyWith(
                              color: ChronosColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: ChronosColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            // Lista de eventos pertencentes a esta Era
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ChronosSpacing.xl,
                  vertical: ChronosSpacing.sm,
                ),
                child: Text(
                  'Nenhum evento registrado nesta era sob os filtros atuais.',
                  style: ChronosTypography.bodySmall.copyWith(
                    color: ChronosColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.lg),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, eventIndex) {
                    final item = events[eventIndex];
                    return _buildTimelineRowItem(
                      context,
                      item: item,
                      index: eventIndex,
                      totalCount: events.length,
                    );
                  },
                ),
              ),
            ChronosSpacing.vSizedBoxLG,
            const ChronosDivider(),
          ],
        );
      },
    );
  }

  /// Constrói a visualização de fluxo contínuo unificado.
  Widget _buildContinuousTimeline(BuildContext context) {
    final items = controller.filteredItems;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildTimelineRowItem(
          context,
          item: item,
          index: index,
          totalCount: items.length,
        );
      },
    );
  }

  /// Cria uma linha unificada e conectada da Timeline visual.
  Widget _buildTimelineRowItem(
    BuildContext context, {
    required TimelineDisplayItem item,
    required int index,
    required int totalCount,
  }) {
    final bool isEra = item.type == TimelineItemType.era;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Conexão visual da Timeline (Linha vertical + Nó)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Segmento superior da linha (não renderiza no primeiríssimo nó)
                Container(
                  width: 2,
                  height: 24,
                  color: index > 0 ? item.color.withValues(alpha: 0.5) : Colors.transparent,
                ),
                // O nó circular representativo
                Container(
                  width: isEra ? 16 : 12,
                  height: isEra ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isEra ? ChronosColors.background : item.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.color,
                      width: isEra ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Segmento inferior da linha (não renderiza no último nó)
                Expanded(
                  child: Container(
                    width: 2,
                    color: index < totalCount - 1 ? item.color.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          ChronosSpacing.hSizedBoxMD,

          // O Card de conteúdo do nó
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.xs),
              child: ChronosCard(
                borderColor: item.color.withValues(alpha: 0.2),
                borderWidth: isEra ? 1.5 : 1.0,
                padding: const EdgeInsets.all(ChronosSpacing.md),
                onTap: () => _showDetails(context, item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de entidade e ano
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ChronosSpacing.xs,
                            vertical: ChronosSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ChronosRadius.xs),
                          ),
                          child: Text(
                            isEra ? 'ERA' : 'EVENTO',
                            style: ChronosTypography.labelSmall.copyWith(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        Text(
                          item.subtitle,
                          style: ChronosTypography.codeSmall.copyWith(
                            color: ChronosColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ChronosSpacing.vSizedBoxXS,

                    // Título e resumo do nó
                    Text(
                      item.title,
                      style: ChronosTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ChronosSpacing.vSizedBoxXXS,
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ChronosTypography.bodySmall.copyWith(
                        color: ChronosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Abre a visualização detalhada rica e modular utilizando o Universal Entity Rendering Engine.
  void _showDetails(BuildContext context, TimelineDisplayItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EntityDetailsPage(
          entity: item.originalEntity,
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return ChronosColors.accent;
  }
}
