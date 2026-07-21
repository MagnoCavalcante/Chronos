import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_icons.dart';
import '../../theme/chronos_typography.dart';
import 'chronos_button.dart';

/// Estado Vazio (Empty State) padronizado do CHRONOS.
///
/// Componente completo com ícone elegante, título, descrição e botão de ação opcional.
class ChronosEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const ChronosEmptyState({
    super.key,
    this.title = 'Nenhum registro encontrado',
    this.description = 'Ainda não existem informações ou cadastros para exibir nesta seção.',
    this.icon = ChronosIcons.empty,
    this.actionLabel,
    this.onActionPressed,
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
            // Círculo de destaque com o ícone semântico
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ChronosColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: ChronosColors.textMuted,
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
              description,
              textAlign: TextAlign.center,
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ChronosButton(
                label: actionLabel!,
                onPressed: onActionPressed!,
                variant: ChronosButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
