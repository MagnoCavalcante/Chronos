import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// Features que podem ser ativadas/desativadas em Beta.
enum BetaFeature {
  aiAssistant,
  mapView,
  exportSystem,
  presentationMode,
  gamification,
  studySystem,
  offlineMode,
  onboarding,
  feedbackSystem,
  whatsNew,
}

/// Sistema de Feature Toggle do CHRONOS Beta.
///
/// Permite ativar/desativar funcionalidades sem recompilar o app.
/// Ideal para testes controlados e rollback rápido.
class FeatureToggleService extends ChangeNotifier {
  static const String _tag = 'FeatureToggleService';
  static const String _prefix = 'chronos_feature_';

  final Map<BetaFeature, bool> _toggles = {};

  /// Verifica se uma feature está ativa.
  bool isEnabled(BetaFeature feature) => _toggles[feature] ?? true;

  /// Mapa de todas as toggles.
  Map<BetaFeature, bool> get allToggles => Map.unmodifiable(_toggles);

  /// Carrega toggles persistidos.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final feature in BetaFeature.values) {
        final key = '$_prefix${feature.name}';
        _toggles[feature] = prefs.getBool(key) ?? true;
      }
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar feature toggles: $e', tag: _tag);
    }
  }

  /// Ativa ou desativa uma feature.
  Future<void> setEnabled(BetaFeature feature, bool enabled) async {
    _toggles[feature] = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefix${feature.name}', enabled);
    } catch (_) {}
    ChronosLogger.info(
      'Feature ${feature.name}: ${enabled ? 'ATIVADA' : 'DESATIVADA'}',
      tag: _tag,
    );
    notifyListeners();
  }

  /// Ativa todas as features.
  Future<void> enableAll() async {
    for (final feature in BetaFeature.values) {
      await setEnabled(feature, true);
    }
  }

  /// Desativa todas as features.
  Future<void> disableAll() async {
    for (final feature in BetaFeature.values) {
      await setEnabled(feature, false);
    }
  }

  /// Reseta todas as toggles para padrão (todas ativas).
  Future<void> reset() async {
    _toggles.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final feature in BetaFeature.values) {
        await prefs.remove('$_prefix${feature.name}');
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Quantidade de features ativas.
  int get enabledCount => _toggles.values.where((v) => v).length;

  /// Quantidade de features desativadas.
  int get disabledCount => _toggles.values.where((v) => !v).length;
}
