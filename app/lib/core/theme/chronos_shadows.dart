import 'package:flutter/material.dart';
import 'chronos_colors.dart';

/// Design Tokens de Sombra e Elevação para o ecossistema CHRONOS.
///
/// Define as sombras para dar sensação de profundidade e hierarquia visual.
abstract class ChronosShadows {
  // Sombras individuais
  static final BoxShadow shadowSM = BoxShadow(
    color: ChronosColors.black.withOpacity(0.15),
    offset: const Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );

  static final BoxShadow shadowMD = BoxShadow(
    color: ChronosColors.black.withOpacity(0.25),
    offset: const Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -1,
  );

  static final BoxShadow shadowLG = BoxShadow(
    color: ChronosColors.black.withOpacity(0.4),
    offset: const Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
  );

  // Listas de BoxShadow prontas para decoração
  static final List<BoxShadow> none = const [];
  static final List<BoxShadow> sm = [shadowSM];
  static final List<BoxShadow> md = [shadowMD];
  static final List<BoxShadow> lg = [shadowLG];
}
