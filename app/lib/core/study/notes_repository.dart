import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_models.dart';

/// Repositório para notas pessoais e marcações.
class NotesRepository {
  final SupabaseClient? _providedClient;
  NotesRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try { return SupabaseConfig.client; } catch (_) { return null; }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<Note?> getNote(String entityType, String entityId) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final response = await client.from('notes')
          .select()
          .eq('user_id', _userId!)
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .maybeSingle();
      if (response == null) return null;
      return Note.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar nota', error: e);
      return null;
    }
  }

  Future<Note?> saveNote(String entityType, String entityId, {String? content, String? summary}) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final existing = await getNote(entityType, entityId);
      final payload = {
        'user_id': _userId!,
        'entity_type': entityType,
        'entity_id': entityId,
        'content': content,
        'summary': summary,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (existing == null) {
        final response = await client.from('notes').insert(payload).select().single();
        return Note.fromJson(response);
      } else {
        final response = await client.from('notes').update(payload).eq('id', existing.id).select().single();
        return Note.fromJson(response);
      }
    } catch (e) {
      ChronosLogger.error('Erro ao salvar nota', error: e);
      return null;
    }
  }

  Future<List<Highlight>> getHighlights(String entityType, String entityId) async {
    final client = _client;
    if (client == null || _userId == null) return [];
    try {
      final response = await client.from('highlights')
          .select()
          .eq('user_id', _userId!)
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .order('created_at', ascending: false);
      return response.map((e) => Highlight.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar marcações', error: e);
      return [];
    }
  }

  Future<Highlight?> addHighlight({
    required String entityType,
    required String entityId,
    required String selectedText,
    String? note,
    String color = '#FFD700',
  }) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final response = await client.from('highlights').insert({
        'user_id': _userId!,
        'entity_type': entityType,
        'entity_id': entityId,
        'selected_text': selectedText,
        'note': note,
        'color': color,
      }).select().single();
      return Highlight.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao adicionar marcação', error: e);
      return null;
    }
  }

  Future<bool> deleteHighlight(String id) async {
    final client = _client;
    if (client == null || _userId == null) return false;
    try {
      await client.from('highlights').delete().eq('id', id);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao excluir marcação', error: e);
      return false;
    }
  }
}
