import 'package:flutter/foundation.dart';

import '../../../core/theme/chronos_colors.dart';
import '../../../core/theme/chronos_spacing.dart';
import '../../../core/theme/chronos_radius.dart';
import '../../../core/theme/chronos_typography.dart';

/// UI Inspector interno do CHRONOS.
///
/// Tela oculta para desenvolvedores mostrando componentes, espaçamentos, tema e breakpoints.
class UIInspectorService {
  /// Retorna lista de tokens de cor para inspeção.
  List<TokenEntry> getColorTokens() {
    return [
      TokenEntry('primary', '#0F172A', ChronosColors.primary.value),
      TokenEntry('primaryLight', '#1E293B', ChronosColors.primaryLight.value),
      TokenEntry('accent', '#F59E0B', ChronosColors.accent.value),
      TokenEntry('background', '#0B0F19', ChronosColors.background.value),
      TokenEntry('surface', '#151D30', ChronosColors.surface.value),
      TokenEntry('surfaceLight', '#1E293B', ChronosColors.surfaceLight.value),
      TokenEntry('textPrimary', '#F8FAFC', ChronosColors.textPrimary.value),
      TokenEntry('textSecondary', '#94A3B8', ChronosColors.textSecondary.value),
      TokenEntry('textMuted', '#64748B', ChronosColors.textMuted.value),
      TokenEntry('success', '#10B981', ChronosColors.success.value),
      TokenEntry('error', '#EF4444', ChronosColors.error.value),
      TokenEntry('warning', '#F59E0B', ChronosColors.warning.value),
      TokenEntry('info', '#3B82F6', ChronosColors.info.value),
    ];
  }

  /// Retorna lista de tokens de espaçamento.
  List<TokenEntry> getSpacingTokens() {
    return [
      TokenEntry('xxs', '2.0', ChronosSpacing.xxs.toInt()),
      TokenEntry('xs', '4.0', ChronosSpacing.xs.toInt()),
      TokenEntry('sm', '8.0', ChronosSpacing.sm.toInt()),
      TokenEntry('md', '12.0', ChronosSpacing.md.toInt()),
      TokenEntry('lg', '16.0', ChronosSpacing.lg.toInt()),
      TokenEntry('xl', '20.0', ChronosSpacing.xl.toInt()),
      TokenEntry('xxl', '24.0', ChronosSpacing.xxl.toInt()),
      TokenEntry('xxxl', '32.0', ChronosSpacing.xxxl.toInt()),
      TokenEntry('huge', '48.0', ChronosSpacing.huge.toInt()),
      TokenEntry('giant', '64.0', ChronosSpacing.giant.toInt()),
    ];
  }

  /// Retorna lista de tokens de radius.
  List<TokenEntry> getRadiusTokens() {
    return [
      TokenEntry('xs', '4.0', ChronosRadius.xs.toInt()),
      TokenEntry('sm', '8.0', ChronosRadius.sm.toInt()),
      TokenEntry('md', '12.0', ChronosRadius.md.toInt()),
      TokenEntry('lg', '16.0', ChronosRadius.lg.toInt()),
      TokenEntry('xl', '24.0', ChronosRadius.xl.toInt()),
      TokenEntry('xxl', '32.0', ChronosRadius.xxl.toInt()),
      TokenEntry('circular', '999.0', ChronosRadius.circular.toInt()),
    ];
  }

  /// Retorna lista de tokens de tipografia.
  List<TokenEntry> getTypographyTokens() {
    return [
      TokenEntry('displayLarge', '32px Bold', 32),
      TokenEntry('displayMedium', '26px Bold', 26),
      TokenEntry('displaySmall', '22px Bold', 22),
      TokenEntry('titleLarge', '18px Bold', 18),
      TokenEntry('titleMedium', '16px SemiBold', 16),
      TokenEntry('titleSmall', '14px SemiBold', 14),
      TokenEntry('bodyLarge', '16px Regular', 16),
      TokenEntry('bodyMedium', '14px Regular', 14),
      TokenEntry('bodySmall', '12px Regular', 12),
      TokenEntry('labelLarge', '14px Bold', 14),
      TokenEntry('labelSmall', '10px Bold', 10),
    ];
  }

  /// Retorna breakpoints para responsividade.
  Map<String, double> getBreakpoints() {
    return {
      'smallPhone': 320,
      'phone': 375,
      'largePhone': 414,
      'tablet': 768,
      'landscape': 812,
    };
  }

  /// Indica se estamos em modo debug.
  bool get isDebugMode => kDebugMode;
}

/// Entrada de token para visualização.
class TokenEntry {
  final String name;
  final String displayValue;
  final int rawValue;

  const TokenEntry(this.name, this.displayValue, this.rawValue);
}
