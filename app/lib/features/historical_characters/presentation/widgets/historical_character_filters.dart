import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_chip.dart';
import 'package:chronos/core/theme/chronos_icons.dart';

/// Widget de filtros visuais para a tela de personagens históricos.
class HistoricalCharacterFilters extends StatelessWidget {
  const HistoricalCharacterFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChronosChip(
            label: 'Todos',
            leadingIcon: ChronosIcons.character,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          ChronosChip(
            label: 'Ativos',
            leadingIcon: ChronosIcons.success,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          ChronosChip(
            label: 'Mais recentes',
            leadingIcon: ChronosIcons.refresh,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
