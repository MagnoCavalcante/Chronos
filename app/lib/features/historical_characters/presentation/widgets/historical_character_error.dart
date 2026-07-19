import 'package:flutter/material.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/presentation/widgets/chronos_error_state.dart';

/// Componente visual dedicado para exibição de mensagens de falha ou erro na listagem de Personagens Históricos.
class HistoricalCharacterError extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const HistoricalCharacterError({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosErrorState(
      title: 'Não foi possível carregar os personagens',
      errorMessage: failure.message,
      onRetry: onRetry,
    );
  }
}
