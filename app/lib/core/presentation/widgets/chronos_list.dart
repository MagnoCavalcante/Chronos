import 'package:flutter/material.dart';
import '../../theme/chronos_spacing.dart';

/// Lista estruturada padronizada do CHRONOS.
///
/// Facilita a construção de listagens verticais ou horizontais aplicando
/// os tokens oficiais de espaçamento e divisores de forma integrada.
class ChronosList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final double separatorHeight;
  final bool showSeparator;

  const ChronosList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.physics,
    this.padding = const EdgeInsets.symmetric(
      vertical: ChronosSpacing.md,
    ),
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.separatorHeight = ChronosSpacing.md,
    this.showSeparator = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    if (showSeparator) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        physics: physics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: items.length,
        separatorBuilder: (context, index) => scrollDirection == Axis.vertical
            ? SizedBox(height: separatorHeight)
            : SizedBox(width: separatorHeight),
        itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      );
    }

    return ListView.builder(
      scrollDirection: scrollDirection,
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
    );
  }
}
