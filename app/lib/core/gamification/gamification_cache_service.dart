import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'gamification_models.dart';

/// Cache local offline para gamificação.
///
/// Quando o binding do Flutter não está inicializado (por exemplo, em testes unitários),
/// utiliza um fallback em memória.
class GamificationCacheService {
  static const _profileKey = 'cached_gamification_profile';
  static const _achievementsKey = 'cached_gamification_achievements';
  static const _challengesKey = 'cached_gamification_challenges';
  static const _xpEventsKey = 'cached_gamification_xp_events';
  static const _titlesKey = 'cached_gamification_titles';
  static const _lastSyncKey = 'gamification_last_sync';

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

  Future<void> cacheProfile(UserProfile? profile) async {
    if (profile == null) {
      await _remove(_profileKey);
      return;
    }
    await _setString(_profileKey, jsonEncode(profile.toJson()));
    await _setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<UserProfile?> getProfile() async {
    final raw = await _getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromJson(map);
  }

  Future<void> cacheAchievements(List<UserAchievement> items) async {
    await _setString(_achievementsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<List<UserAchievement>> getAchievements() async {
    final raw = await _getString(_achievementsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => UserAchievement.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cacheChallenges(List<Challenge> challenges) async {
    await _setString(_challengesKey, jsonEncode(challenges.map((c) => c.toJson()).toList()));
  }

  Future<List<Challenge>> getChallenges() async {
    final raw = await _getString(_challengesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Challenge.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cacheXpEvents(List<XpEvent> events) async {
    await _setString(_xpEventsKey, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  Future<List<XpEvent>> getXpEvents() async {
    final raw = await _getString(_xpEventsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => XpEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cacheTitles(List<Title> titles) async {
    await _setString(_titlesKey, jsonEncode(titles.map((t) => t.toJson()).toList()));
  }

  Future<List<Title>> getTitles() async {
    final raw = await _getString(_titlesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Title.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DateTime?> getLastSync() async {
    final raw = await _getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _remove(_profileKey);
    await _remove(_achievementsKey);
    await _remove(_challengesKey);
    await _remove(_xpEventsKey);
    await _remove(_titlesKey);
    await _remove(_lastSyncKey);
  }
}
