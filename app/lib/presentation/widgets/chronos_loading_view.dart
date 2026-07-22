import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Componente centralizado para exibição de estados de carregamento (Loading) no ecossistema CHRONOS.
///
/// Apresenta o indicador circular customizado, com mensagens e ícones opcionais de ambientação.
class ChronosLoadingView extends StatelessWidget {
  final String? message;
  final IconData? icon;

  const ChronosLoadingView({
    super.key,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ?? 'Buscando informações históricas...';

    return Semantics(
      label: 'Carregando',
      hint: displayMessage,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ChronosSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 40,
                  color: ChronosColors.accent.withValues(alpha: 0.6),
                ),
                ChronosSpacing.vSizedBoxMD,
              ],
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(ChronosColors.accent),
                  backgroundColor: ChronosColors.primaryLight,
                ),
              ),
              ChronosSpacing.vSizedBoxLG,
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
