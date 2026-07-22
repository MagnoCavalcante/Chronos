import 'package:flutter/material.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_icons.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Componente padronizado para tratamento e exibição de falhas (Erros) no ecossistema CHRONOS.
///
/// Aceita uma entidade de negócio [Failure], uma [message] amigável de substituição,
/// e um callback de retentativa ([onRetry]) acionando um botão de ação rápida.
class ChronosErrorView extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;

  const ChronosErrorView({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Determina a mensagem final de erro de acordo com a prioridade
    final String displayMessage = message ?? 
        failure?.message ?? 
        'Houve uma falha inesperada ao sincronizar a fenda temporal.';

    return Semantics(
      label: 'Erro na operação',
      hint: displayMessage,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ChronosSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(ChronosSpacing.md),
                decoration: BoxDecoration(
                  color: ChronosColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  ChronosIcons.error,
                  size: 48,
                  color: ChronosColors.error,
                ),
              ),
              ChronosSpacing.vSizedBoxLG,
              Text(
                'Falha de Conexão com o Tempo',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              ChronosSpacing.vSizedBoxSM,
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textSecondary,
                ),
              ),
              if (onRetry != null) ...[
                ChronosSpacing.vSizedBoxXL,
                Semantics(
                  button: true,
                  label: 'Tentar novamente',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(ChronosIcons.refresh, size: 18),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChronosColors.error,
                      foregroundColor: ChronosColors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
