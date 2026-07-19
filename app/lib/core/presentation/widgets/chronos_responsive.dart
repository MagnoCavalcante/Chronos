import 'package:flutter/material.dart';

/// Builder responsivo padronizado do CHRONOS.
///
/// Facilita o design adaptativo separando telas por categorias de tamanho
/// (mobile, tablet, desktop).
class ChronosResponsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ChronosResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Breakpoints de largura padrão
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMax &&
      MediaQuery.of(context).size.width < tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletMax) {
          return desktop;
        }
        if (constraints.maxWidth >= mobileMax) {
          return tablet ?? desktop;
        }
        return mobile;
      },
    );
  }
}
