import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'timeline_item.dart';

/// Repositório responsável pelas consultas otimizadas da Timeline do CHRONOS.
class TimelineRepository {
  final SupabaseClient? _providedClient;
  static const String _tag = 'TimelineRepository';
  static const int _defaultPageSize = 50;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient;

  SupabaseClient? get _safeSupabaseClient {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  TimelineRepository({SupabaseClient? client}) : _providedClient = client;

  /// Retorna itens da Timeline com filtros, paginação e busca.
  Future<List<TimelineDisplayItem>> getTimeline({
    String? filter,
    int? startYear,
    int? endYear,
    String? search,
    int page = 0,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      final response = await _client!.rpc('get_timeline', params: {
        'p_filter': filter,
        'p_start_year': startYear,
        'p_end_year': endYear,
        'p_search': search,
        'p_limit': pageSize,
        'p_offset': page * pageSize,
      });
      return (response as List<dynamic>)
          .map((e) => TimelineDisplayItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar timeline: $e', tag: _tag, error: e);
      return [];
    }
  }

  /// Retorna itens cronologicamente relacionados ao item informado.
  Future<List<TimelineDisplayItem>> getRelatedItems({
    required String entityType,
    required String entityId,
    int radius = 100,
  }) async {
    try {
      final response = await _client!.rpc('get_related_items', params: {
        'p_entity_type': entityType,
        'p_entity_id': entityId,
        'p_radius': radius,
      });
      return (response as List<dynamic>)
          .map((e) => TimelineDisplayItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar itens relacionados: $e', tag: _tag, error: e);
      return [];
    }
  }
}
