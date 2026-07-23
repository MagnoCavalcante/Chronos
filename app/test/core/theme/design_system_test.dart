import 'package:chronos/core/theme/chronos_animation.dart';
import 'package:chronos/core/theme/chronos_colors.dart';
import 'package:chronos/core/theme/chronos_elevation.dart';
import 'package:chronos/core/theme/chronos_radius.dart';
import 'package:chronos/core/theme/chronos_spacing.dart';
import 'package:chronos/core/theme/chronos_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChronosColors', () {
    test('paleta principal definida', () {
      expect(ChronosColors.primary, isNotNull);
      expect(ChronosColors.accent, isNotNull);
      expect(ChronosColors.background, isNotNull);
    });

    test('cores semânticas definidas', () {
      expect(ChronosColors.success, isNotNull);
      expect(ChronosColors.error, isNotNull);
      expect(ChronosColors.warning, isNotNull);
      expect(ChronosColors.info, isNotNull);
    });
  });

  group('ChronosSpacing', () {
    test('escala progressiva', () {
      expect(ChronosSpacing.xxs < ChronosSpacing.xs, isTrue);
      expect(ChronosSpacing.xs < ChronosSpacing.sm, isTrue);
      expect(ChronosSpacing.sm < ChronosSpacing.md, isTrue);
      expect(ChronosSpacing.md < ChronosSpacing.lg, isTrue);
      expect(ChronosSpacing.lg < ChronosSpacing.xl, isTrue);
    });
  });

  group('ChronosRadius', () {
    test('escala progressiva', () {
      expect(ChronosRadius.xs < ChronosRadius.sm, isTrue);
      expect(ChronosRadius.sm < ChronosRadius.md, isTrue);
      expect(ChronosRadius.md < ChronosRadius.lg, isTrue);
      expect(ChronosRadius.lg < ChronosRadius.xl, isTrue);
    });

    test('borderRadius correspondentes existem', () {
      expect(ChronosRadius.borderRadiusSM, isNotNull);
      expect(ChronosRadius.borderRadiusMD, isNotNull);
      expect(ChronosRadius.borderRadiusLG, isNotNull);
    });
  });

  group('ChronosElevation', () {
    test('níveis definidos corretamente', () {
      expect(ChronosElevation.none, 0);
      expect(ChronosElevation.sm, 2);
      expect(ChronosElevation.md, 4);
      expect(ChronosElevation.lg, 8);
      expect(ChronosElevation.xl, 12);
    });

    test('decorations existem', () {
      expect(ChronosElevation.decorationSM.boxShadow, isNotNull);
      expect(ChronosElevation.decorationMD.boxShadow, isNotNull);
      expect(ChronosElevation.decorationLG.boxShadow, isNotNull);
    });
  });

  group('ChronosAnimation', () {
    test('durações em ordem crescente', () {
      expect(ChronosAnimation.instant < ChronosAnimation.fast, isTrue);
      expect(ChronosAnimation.fast < ChronosAnimation.normal, isTrue);
      expect(ChronosAnimation.normal < ChronosAnimation.slow, isTrue);
      expect(ChronosAnimation.slow < ChronosAnimation.slower, isTrue);
    });

    test('curvas definidas', () {
      expect(ChronosAnimation.defaultCurve, isNotNull);
      expect(ChronosAnimation.enterCurve, isNotNull);
      expect(ChronosAnimation.exitCurve, isNotNull);
    });
  });

  group('ChronosTheme', () {
    test('darkTheme é válido', () {
      final theme = ChronosTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, ChronosColors.accent);
    });

    test('darkTheme usa fontes corretas', () {
      final theme = ChronosTheme.darkTheme;
      expect(theme.textTheme.bodyLarge, isNotNull);
      expect(theme.textTheme.titleLarge, isNotNull);
    });
  });
}
