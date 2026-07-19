import 'package:flutter/material.dart';
import '../../core/presentation/widgets/widgets.dart';

/// Widget de Apresentação para exibir o estado de lista vazia.
class HistoricalEventsEmpty extends StatelessWidget {
  final VoidCallback onRefresh;

  const HistoricalEventsEmpty({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosEmptyState(
      title: 'Nenhum evento localizado',
      description: 'Não foram encontrados registros de eventos históricos ativos e publicados no ecossistema CHRONOS no momento.',
      actionLabel: 'Recarregar',
      onActionPressed: onRefresh,
    );
  }
}
