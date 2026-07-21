import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'entity_card.dart';

/// Enum contendo as opções oficiais de ordenação do CHRONOS.
enum EntitySortOption {
  nameAsc,
  nameDesc,
  chronologyAsc,
  chronologyDesc,
  newest,
  oldest,
  custom,
}

extension EntitySortOptionExtension on EntitySortOption {
  String get label {
    switch (this) {
      case EntitySortOption.nameAsc:
        return 'Nome (A - Z)';
      case EntitySortOption.nameDesc:
        return 'Nome (Z - A)';
      case EntitySortOption.chronologyAsc:
        return 'Cronologia (Mais antigo primeiro)';
      case EntitySortOption.chronologyDesc:
        return 'Cronologia (Mais recente primeiro)';
      case EntitySortOption.newest:
        return 'Adicionados recentemente';
      case EntitySortOption.oldest:
        return 'Mais antigos cadastrados';
      case EntitySortOption.custom:
        return 'Ordenação personalizada';
    }
  }

  IconData get icon {
    switch (this) {
      case EntitySortOption.nameAsc:
        return Icons.sort_by_alpha_rounded;
      case EntitySortOption.nameDesc:
        return Icons.sort_by_alpha_rounded;
      case EntitySortOption.chronologyAsc:
        return Icons.arrow_upward_rounded;
      case EntitySortOption.chronologyDesc:
        return Icons.arrow_downward_rounded;
      case EntitySortOption.newest:
        return Icons.new_releases_outlined;
      case EntitySortOption.oldest:
        return Icons.history_rounded;
      case EntitySortOption.custom:
        return Icons.dashboard_customize_outlined;
    }
  }
}

/// Menu interativo de seleção para ordenar de forma síncrona as entidades históricas do CHRONOS.
class EntitySortMenu extends StatelessWidget {
  final EntitySortOption selectedOption;
  final ValueChanged<EntitySortOption> onSelected;

  const EntitySortMenu({
    super.key,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EntitySortOption>(
      icon: const Icon(Icons.sort_rounded, color: ChronosColors.textPrimary),
      tooltip: 'Ordenar Registros',
      onSelected: onSelected,
      backgroundColor: ChronosColors.surface,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChronosRadius.md),
        side: const BorderSide(color: ChronosColors.border, width: 1.0),
      ),
      itemBuilder: (BuildContext context) {
        return EntitySortOption.values.map((option) {
          final bool isSelected = selectedOption == option;
          return PopupMenuItem<EntitySortOption>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: isSelected ? ChronosColors.accent : ChronosColors.textSecondary,
                  size: 18,
                ),
                ChronosSpacing.hSizedBoxMD,
                Text(
                  option.label,
                  style: ChronosTypography.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? ChronosColors.accent : ChronosColors.textPrimary,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check_rounded,
                    color: ChronosColors.accent,
                    size: 16,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
