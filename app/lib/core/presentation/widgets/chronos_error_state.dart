import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_icons.dart';
import '../../theme/chronos_typography.dart';
import 'chronos_retry_button.dart';

/// Estado de Erro (Error State) padronizado do CHRONOS.
///
/// Componente para exibir falhas, problemas de conexão ou indisponibilidades de dados,
/// permitindo a ação de tentar carregar novamente (Retry).
class ChronosErrorState extends StatelessWidget {
  final String title;
  final String errorMessage;
  final IconData icon;
  final VoidCallback? onRetry;

  const ChronosErrorState({
    super.key,
    this.title = 'Ops! Algo deu errado',
    required this.errorMessage,
    this.icon = ChronosIcons.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Destaque para o ícone de Erro (Vermelho Semântico)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ChronosColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: ChronosColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ChronosTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ChronosRetryButton(onRetry: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}
