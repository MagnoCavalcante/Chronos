import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_radius.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Card unificado e acessível para exibição estruturada de entidades no ecossistema CHRONOS.
///
/// Pode conter imagem (leading), ações (trailing), textos descritivos e cliques (onTap).
class ChronosCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ChronosCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.cardTheme.color ?? ChronosColors.surface;
    final radius = borderRadius ?? ChronosRadius.borderRadiusMD;
    final edgePadding = padding ?? ChronosSpacing.edgeInsetsAllMD;
    final cardElevation = elevation ?? theme.cardTheme.elevation ?? 2.0;

    Widget cardContent = Padding(
      padding: edgePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            ChronosSpacing.hSizedBoxMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: ChronosTypography.titleMedium.copyWith(
                    color: ChronosColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  ChronosSpacing.vSizedBoxXS,
                  Text(
                    subtitle!,
                    style: ChronosTypography.bodySmall.copyWith(
                      color: ChronosColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (description != null && description!.isNotEmpty) ...[
                  ChronosSpacing.vSizedBoxSM,
                  Text(
                    description!,
                    style: ChronosTypography.bodyMedium.copyWith(
                      color: ChronosColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            ChronosSpacing.hSizedBoxMD,
            trailing!,
          ],
        ],
      ),
    );

    // Se possui clique, envelopa com InkWell para dar feedback visual de toque (Ripple)
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: cardContent,
      );
    }

    final boxDecoration = BoxDecoration(
      color: cardColor,
      borderRadius: radius,
      border: borderColor != null
          ? Border.all(color: borderColor!, width: 1.0)
          : Border.all(color: ChronosColors.border, width: 1.0),
      boxShadow: cardElevation > 0
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: cardElevation * 2,
                offset: Offset(0, cardElevation),
              )
            ]
          : null,
    );

    return Semantics(
      container: true,
      label: 'Card: $title${subtitle != null ? ', $subtitle' : ''}',
      hint: onTap != null ? 'Toque duas vezes para abrir detalhes.' : null,
      button: onTap != null,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: ChronosSpacing.md),
        decoration: boxDecoration,
        child: ClipRRect(
          borderRadius: radius,
          child: cardContent,
        ),
      ),
    );
  }
}
