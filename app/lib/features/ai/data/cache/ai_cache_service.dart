import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache local para perguntas, respostas e histórico do Chronos AI.
///
/// Funciona com [SharedPreferences] quando disponível e usa fallback em
/// memória em ambientes de teste sem binding inicializado.
class AiCacheService {
  static const _historyKey = 'ai_conversation_history';
  static const _favoritesKey = 'ai_conversation_favorites';
  static const _pinnedKey = 'ai_conversation_pinned';
  static const _responseCacheKey = 'ai_response_cache';
  static const _suggestionsKey = 'ai_suggestions_cache';

  final Map<String, String> _memory = {};

  Future<SharedPreferences?> get _prefs async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getString(String key) async {
    final prefs = await _prefs;
    if (prefs != null) return prefs.getString(key);
    return _memory[key];
  }

  Future<void> _setString(String key, String value) async {
    final prefs = await _prefs;
    if (prefs != null) {
      await prefs.setString(key, value);
    } else {
      _memory[key] = value;
    }
  }

  Future<void> _remove(String key) async {
    final prefs = await _prefs;
    if (prefs != null) {
      await prefs.remove(key);
    } else {
      _memory.remove(key);
    }
  }

  Future<void> cacheHistory(String key, List<Map<String, dynamic>> items) async {
    await _setString(key, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getHistory(String key) async {
    final raw = await _getString(key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> cacheResponse(String cacheKey, Map<String, dynamic> response) async {
    await _setString('$_responseCacheKey/$cacheKey', jsonEncode(response));
  }

  Future<Map<String, dynamic>?> getResponse(String cacheKey) async {
    final raw = await _getString('$_responseCacheKey/$cacheKey');
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearCache() async {
    await _remove(_historyKey);
    await _remove(_favoritesKey);
    await _remove(_pinnedKey);
    await _remove(_suggestionsKey);
    final keys = _memory.keys.where((k) => k.startsWith('$_responseCacheKey/')).toList();
    for (final key in keys) {
      await _remove(key);
    }
  }
}
