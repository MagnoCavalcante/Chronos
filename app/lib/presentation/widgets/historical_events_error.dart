import 'package:flutter/material.dart';
import '../../core/errors/failure.dart';
import '../../core/presentation/widgets/widgets.dart';

/// Widget de exibição de erros físicos ou de conectividade no ecossistema CHRONOS.
class HistoricalEventsError extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const HistoricalEventsError({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosErrorState(
      errorMessage: failure.message,
      onRetry: onRetry,
    );
  }
}
