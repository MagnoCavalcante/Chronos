import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_empty_state.dart';
import 'package:chronos/core/theme/chronos_icons.dart';

class CivilizationsEmpty extends StatelessWidget {
  final VoidCallback onRefresh;

  const CivilizationsEmpty({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosEmptyState(
      title: 'Nenhum registro encontrado',
      description: 'Ainda não existem itens publicados ou ativos nesta categoria.',
      icon: ChronosIcons.empty,
      actionLabel: 'Sincronizar',
      onActionPressed: onRefresh,
    );
  }
}
