import 'package:flutter/material.dart';
import '../../theme/chronos_spacing.dart';
import 'chronos_responsive.dart';

/// Grade de Exibição Responsiva (Grid System) do CHRONOS.
///
/// Calcula de forma nativa a quantidade ideal de colunas dependendo do espaço
/// de tela (Viewport) e aplica os espaçamentos regulados por tokens.
class ChronosGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double childAspectRatio;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const ChronosGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = ChronosSpacing.md,
    this.childAspectRatio = 1.0,
    this.physics,
    this.padding = const EdgeInsets.all(ChronosSpacing.md),
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;

        if (constraints.maxWidth >= ChronosResponsive.tabletMax) {
          crossAxisCount = desktopColumns ?? 4;
        } else if (constraints.maxWidth >= ChronosResponsive.mobileMax) {
          crossAxisCount = tabletColumns ?? 2;
        } else {
          crossAxisCount = mobileColumns ?? 1;
        }

        return GridView.builder(
          physics: physics,
          padding: padding,
          shrinkWrap: shrinkWrap,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => itemBuilder(context, items[index], index),
        );
      },
    );
  }
}
