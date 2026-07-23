import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/accessibility_entities.dart';

/// Serviço de Acessibilidade Avançada do CHRONOS.
///
/// Suporta:
/// - Leitura por voz (preparação)
/// - Alto contraste
/// - Daltonismo (protanopia, deuteranopia, tritanopia)
/// - Escala dinâmica de fontes
/// - Feedback tátil (Haptic Feedback)
/// - Descrições automáticas para imagens
/// - Navegação totalmente acessível
class AccessibilityService extends ChangeNotifier {
  static const String _tag = 'AccessibilityService';
  static const String _prefsKey = 'chronos_accessibility_config';

  AccessibilityConfig _config = const AccessibilityConfig();

  /// Configuração atual de acessibilidade.
  AccessibilityConfig get config => _config;

  /// Carrega configurações salvas.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorIndex = prefs.getInt('${_prefsKey}_color') ?? 0;
      final fontScale = prefs.getDouble('${_prefsKey}_font_scale') ?? 1.0;
      final haptic = prefs.getBool('${_prefsKey}_haptic') ?? true;
      final screenReader = prefs.getBool('${_prefsKey}_screen_reader') ?? true;
      final autoDescribe = prefs.getBool('${_prefsKey}_auto_describe') ?? true;
      final reducedMotion = prefs.getBool('${_prefsKey}_reduced_motion') ?? false;

      _config = AccessibilityConfig(
        colorMode: AccessibilityMode.values[colorIndex.clamp(0, AccessibilityMode.values.length - 1)],
        fontScale: fontScale.clamp(0.8, 2.0),
        hapticFeedbackEnabled: haptic,
        screenReaderPrepared: screenReader,
        autoDescribeImages: autoDescribe,
        reducedMotion: reducedMotion,
      );
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar config de acessibilidade: $e', tag: _tag);
    }
  }

  /// Salva configurações.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_prefsKey}_color', _config.colorMode.index);
      await prefs.setDouble('${_prefsKey}_font_scale', _config.fontScale);
      await prefs.setBool('${_prefsKey}_haptic', _config.hapticFeedbackEnabled);
      await prefs.setBool('${_prefsKey}_screen_reader', _config.screenReaderPrepared);
      await prefs.setBool('${_prefsKey}_auto_describe', _config.autoDescribeImages);
      await prefs.setBool('${_prefsKey}_reduced_motion', _config.reducedMotion);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar config de acessibilidade: $e', tag: _tag);
    }
  }

  /// Define o modo de cor (alto contraste, daltonismo).
  Future<void> setColorMode(AccessibilityMode mode) async {
    _config = _config.copyWith(colorMode: mode);
    notifyListeners();
    await _save();
    ChronosLogger.info('Modo de cor alterado: ${mode.name}', tag: _tag);
  }

  /// Define a escala de fontes.
  Future<void> setFontScale(double scale) async {
    _config = _config.copyWith(fontScale: scale.clamp(0.8, 2.0));
    notifyListeners();
    await _save();
  }

  /// Ativa/desativa feedback tátil.
  Future<void> setHapticFeedback(bool enabled) async {
    _config = _config.copyWith(hapticFeedbackEnabled: enabled);
    notifyListeners();
    await _save();
  }

  /// Ativa/desativa descrição automática de imagens.
  Future<void> setAutoDescribeImages(bool enabled) async {
    _config = _config.copyWith(autoDescribeImages: enabled);
    notifyListeners();
    await _save();
  }

  /// Ativa/desativa movimento reduzido.
  Future<void> setReducedMotion(bool enabled) async {
    _config = _config.copyWith(reducedMotion: enabled);
    notifyListeners();
    await _save();
  }

  /// Dispara feedback tátil se habilitado.
  void hapticTap() {
    if (_config.hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Dispara feedback tátil pesado.
  void hapticHeavy() {
    if (_config.hapticFeedbackEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Gera descrição automática para imagem com base em metadados.
  String generateImageDescription({
    required String title,
    String? entityType,
    int? year,
    String? location,
  }) {
    final parts = <String>['Imagem: $title'];
    if (entityType != null) parts.add('Tipo: $entityType');
    if (year != null) parts.add('Ano: $year');
    if (location != null) parts.add('Local: $location');
    return parts.join('. ');
  }

  /// Reseta para configuração padrão.
  Future<void> reset() async {
    _config = const AccessibilityConfig();
    notifyListeners();
    await _save();
  }
}
