import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_empty_state.dart';

/// Componente visual dedicado para exibição de estado vazio na listagem de Personagens Históricos.
class HistoricalCharacterEmpty extends StatelessWidget {
  final VoidCallback onRefresh;

  const HistoricalCharacterEmpty({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosEmptyState(
      title: 'Nenhum personagem encontrado',
      description: 'Ainda não existem personagens históricos publicados ou ativos neste período ou categoria.',
      actionLabel: 'Recarregar',
      onActionPressed: onRefresh,
    );
  }
}
