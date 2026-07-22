import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import 'timeline_controller.dart';
import 'timeline_filters.dart';
import 'timeline_item.dart';
import 'period_compare_page.dart';

/// Cabeçalho rico e interativo para a Timeline CHRONOS.
class TimelineHeader extends StatelessWidget {
  final TimelineController controller;

  const TimelineHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isFilterActive = controller.selectedCategory != TimelineItemType.all ||
        controller.searchQuery.isNotEmpty ||
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
                      'Explore fendas temporais de todas as categorias.',
                      style: ChronosTypography.bodyMedium.copyWith(
                        color: ChronosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFilterActive)
                ChronosButton(
                  label: 'Limpar',
                  onPressed: controller.resetFilters,
                  variant: ChronosButtonVariant.text,
                ),
            ],
          ),
          ChronosSpacing.vSizedBoxMD,

          // Barra de pesquisa
          ChronosSearchBar(
            initialValue: controller.searchQuery,
            hintText: 'Buscar na linha do tempo...',
            onChanged: controller.setSearchQuery,
          ),
          ChronosSpacing.vSizedBoxMD,

          // Categorias rápidas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ChronosChip(
                  label: 'Todos',
                  isSelected: controller.selectedCategory == TimelineItemType.all,
                  leadingIcon: Icons.apps_rounded,
                  onTap: () => controller.selectCategory(TimelineItemType.all),
                ),
                ...controller.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: ChronosSpacing.sm),
                    child: ChronosChip(
                      label: category.label,
                      isSelected: controller.selectedCategory == category,
                      leadingIcon: category.icon,
                      onTap: () => controller.selectCategory(category),
                    ),
                  );
                }),
              ],
            ),
          ),
          ChronosSpacing.vSizedBoxSM,

          // Ações: ordenar, zoom, comparar, filtros avançados
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ChronosChip(
                  label: controller.isAscending ? 'Mais Antigo' : 'Mais Recente',
                  leadingIcon: controller.isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  onTap: controller.toggleOrder,
                ),
                const SizedBox(width: ChronosSpacing.sm),
                ChronosChip(
                  label: controller.zoom,
                  leadingIcon: Icons.zoom_in_map_rounded,
                  onTap: () => _showZoomSelector(context),
                ),
                const SizedBox(width: ChronosSpacing.sm),
                ChronosChip(
                  label: 'Comparar',
                  leadingIcon: Icons.compare_arrows_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PeriodComparePage()),
                  ),
                ),
                const SizedBox(width: ChronosSpacing.sm),
                ChronosChip(
                  label: 'Filtros Avançados',
                  leadingIcon: Icons.tune_rounded,
                  isSelected: isFilterActive,
                  onTap: () {
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

  void _showZoomSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ChronosColors.background,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Décadas', 'Séculos', 'Milênios'].map((zoom) {
              return ListTile(
                leading: const Icon(Icons.zoom_in_map_rounded),
                title: Text(zoom),
                selected: controller.zoom == zoom,
                onTap: () {
                  controller.setZoom(zoom);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
