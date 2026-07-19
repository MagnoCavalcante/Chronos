import 'package:flutter/material.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/presentation/widgets/chronos_error_state.dart';

class CivilizationsError extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const CivilizationsError({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosErrorState(
      title: 'Ocorreu um erro ao carregar os dados',
      errorMessage: failure.message,
      onRetry: onRetry,
    );
  }
}
