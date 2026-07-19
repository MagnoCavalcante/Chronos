import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';

/// Divisor estilizado oficial do CHRONOS.
///
/// Substitui o [Divider] do Material com espaçamento e cor vinculados aos tokens de design.
class ChronosDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final double indent;
  final double endIndent;

  const ChronosDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      color: color ?? ChronosColors.divider,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
