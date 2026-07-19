import 'package:flutter/material.dart';
import '../../theme/chronos_icons.dart';
import 'chronos_button.dart';

/// Botão de Repetição (Retry Button) padronizado do CHRONOS.
///
/// Encapsula a ação comum de tentar carregar novamente os dados de uma tela ou seção.
class ChronosRetryButton extends StatelessWidget {
  final VoidCallback onRetry;
  final String label;
  final bool fullWidth;

  const ChronosRetryButton({
    super.key,
    required this.onRetry,
    this.label = 'Tentar Novamente',
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosButton(
      label: label,
      onPressed: onRetry,
      variant: ChronosButtonVariant.outline,
      icon: ChronosIcons.refresh,
      fullWidth: fullWidth,
    );
  }
}
