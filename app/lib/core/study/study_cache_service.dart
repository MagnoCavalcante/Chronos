import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_models.dart';

/// Cache local offline para coleções, progresso e notas de estudo.
class StudyCacheService {
  static const _collectionsKey = 'cached_collections';
  static const _progressKey = 'cached_progress';
  static const _notesKey = 'cached_notes';
  static const _lastSyncKey = 'study_last_sync';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> cacheCollections(List<Collection> collections) async {
    final prefs = await _prefs;
    await prefs.setString(_collectionsKey, jsonEncode(collections.map((c) => c.toJson()).toList()));
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<List<Collection>> getCollections() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_collectionsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cacheProgress(List<StudyProgress> progress) async {
    final prefs = await _prefs;
    await prefs.setString(_progressKey, jsonEncode(progress.map((p) => p.toJson()).toList()));
  }

  Future<List<StudyProgress>> getProgress() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => StudyProgress.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cacheNotes(List<Note> notes) async {
    final prefs = await _prefs;
    await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
  }

  Future<List<Note>> getNotes() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DateTime?> getLastSync() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_collectionsKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_notesKey);
    await prefs.remove(_lastSyncKey);
  }
}
