import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/knowledge_entities.dart';

/// DataSource remoto da Base de Conhecimento via Supabase.
abstract class KnowledgeRemoteDataSource {
  Future<Map<String, dynamic>?> fetchEntry(String entityId, EntityType entityType);
  Future<List<Map<String, dynamic>>> fetchRelations(String entityId);
  Future<List<Map<String, dynamic>>> fetchReverseRelations(String entityId);
  Future<List<Map<String, dynamic>>> fetchSources(String entityId);
  Future<List<Map<String, dynamic>>> fetchDebates(String entityId);
  Future<List<Map<String, dynamic>>> fetchCuriosities(String entityId);
  Future<List<Map<String, dynamic>>> searchEntries(String query, {String? entityType});
}

/// Implementação concreta usando Supabase.
class KnowledgeRemoteDataSourceImpl implements KnowledgeRemoteDataSource {
  static const String _tag = 'KnowledgeDataSource';

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchEntry(String entityId, EntityType entityType) async {
    try {
      final client = _client;
      if (client == null) return null;

      final response = await client
          .from('knowledge_entries')
          .select()
          .eq('entity_id', entityId)
          .eq('entity_type', entityType.name)
          .maybeSingle();

      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar entry: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRelations(String entityId) async {
    try {
      final client = _client;
      if (client == null) return [];

      final response = await client
          .from('knowledge_relations')
          .select()
          .eq('source_entity_id', entityId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar relações: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReverseRelations(String entityId) async {
    try {
      final client = _client;
      if (client == null) return [];

      final response = await client
          .from('knowledge_relations')
          .select()
          .eq('target_id', entityId);

      // Converter relações inversas: trocar source/target para perspectiva do entityId
      return List<Map<String, dynamic>>.from(response).map((r) {
        return {
          ...r,
          'target_id': r['source_entity_id'],
          'target_type': r['source_type'] ?? 'character',
          'target_name': r['source_name'] ?? '',
        };
      }).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao buscar relações inversas: \$e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSources(String entityId) async {
    try {
      final client = _client;
      if (client == null) return [];

      final response = await client
          .from('knowledge_sources')
          .select()
          .eq('entity_id', entityId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar fontes: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchDebates(String entityId) async {
    try {
      final client = _client;
      if (client == null) return [];

      final response = await client
          .from('knowledge_debates')
          .select()
          .eq('entity_id', entityId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar debates: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCuriosities(String entityId) async {
    try {
      final client = _client;
      if (client == null) return [];

      final response = await client
          .from('knowledge_curiosities')
          .select()
          .eq('entity_id', entityId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar curiosidades: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchEntries(String query, {String? entityType}) async {
    try {
      final client = _client;
      if (client == null) return [];

      var request = client
          .from('knowledge_entries')
          .select()
          .ilike('nome', '%$query%');

      if (entityType != null) {
        request = request.eq('entity_type', entityType);
      }

      final response = await request.limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar entries: $e', tag: _tag);
      return [];
    }
  }
}
