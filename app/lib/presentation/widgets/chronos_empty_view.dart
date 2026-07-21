import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_icons.dart';
import '../../core/theme/chronos_radius.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Componente oficial para representação de listas, filtros ou buscas vazias (Empty State).
///
/// Aceita personalização de [icon], [title] principal, [description] de apoio,
/// e uma [action] opcional (ex: botão de limpar filtros ou cadastrar).
class ChronosEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const ChronosEmptyView({
    super.key,
    this.icon = ChronosIcons.empty,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nenhum resultado encontrado',
      hint: '$title: $description',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ChronosSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(ChronosSpacing.lg),
                decoration: BoxDecoration(
                  color: ChronosColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ChronosColors.border,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 44,
                  color: ChronosColors.accent,
                ),
              ),
              ChronosSpacing.vSizedBoxLG,
              Text(
                title,
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              ChronosSpacing.vSizedBoxSM,
              Text(
                description,
                textAlign: TextAlign.center,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textSecondary,
                ),
              ),
              if (action != null) ...[
                ChronosSpacing.vSizedBoxXL,
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
