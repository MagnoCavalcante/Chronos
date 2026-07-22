import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_chip.dart';

/// Filtros de Categoria e Ordenação estruturados para a busca.
class SearchFilters extends StatelessWidget {
  final String selectedCategory;
  final String selectedSort;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSortChanged;

  const SearchFilters({
    super.key,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  static const List<String> _categories = [
    'Todos',
    'Eras',
    'Eventos',
    'Personagens',
    'Civilizações',
    'Artefatos',
    'Localizações',
    'Fontes',
  ];

  static const List<String> _sortOptions = [
    'Mais relevantes',
    'Nome A-Z',
    'Nome Z-A',
    'Mais recentes',
    'Mais antigos',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha superior: Categorias (Rolo horizontal)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
          child: Row(
            children: _categories.map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: ChronosSpacing.xs),
                child: ChronosChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () => onCategoryChanged(category),
                ),
              );
            }).toList(),
          ),
        ),
        
        ChronosSpacing.vSizedBoxSM,

        // Linha inferior: Contador de resultados e Seletor de ordenação
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ordernar por: ',
                style: ChronosTypography.bodySmall.copyWith(
                  color: ChronosColors.textMuted,
                ),
              ),
              PopupMenuButton<String>(
                initialValue: selectedSort,
                onSelected: onSortChanged,
                color: ChronosColors.surface,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ChronosRadius.sm),
                  side: const BorderSide(color: ChronosColors.border, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedSort,
                      style: ChronosTypography.bodySmall.copyWith(
                        color: ChronosColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: ChronosColors.accent,
                      size: 20,
                    ),
                  ],
                ),
                itemBuilder: (context) {
                  return _sortOptions.map((option) {
                    return PopupMenuItem<String>(
                      value: option,
                      height: 36,
                      child: Text(
                        option,
                        style: ChronosTypography.bodySmall.copyWith(
                          color: selectedSort == option
                              ? ChronosColors.accent
                              : ChronosColors.textPrimary,
                          fontWeight: selectedSort == option
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
          child: Divider(color: ChronosColors.border, height: 1.0),
        ),
      ],
    );
  }
}
