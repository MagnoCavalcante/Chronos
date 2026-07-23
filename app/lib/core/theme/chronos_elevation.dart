import 'package:flutter/material.dart';
import 'chronos_colors.dart';

/// Design Tokens de Elevação para o ecossistema CHRONOS.
///
/// Define os níveis de elevação padronizados para hierarquia visual.
abstract class ChronosElevation {
  // Níveis de elevação Material
  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 12;
  static const double xxl = 24;

  // BoxDecoration com sombras para cada nível
  static BoxDecoration decorationNone = const BoxDecoration();

  static BoxDecoration decorationSM = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.08),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );

  static BoxDecoration decorationMD = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.12),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.06),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );

  static BoxDecoration decorationLG = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.15),
        offset: const Offset(0, 4),
        blurRadius: 8,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.08),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  static BoxDecoration decorationXL = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.2),
        offset: const Offset(0, 8),
        blurRadius: 16,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: ChronosColors.black.withValues(alpha: 0.1),
        offset: const Offset(0, 4),
        blurRadius: 8,
      ),
    ],
  );
}
