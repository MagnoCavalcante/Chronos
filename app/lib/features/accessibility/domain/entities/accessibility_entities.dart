/// Modo de acessibilidade ativo.
enum AccessibilityMode {
  standard,
  highContrast,
  protanopia,
  deuteranopia,
  tritanopia,
}

/// Configuração de acessibilidade do usuário.
class AccessibilityConfig {
  final AccessibilityMode colorMode;
  final double fontScale;
  final bool hapticFeedbackEnabled;
  final bool screenReaderPrepared;
  final bool autoDescribeImages;
  final bool reducedMotion;

  const AccessibilityConfig({
    this.colorMode = AccessibilityMode.standard,
    this.fontScale = 1.0,
    this.hapticFeedbackEnabled = true,
    this.screenReaderPrepared = true,
    this.autoDescribeImages = true,
    this.reducedMotion = false,
  });

  AccessibilityConfig copyWith({
    AccessibilityMode? colorMode,
    double? fontScale,
    bool? hapticFeedbackEnabled,
    bool? screenReaderPrepared,
    bool? autoDescribeImages,
    bool? reducedMotion,
  }) =>
      AccessibilityConfig(
        colorMode: colorMode ?? this.colorMode,
        fontScale: fontScale ?? this.fontScale,
        hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
        screenReaderPrepared: screenReaderPrepared ?? this.screenReaderPrepared,
        autoDescribeImages: autoDescribeImages ?? this.autoDescribeImages,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );
}
