import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Cabeçalho estilizado para seções ou agrupamentos de conteúdo no CHRONOS.
///
/// Aceita título, subtítulo explicativo sutil, ícone temático e um botão de ação.
class ChronosSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;

  const ChronosSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Seção: $title',
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: ChronosSpacing.md,
          top: ChronosSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: ChronosColors.accent,
                size: 22,
              ),
              ChronosSpacing.hSizedBoxSM,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: ChronosTypography.titleLarge.copyWith(
                      color: ChronosColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    ChronosSpacing.vSizedBoxXXS,
                    Text(
                      subtitle!,
                      style: ChronosTypography.bodySmall.copyWith(
                        color: ChronosColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) ...[
              ChronosSpacing.hSizedBoxMD,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
