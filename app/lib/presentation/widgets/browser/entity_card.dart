import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_card.dart';
import '../../../core/presentation/widgets/status_badge.dart';
import '../../../domain/entities/publication_status.dart';

/// Enum contendo os modos de visualização suportados pelos Cards.
enum EntityViewMode {
  compact,
  list,
  grid,
  large,
}

/// Representação padronizada dos campos visuais de qualquer Entidade histórica do CHRONOS.
class ChronosEntityDisplay {
  final String id;
  final String title;
  final String subtitle;
  final String? description;
  final String? imageUrl;
  final PublicationStatus? status;
  final String? chronology;
  final IconData? icon;
  final Color? color;
  final String? type;
  final String? category;
  final int? chronologyValue; // Ano de ocorrência ou de início para ordenação
  final DateTime? dateValue; // Timestamp de criação ou atualização para ordenação

  const ChronosEntityDisplay({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description,
    this.imageUrl,
    this.status,
    this.chronology,
    this.icon,
    this.color,
    this.type,
    this.category,
    this.chronologyValue,
    this.dateValue,
  });
}

/// Widget de exibição unificado e acessível para qualquer Entidade do CHRONOS.
///
/// Oferece suporte completo a 4 modos visuais diferentes ([EntityViewMode]):
/// - `compact`: Menor padding, focando em títulos e badges.
/// - `list`: Exibição clássica em cards médios com descrição e ícones.
/// - `grid`: Layout ideal para grades (bento-grid).
/// - `large`: Layout rico com banner/imagem de destaque, ideal para detalhes.
class EntityCard extends StatelessWidget {
  final ChronosEntityDisplay display;
  final EntityViewMode viewMode;
  final VoidCallback? onTap;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectedChanged;

  const EntityCard({
    super.key,
    required this.display,
    this.viewMode = EntityViewMode.list,
    this.onTap,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = display.color ?? ChronosColors.accent;

    return Semantics(
      label: '${display.title}, ${display.subtitle}',
      hint: display.description ?? 'Item do acervo CHRONOS',
      selected: selectionMode ? isSelected : null,
      enabled: true,
      button: true,
      child: Focus(
        child: ChronosCard(
          borderColor: isSelected
              ? ChronosColors.accent
              : themeColor.withValues(alpha: 0.2),
          borderWidth: isSelected ? 2.0 : 1.0,
          padding: EdgeInsets.zero,
          onTap: selectionMode
              ? () => onSelectedChanged?.call(!isSelected)
              : onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ChronosRadius.md),
            child: _buildCardContent(context, themeColor),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Color themeColor) {
    switch (viewMode) {
      case EntityViewMode.compact:
        return _buildCompactView(themeColor);
      case EntityViewMode.grid:
        return _buildGridView(themeColor);
      case EntityViewMode.large:
        return _buildLargeView(themeColor);
      case EntityViewMode.list:
      default:
        return _buildListView(themeColor);
    }
  }

  Widget _buildSelectionIndicator() {
    if (!selectionMode) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: ChronosSpacing.md),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Checkbox(
          value: isSelected,
          activeColor: ChronosColors.accent,
          onChanged: onSelectedChanged,
        ),
      ),
    );
  }

  Widget _buildCompactView(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.md,
        vertical: ChronosSpacing.sm,
      ),
      child: Row(
        children: [
          _buildSelectionIndicator(),
          _buildIconBox(themeColor, size: 36, iconSize: 18),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  display.title,
                  style: ChronosTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  display.subtitle,
                  style: ChronosTypography.bodySmall.copyWith(
                    color: ChronosColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (display.status != null) ...[
            ChronosSpacing.hSizedBoxSM,
            StatusBadge(status: display.status!.value),
          ],
        ],
      ),
    );
  }

  Widget _buildListView(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionIndicator(),
          _buildIconBox(themeColor, size: 48, iconSize: 24),
          ChronosSpacing.hSizedBoxLG,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        display.title,
                        style: ChronosTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (display.status != null) ...[
                      ChronosSpacing.hSizedBoxSM,
                      StatusBadge(status: display.status!.value),
                    ],
                  ],
                ),
                ChronosSpacing.vSizedBoxXS,
                Text(
                  display.subtitle,
                  style: ChronosTypography.bodySmall.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (display.description != null && display.description!.isNotEmpty) ...[
                  ChronosSpacing.vSizedBoxSM,
                  Text(
                    display.description!,
                    style: ChronosTypography.bodySmall.copyWith(
                      color: ChronosColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (display.chronology != null) ...[
                  ChronosSpacing.vSizedBoxSM,
                  _buildChronologyBadge(display.chronology!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (display.imageUrl != null)
          Container(
            height: 120,
            width: double.infinity,
            color: ChronosColors.surfaceLight,
            child: Image.network(
              display.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildGridPlaceholder(themeColor),
            ),
          )
        else
          _buildGridPlaceholder(themeColor),
        Padding(
          padding: const EdgeInsets.all(ChronosSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selectionMode) ...[
                    _buildSelectionIndicator(),
                  ],
                  Expanded(
                    child: Text(
                      display.title,
                      style: ChronosTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              ChronosSpacing.vSizedBoxXXS,
              Text(
                display.subtitle,
                style: ChronosTypography.bodySmall.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (display.chronology != null) ...[
                ChronosSpacing.vSizedBoxSM,
                _buildChronologyBadge(display.chronology!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeView(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (display.imageUrl != null)
          Container(
            height: 200,
            width: double.infinity,
            color: ChronosColors.surfaceLight,
            child: Image.network(
              display.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildLargePlaceholder(themeColor),
            ),
          )
        else
          _buildLargePlaceholder(themeColor),
        Padding(
          padding: const EdgeInsets.all(ChronosSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode) ...[
                    _buildSelectionIndicator(),
                  ],
                  _buildIconBox(themeColor, size: 36, iconSize: 18),
                  ChronosSpacing.hSizedBoxMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          display.title,
                          style: ChronosTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ChronosSpacing.vSizedBoxXXS,
                        Text(
                          display.subtitle,
                          style: ChronosTypography.bodyMedium.copyWith(
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (display.status != null) ...[
                    ChronosSpacing.hSizedBoxSM,
                    StatusBadge(status: display.status!.value),
                  ],
                ],
              ),
              if (display.description != null && display.description!.isNotEmpty) ...[
                ChronosSpacing.vSizedBoxLG,
                Text(
                  display.description!,
                  style: ChronosTypography.bodyMedium.copyWith(
                    color: ChronosColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
              ChronosSpacing.vSizedBoxMD,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (display.chronology != null)
                    _buildChronologyBadge(display.chronology!),
                  if (display.category != null || display.type != null)
                    Text(
                      display.category ?? display.type ?? '',
                      style: ChronosTypography.codeSmall.copyWith(
                        color: ChronosColors.textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBox(Color color, {required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ChronosRadius.sm),
      ),
      child: Icon(
        display.icon ?? Icons.layers_outlined,
        color: color,
        size: iconSize,
      ),
    );
  }

  Widget _buildChronologyBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.sm,
        vertical: ChronosSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: ChronosColors.surfaceLight,
        borderRadius: BorderRadius.circular(ChronosRadius.xs),
        border: Border.all(color: ChronosColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_filled_rounded,
            size: 12,
            color: ChronosColors.textMuted,
          ),
          ChronosSpacing.hSizedBoxXXS,
          Text(
            label,
            style: ChronosTypography.codeSmall.copyWith(
              color: ChronosColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPlaceholder(Color themeColor) {
    return Container(
      height: 120,
      width: double.infinity,
      color: themeColor.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          display.icon ?? Icons.layers_outlined,
          color: themeColor.withValues(alpha: 0.3),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildLargePlaceholder(Color themeColor) {
    return Container(
      height: 200,
      width: double.infinity,
      color: themeColor.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          display.icon ?? Icons.layers_outlined,
          color: themeColor.withValues(alpha: 0.3),
          size: 60,
        ),
      ),
    );
  }
}
