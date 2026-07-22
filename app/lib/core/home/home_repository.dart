import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../crud/crud_repository.dart';
import '../utils/logger.dart';
import 'home_item.dart';

class _CategoryConfig {
  final String tableName;
  final String label;
  final String titleKey;
  final String? imageKey;
  final String? yearKey;

  const _CategoryConfig({
    required this.tableName,
    required this.label,
    required this.titleKey,
    this.imageKey,
    this.yearKey,
  });
}

/// Repositório que alimenta a Home, Favoritos e Histórico do CHRONOS.
class HomeRepository {
  final SupabaseClient? _providedClient;
  static const String _tag = 'HomeRepository';

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient;

  SupabaseClient? get _safeSupabaseClient {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  static const List<_CategoryConfig> _categories = [
    _CategoryConfig(
      tableName: 'civilizations',
      label: 'Civilização',
      titleKey: 'name',
      imageKey: 'cover_image_url',
      yearKey: 'start_year',
    ),
    _CategoryConfig(
      tableName: 'historical_characters',
      label: 'Personagem',
      titleKey: 'nome',
      imageKey: 'imagem_principal',
      yearKey: 'data_nascimento',
    ),
    _CategoryConfig(
      tableName: 'historical_events',
      label: 'Evento',
      titleKey: 'titulo',
      yearKey: 'start_year',
    ),
    _CategoryConfig(
      tableName: 'artifacts',
      label: 'Artefato',
      titleKey: 'name',
      imageKey: 'cover_image_url',
      yearKey: 'estimated_year',
    ),
    _CategoryConfig(
      tableName: 'historical_locations',
      label: 'Localização',
      titleKey: 'name',
      imageKey: 'cover_image_url',
      yearKey: 'start_year',
    ),
    _CategoryConfig(
      tableName: 'historical_sources',
      label: 'Fonte',
      titleKey: 'titulo',
    ),
  ];

  HomeRepository({SupabaseClient? client}) : _providedClient = client;

  /// Retorna os últimos registros visualizados (Continue Explorando).
  Future<List<HomeItem>> getContinueExploring({int limit = 10}) async {
    try {
      final response = await _client!
          .from('navigation_history')
          .select()
          .order('accessed_at', ascending: false)
          .limit(limit);
      return response.map(HomeItem.fromJson).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar histórico: $e', tag: _tag, error: e);
      return [];
    }
  }

  /// Retorna todos os favoritos salvos.
  Future<List<HomeItem>> getFavorites() async {
    try {
      final response = await _client!
          .from('user_favorites')
          .select()
          .order('created_at', ascending: false);
      return response.map(HomeItem.fromJson).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar favoritos: $e', tag: _tag, error: e);
      return [];
    }
  }

  /// Retorna destaques da semana: registros mais recentes de todas as categorias.
  Future<List<HomeItem>> getHighlights({int limit = 10}) async {
    final all = <HomeItem>[];
    for (final category in _categories) {
      final items = await _fetchCategory(category, limit: 5);
      all.addAll(items);
    }
    all.sort((a, b) {
      final aDate = a.accessedAt ?? a.favoritedAt;
      final bDate = b.accessedAt ?? b.favoritedAt;
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });
    return all.take(limit).toList();
  }

  /// Retorna os registros mais recentes de uma categoria específica.
  Future<List<HomeItem>> getRecentByCategory(String tableName, {int limit = 10}) async {
    final config = _categories.firstWhere((c) => c.tableName == tableName);
    return _fetchCategory(config, limit: limit);
  }

  /// Retorna um registro aleatório para o botão "Surpreenda-me".
  Future<HomeItem?> getSurpriseMe() async {
    final config = _categories[Random().nextInt(_categories.length)];
    final items = await _fetchCategory(config, limit: 100);
    if (items.isEmpty) return null;
    return items[Random().nextInt(items.length)];
  }

  /// Registra um acesso para o histórico e incrementa popularidade.
  Future<void> logAccess(HomeItem item) async {
    try {
      await _client!.from('navigation_history').insert(item.toJson()..['accessed_at'] = DateTime.now().toIso8601String());
      await _incrementPopularity(item, views: 1);
    } catch (e) {
      ChronosLogger.error('Erro ao registrar acesso: $e', tag: _tag, error: e);
    }
  }

  /// Alterna o estado de favorito de um item.
  /// Retorna `true` se o item passou a ser favorito.
  Future<bool> toggleFavorite(HomeItem item) async {
    final isFav = await isFavorite(item);
    try {
      if (isFav) {
        await _client!
            .from('user_favorites')
            .delete()
            .eq('entity_type', item.entityType)
            .eq('entity_id', item.entityId);
        await _incrementPopularity(item, favorites: -1);
        return false;
      } else {
        await _client!.from('user_favorites').insert(item.toJson()..['created_at'] = DateTime.now().toIso8601String());
        await _incrementPopularity(item, favorites: 1);
        return true;
      }
    } catch (e) {
      ChronosLogger.error('Erro ao alternar favorito: $e', tag: _tag, error: e);
      return isFav;
    }
  }

  /// Verifica se um item já está favoritado.
  Future<bool> isFavorite(HomeItem item) async {
    try {
      final response = await _client!
          .from('user_favorites')
          .select()
          .eq('entity_type', item.entityType)
          .eq('entity_id', item.entityId)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      ChronosLogger.error('Erro ao verificar favorito: $e', tag: _tag, error: e);
      return false;
    }
  }

  Future<List<HomeItem>> _fetchCategory(_CategoryConfig config, {required int limit}) async {
    final repo = CrudRepository(tableName: config.tableName, orderBy: 'created_at');
    final result = await repo.getRecent(limit);
    return result.fold(
      onSuccess: (rows) => rows.map((row) => _mapRow(row, config)).toList(),
      onFailure: (_) => [],
    );
  }

  HomeItem _mapRow(Map<String, dynamic> row, _CategoryConfig config) {
    final id = row['id'] as String? ?? '';
    final title = row[config.titleKey]?.toString() ?? 'Sem título';
    final imageUrl = config.imageKey != null ? row[config.imageKey!]?.toString() : null;
    return HomeItem(
      entityType: config.tableName,
      entityId: id,
      title: title,
      imageUrl: imageUrl,
      category: config.label,
      chronology: _extractChronology(row, config.yearKey),
    );
  }

  String? _extractChronology(Map<String, dynamic> row, String? yearKey) {
    if (yearKey == null) return null;
    final value = row[yearKey];
    if (value == null) return null;
    if (value is int) return _formatYear(value);
    if (value is double) return _formatYear(value.toInt());
    if (value is String) {
      if (value.contains('-')) {
        final date = DateTime.tryParse(value);
        if (date != null) return _formatYear(date.year);
      }
      final parsed = int.tryParse(value);
      if (parsed != null) return _formatYear(parsed);
    }
    return null;
  }

  String _formatYear(int year) {
    return year < 0 ? '${year.abs()} a.C.' : '$year d.C.';
  }

  Future<void> _incrementPopularity(HomeItem item, {int views = 0, int favorites = 0}) async {
    try {
      await _client!.rpc('upsert_popularity', params: {
        'p_entity_type': item.entityType,
        'p_entity_id': item.entityId,
        'p_views': views,
        'p_favorites': favorites,
      });
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar popularidade: $e', tag: _tag, error: e);
    }
  }
}
