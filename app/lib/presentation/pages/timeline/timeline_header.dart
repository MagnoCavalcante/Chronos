import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import 'timeline_controller.dart';
import 'timeline_filters.dart';

/// Cabeçalho rico e interativo para a Timeline CHRONOS.
///
/// Contém campo de busca integrada, botões de ordenação e agrupamento rápidos
/// e aciona o painel de filtros avançados via Bottom Sheet.
class TimelineHeader extends StatelessWidget {
  final TimelineController controller;

  const TimelineHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFilterActive = controller.selectedEraId != null ||
        controller.searchQuery.isNotEmpty ||
        controller.groupByEra ||
        controller.startYear != controller.minPossibleYear ||
        controller.endYear != controller.maxPossibleYear;

    return Container(
      width: double.infinity,
      color: ChronosColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e Descrição
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Linha do Tempo',
                      style: ChronosTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ChronosColors.textPrimary,
                      ),
                    ),
                    ChronosSpacing.vSizedBoxXXS,
                    Text(
                      'Explore fendas temporais e eras conectadas.',
                      style: ChronosTypography.bodyMedium.copyWith(
                        color: ChronosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFilterActive)
                ChronosButton.text(
                  label: 'Limpar',
                  onPressed: controller.resetFilters,
                ),
            ],
          ),
          ChronosSpacing.vSizedBoxMD,

          // Barra de Pesquisa integrada
          ChronosSearchBar(
            initialValue: controller.searchQuery,
            hintText: 'Buscar na linha do tempo...',
            onChanged: controller.setSearchQuery,
          ),
          ChronosSpacing.vSizedBoxMD,

          // Linha de ações rápidas (Chips horizontais scrolláveis)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Ordenação rápida
                ChronosChip(
                  label: controller.isAscending ? 'Mais Antigo primeiro' : 'Mais Recente primeiro',
                  avatar: Icon(
                    controller.isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 14,
                    color: ChronosColors.accent,
                  ),
                  onPressed: controller.toggleOrder,
                ),
                const SizedBox(width: ChronosSpacing.sm),

                // Agrupamento por Era
                ChronosChip(
                  label: controller.groupByEra ? 'Agrupado por Era' : 'Fluxo Contínuo',
                  avatar: Icon(
                    controller.groupByEra ? Icons.grid_view_rounded : Icons.splitscreen_rounded,
                    size: 14,
                    color: controller.groupByEra ? ChronosColors.accent : ChronosColors.textMuted,
                  ),
                  selected: controller.groupByEra,
                  onPressed: () => controller.setGroupByEra(!controller.groupByEra),
                ),
                const SizedBox(width: ChronosSpacing.sm),

                // Filtros avançados
                ChronosChip(
                  label: 'Filtros Avançados',
                  avatar: Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: isFilterActive ? ChronosColors.accent : ChronosColors.textMuted,
                  ),
                  selected: isFilterActive,
                  onPressed: () {
                    ChronosBottomSheet.show(
                      context,
                      child: TimelineFilters(controller: controller),
                    );
                  },
                ),
              ],
            ),
          ),
          ChronosSpacing.vSizedBoxSM,
          const ChronosDivider(),
        ],
      ),
    );
  }
}
