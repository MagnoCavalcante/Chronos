import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// Serviço de Dicas Contextuais (Tooltips) do CHRONOS.
///
/// Mostra dicas apenas na primeira utilização de cada feature.
/// Permite reativar em Configurações.
class TooltipService extends ChangeNotifier {
  static const String _tag = 'TooltipService';
  static const String _prefix = 'chronos_tooltip_seen_';

  final Set<String> _seenTooltips = {};
  bool _tooltipsEnabled = true;

  /// Se tooltips estão habilitados globalmente.
  bool get tooltipsEnabled => _tooltipsEnabled;

  /// Carrega tooltips vistos do armazenamento.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _tooltipsEnabled = prefs.getBool('${_prefix}enabled') ?? true;
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix) && k != '${_prefix}enabled');
      _seenTooltips.clear();
      for (final key in keys) {
        if (prefs.getBool(key) == true) {
          _seenTooltips.add(key.replaceFirst(_prefix, ''));
        }
      }
    } catch (e) {
      ChronosLogger.error('Erro ao carregar tooltips: $e', tag: _tag);
    }
  }

  /// Verifica se um tooltip deve ser mostrado.
  bool shouldShow(String tooltipId) {
    if (!_tooltipsEnabled) return false;
    return !_seenTooltips.contains(tooltipId);
  }

  /// Marca um tooltip como visto.
  Future<void> markSeen(String tooltipId) async {
    _seenTooltips.add(tooltipId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefix$tooltipId', true);
    } catch (_) {}
    notifyListeners();
  }

  /// Habilita/desabilita tooltips globalmente.
  Future<void> setEnabled(bool enabled) async {
    _tooltipsEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_prefix}enabled', enabled);
    } catch (_) {}
    notifyListeners();
  }

  /// Reseta todos os tooltips (reativa todas as dicas).
  Future<void> resetAll() async {
    _seenTooltips.clear();
    _tooltipsEnabled = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
      await prefs.setBool('${_prefix}enabled', true);
    } catch (e) {
      ChronosLogger.error('Erro ao resetar tooltips: $e', tag: _tag);
    }
    notifyListeners();
  }
}
