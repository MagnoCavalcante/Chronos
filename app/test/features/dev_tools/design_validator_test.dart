import 'package:chronos/core/theme/chronos_colors.dart';
import 'package:chronos/features/dev_tools/services/design_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DesignValidator', () {
    test('validateColor aceita cor válida', () {
      final issue = DesignValidator.validateColor(ChronosColors.accent, 'Button');
      expect(issue, isNull);
    });

    test('validateColor rejeita cor inválida', () {
      final issue = DesignValidator.validateColor(const Color(0xFF123456), 'CustomWidget');
      expect(issue, isNotNull);
      expect(issue!.severity, DesignIssueSeverity.warning);
      expect(issue.issue, contains('não pertence'));
    });

    test('validateTextStyle aceita fonte válida', () {
      const style = TextStyle(fontFamily: 'Inter');
      final issue = DesignValidator.validateTextStyle(style, 'Title');
      expect(issue, isNull);
    });

    test('validateTextStyle rejeita fonte inválida', () {
      const style = TextStyle(fontFamily: 'Roboto');
      final issue = DesignValidator.validateTextStyle(style, 'Title');
      expect(issue, isNotNull);
      expect(issue!.severity, DesignIssueSeverity.error);
    });

    test('validateFontSize aceita tamanho válido', () {
      final issue = DesignValidator.validateFontSize(14.0, 'Body');
      expect(issue, isNull);
    });

    test('validateFontSize detecta tamanho não padrão', () {
      final issue = DesignValidator.validateFontSize(15.0, 'Custom');
      expect(issue, isNotNull);
      expect(issue!.severity, DesignIssueSeverity.info);
    });

    test('validateContrast detecta contraste insuficiente', () {
      final issue = DesignValidator.validateContrast(
        const Color(0xFF555555),
        const Color(0xFF666666),
        'LowContrast',
      );
      expect(issue, isNotNull);
      expect(issue!.issue, contains('Contraste insuficiente'));
    });

    test('validateContrast aceita contraste suficiente', () {
      final issue = DesignValidator.validateContrast(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
        'HighContrast',
      );
      expect(issue, isNull);
    });
  });
}
