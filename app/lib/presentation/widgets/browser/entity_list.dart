import 'package:flutter/material.dart';
import 'entity_card.dart';
import '../../../core/theme/theme.dart';

/// Lista de exibição padronizada, acessível e responsiva para qualquer Entidade do CHRONOS.
class EntityList<T> extends StatelessWidget {
  final List<T> items;
  final ChronosEntityDisplay Function(T) displayMapper;
  final EntityViewMode viewMode;
  final ScrollController? scrollController;
  final EdgeInsets padding;
  final double spacing;
  final bool selectionMode;
  final List<String> selectedIds;
  final Function(T)? onTap;
  final Function(T, bool)? onSelectedChanged;

  const EntityList({
    super.key,
    required this.items,
    required this.displayMapper,
    this.viewMode = EntityViewMode.list,
    this.scrollController,
    this.padding = const EdgeInsets.symmetric(
      vertical: ChronosSpacing.md,
      horizontal: ChronosSpacing.lg,
    ),
    this.spacing = ChronosSpacing.md,
    this.selectionMode = false,
    this.selectedIds = const [],
    this.onTap,
    this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final display = displayMapper(item);
        final bool isSelected = selectedIds.contains(display.id);

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == items.length - 1 ? 0 : spacing,
          ),
          child: EntityCard(
            display: display,
            viewMode: viewMode,
            onTap: () => onTap?.call(item),
            selectionMode: selectionMode,
            isSelected: isSelected,
            onSelectedChanged: (checked) {
              if (checked != null && onSelectedChanged != null) {
                onSelectedChanged!(item, checked);
              }
            },
          ),
        );
      },
    );
  }
}
