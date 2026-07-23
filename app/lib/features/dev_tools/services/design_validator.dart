import 'package:flutter/material.dart';

import '../../../core/theme/chronos_colors.dart';
import '../../../core/theme/chronos_typography.dart';

/// Resultado de validação do design.
class DesignIssue {
  final String component;
  final String issue;
  final DesignIssueSeverity severity;

  const DesignIssue({
    required this.component,
    required this.issue,
    required this.severity,
  });
}

enum DesignIssueSeverity { error, warning, info }

/// Design Validator do CHRONOS.
///
/// Detecta automaticamente:
/// - Cores incorretas (fora do ChronosColors)
/// - Fontes fora do padrão
/// - Componentes inconsistentes
class DesignValidator {
  /// Valida uma cor contra a paleta oficial.
  static DesignIssue? validateColor(Color color, String componentName) {
    final validColors = [
      ChronosColors.primary,
      ChronosColors.primaryLight,
      ChronosColors.primaryDark,
      ChronosColors.accent,
      ChronosColors.accentLight,
      ChronosColors.accentDark,
      ChronosColors.background,
      ChronosColors.surface,
      ChronosColors.surfaceLight,
      ChronosColors.border,
      ChronosColors.borderLight,
      ChronosColors.divider,
      ChronosColors.textPrimary,
      ChronosColors.textSecondary,
      ChronosColors.textMuted,
      ChronosColors.textOnAccent,
      ChronosColors.success,
      ChronosColors.successLight,
      ChronosColors.error,
      ChronosColors.errorLight,
      ChronosColors.warning,
      ChronosColors.warningLight,
      ChronosColors.info,
      ChronosColors.infoLight,
      ChronosColors.transparent,
      ChronosColors.white,
      ChronosColors.black,
    ];

    if (!validColors.contains(color)) {
      return DesignIssue(
        component: componentName,
        issue: 'Cor #${color.value.toRadixString(16)} não pertence ao ChronosColors',
        severity: DesignIssueSeverity.warning,
      );
    }
    return null;
  }

  /// Valida uma TextStyle contra a tipografia oficial.
  static DesignIssue? validateTextStyle(TextStyle style, String componentName) {
    final validFamilies = [ChronosTypography.sansFamily, ChronosTypography.monoFamily];
    if (style.fontFamily != null && !validFamilies.contains(style.fontFamily)) {
      return DesignIssue(
        component: componentName,
        issue: 'Fonte "${style.fontFamily}" não pertence ao ChronosTypography',
        severity: DesignIssueSeverity.error,
      );
    }
    return null;
  }

  /// Valida um tamanho de fonte contra os tamanhos oficiais.
  static DesignIssue? validateFontSize(double fontSize, String componentName) {
    const validSizes = [10.0, 11.0, 12.0, 13.0, 14.0, 16.0, 18.0, 22.0, 26.0, 32.0];
    if (!validSizes.contains(fontSize)) {
      return DesignIssue(
        component: componentName,
        issue: 'Tamanho de fonte $fontSize não é padrão do Design System',
        severity: DesignIssueSeverity.info,
      );
    }
    return null;
  }

  /// Valida contraste entre texto e fundo (WCAG AA mínimo 4.5:1).
  static DesignIssue? validateContrast(Color foreground, Color background, String componentName) {
    final ratio = _contrastRatio(foreground, background);
    if (ratio < 4.5) {
      return DesignIssue(
        component: componentName,
        issue: 'Contraste insuficiente: ${ratio.toStringAsFixed(2)}:1 (mínimo 4.5:1)',
        severity: DesignIssueSeverity.error,
      );
    }
    return null;
  }

  static double _contrastRatio(Color c1, Color c2) {
    final l1 = _luminance(c1);
    final l2 = _luminance(c2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _luminance(Color color) {
    double r = color.red / 255.0;
    double g = color.green / 255.0;
    double b = color.blue / 255.0;
    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055);
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055);
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
}
