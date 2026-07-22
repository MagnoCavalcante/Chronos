import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'relationship_item.dart';

/// Repositório para descoberta de relacionamentos históricos via RPC do Supabase.
class RelationshipRepository {
  final SupabaseClient? _providedClient;

  RelationshipRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (e) {
      ChronosLogger.warn('Supabase não inicializado no RelationshipRepository', tag: 'RelationshipRepository');
      return null;
    }
  }

  /// Retorna itens relacionados a uma entidade usando a RPC `get_relationships`.
  Future<List<RelatedItem>> getRelated({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    final client = _client;
    if (client == null) {
      return [];
    }

    try {
      final response = await client.rpc(
        'get_relationships',
        params: {
          'p_entity_type': entityType,
          'p_entity_id': entityId,
          'p_limit': limit,
        },
      );

      final data = response as List<dynamic>? ?? [];
      return data
          .map((json) => RelatedItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ChronosLogger.error('Erro ao buscar relacionamentos', tag: 'RelationshipRepository', error: e);
      return [];
    }
  }
}
