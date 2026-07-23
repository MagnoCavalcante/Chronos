import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_models.dart';

/// Repositório para tags pessoais.
class TagsRepository {
  final SupabaseClient? _providedClient;
  TagsRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try { return SupabaseConfig.client; } catch (_) { return null; }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<List<Tag>> getTags() async {
    final client = _client;
    if (client == null || _userId == null) return [];
    try {
      final response = await client.from('tags').select().eq('user_id', _userId!).order('name');
      return response.map((e) => Tag.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar tags', error: e);
      return [];
    }
  }

  Future<Tag?> createTag(String name, {String color = '#888888'}) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final response = await client.from('tags').insert({
        'user_id': _userId!,
        'name': name,
        'color': color,
      }).select().single();
      return Tag.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao criar tag', error: e);
      return null;
    }
  }

  Future<bool> deleteTag(String id) async {
    final client = _client;
    if (client == null || _userId == null) return false;
    try {
      await client.from('tags').delete().eq('id', id);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao excluir tag', error: e);
      return false;
    }
  }

  Future<bool> assignTagToCollection(String collectionId, String tagId) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('collection_tags').insert({'collection_id': collectionId, 'tag_id': tagId});
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao vincular tag', error: e);
      return false;
    }
  }

  Future<List<String>> getTagsForCollection(String collectionId) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client.from('collection_tags').select('tag_id').eq('collection_id', collectionId);
      return response.map((e) => e['tag_id'] as String).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar tags da coleção', error: e);
      return [];
    }
  }
}
