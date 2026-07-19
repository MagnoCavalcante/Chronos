import 'package:flutter/material.dart';

/// Design Tokens de Espaçamento para o ecossistema CHRONOS.
///
/// Define as dimensões padrão de padding, margens e espaçamentos internos.
abstract class ChronosSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double giant = 64.0;

  // SizedBox horizontais convenientes (Larguras)
  static const SizedBox hSizedBoxXXS = SizedBox(width: xxs);
  static const SizedBox hSizedBoxXS = SizedBox(width: xs);
  static const SizedBox hSizedBoxSM = SizedBox(width: sm);
  static const SizedBox hSizedBoxMD = SizedBox(width: md);
  static const SizedBox hSizedBoxLG = SizedBox(width: lg);
  static const SizedBox hSizedBoxXL = SizedBox(width: xl);
  static const SizedBox hSizedBoxXXL = SizedBox(width: xxl);
  static const SizedBox hSizedBoxXXXL = SizedBox(width: xxxl);

  // SizedBox verticais convenientes (Alturas)
  static const SizedBox vSizedBoxXXS = SizedBox(height: xxs);
  static const SizedBox vSizedBoxXS = SizedBox(height: xs);
  static const SizedBox vSizedBoxSM = SizedBox(height: sm);
  static const SizedBox vSizedBoxMD = SizedBox(height: md);
  static const SizedBox vSizedBoxLG = SizedBox(height: lg);
  static const SizedBox vSizedBoxXL = SizedBox(height: xl);
  static const SizedBox vSizedBoxXXL = SizedBox(height: xxl);
  static const SizedBox vSizedBoxXXXL = SizedBox(height: xxxl);
  static const SizedBox vSizedBoxHuge = SizedBox(height: huge);
  static const SizedBox vSizedBoxGiant = SizedBox(height: giant);

  // EdgeInsets predefinidos para reutilização
  static const EdgeInsets edgeInsetsZero = EdgeInsets.zero;
  static const EdgeInsets edgeInsetsAllXS = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsAllSM = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsAllMD = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsAllLG = EdgeInsets.all(lg);
  static const EdgeInsets edgeInsetsAllXL = EdgeInsets.all(xl);
  static const EdgeInsets edgeInsetsAllXXL = EdgeInsets.all(xxl);

  static const EdgeInsets edgeInsetsHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets edgeInsetsHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets edgeInsetsHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets edgeInsetsHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets edgeInsetsVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets edgeInsetsVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets edgeInsetsVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets edgeInsetsVerticalXL = EdgeInsets.symmetric(vertical: xl);
}
