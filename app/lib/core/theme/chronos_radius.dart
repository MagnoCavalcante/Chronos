import 'package:flutter/material.dart';

/// Design Tokens de Arredondamento (Border Radius) para o ecossistema CHRONOS.
///
/// Define as diretrizes para cantos arredondados de cards, botões, inputs e avatares.
abstract class ChronosRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double circular = 999.0;

  // BorderRadius correspondentes
  static const BorderRadius borderRadiusZero = BorderRadius.zero;
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderRadiusCircular = BorderRadius.all(Radius.circular(circular));

  // RoundedRectangleBorder correspondentes para facilitar o uso em Cards e Buttons
  static const RoundedRectangleBorder shapeXS = RoundedRectangleBorder(
    borderRadius: borderRadiusXS,
  );
  static const RoundedRectangleBorder shapeSM = RoundedRectangleBorder(
    borderRadius: borderRadiusSM,
  );
  static const RoundedRectangleBorder shapeMD = RoundedRectangleBorder(
    borderRadius: borderRadiusMD,
  );
  static const RoundedRectangleBorder shapeLG = RoundedRectangleBorder(
    borderRadius: borderRadiusLG,
  );
  static const RoundedRectangleBorder shapeXL = RoundedRectangleBorder(
    borderRadius: borderRadiusXL,
  );
  static const RoundedRectangleBorder shapeCircular = RoundedRectangleBorder(
    borderRadius: borderRadiusCircular,
  );
}
