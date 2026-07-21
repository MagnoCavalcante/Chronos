import 'package:flutter/material.dart';
import 'entity_card.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_responsive.dart';

/// Grade de exibição padronizada, acessível e responsiva para qualquer Entidade do CHRONOS.
class EntityGrid<T> extends StatelessWidget {
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

  const EntityGrid({
    super.key,
    required this.items,
    required this.displayMapper,
    this.viewMode = EntityViewMode.grid,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          controller: scrollController,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final display = displayMapper(item);
            final bool isSelected = selectedIds.contains(display.id);

            return EntityCard(
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
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < ChronosResponsive.mobileBreakpoint) {
      return 1;
    } else if (width < ChronosResponsive.tabletBreakpoint) {
      return 2;
    } else {
      return 3;
    }
  }

  double _getChildAspectRatio(double width) {
    if (viewMode == EntityViewMode.large) {
      if (width < ChronosResponsive.mobileBreakpoint) {
        return 0.9;
      } else if (width < ChronosResponsive.tabletBreakpoint) {
        return 0.8;
      } else {
        return 0.85;
      }
    } else {
      // standard grid view
      if (width < ChronosResponsive.mobileBreakpoint) {
        return 1.8;
      } else if (width < ChronosResponsive.tabletBreakpoint) {
        return 1.4;
      } else {
        return 1.3;
      }
    }
  }
}
