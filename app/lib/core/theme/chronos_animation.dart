import 'package:flutter/material.dart';

/// Design Tokens de Animação para o ecossistema CHRONOS.
///
/// Padroniza durações e curvas para consistência visual em toda a aplicação.
/// Evita animações excessivas e garante fluidez premium.
abstract class ChronosAnimation {
  // ─── Durações ─────────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 600);
  static const Duration page = Duration(milliseconds: 350);

  // ─── Curvas ───────────────────────────────────────────────────
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeInOutCubicEmphasized;
  static const Curve decelerate = Curves.decelerate;

  // ─── Offsets para SlideTransition ─────────────────────────────
  static const Offset slideFromBottom = Offset(0, 0.1);
  static const Offset slideFromTop = Offset(0, -0.1);
  static const Offset slideFromRight = Offset(0.1, 0);
  static const Offset slideFromLeft = Offset(-0.1, 0);

  // ─── Valores padrão de escala ─────────────────────────────────
  static const double scaleStart = 0.95;
  static const double scaleEnd = 1.0;
  static const double microScaleStart = 0.98;
}
