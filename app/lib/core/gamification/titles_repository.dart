import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_cache_service.dart';
import 'gamification_models.dart';

/// Repositório de títulos de historiador.
class TitlesRepository {
  final SupabaseClient? _providedClient;
  final GamificationCacheService _cache = GamificationCacheService();

  TitlesRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<List<Title>> getCatalog() async {
    final client = _client;
    if (client == null) return _cache.getTitles();
    try {
      final response = await client.from('titles').select().order('min_level', ascending: true);
      final list = response.map((e) => Title.fromJson(e)).toList();
      await _cache.cacheTitles(list);
      return list;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar títulos', error: e);
      return _cache.getTitles();
    }
  }

  Future<List<Title>> getUnlockedTitles() async {
    final client = _client;
    if (client == null) return _cache.getTitles();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getTitles();
      final response = await client.from('user_titles')
          .select('*, titles(*)')
          .eq('user_id', userId)
          .order('unlocked_at', ascending: true);
      return response.map((e) {
        final titleMap = e['titles'] as Map<String, dynamic>?;
        if (titleMap == null) return Title.fromJson({});
        return Title.fromJson(titleMap);
      }).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar títulos do usuário', error: e);
      return _cache.getTitles();
    }
  }

  Future<void> unlockTitle(String titleId) async {
    final client = _client;
    if (client == null) return;
    try {
      final userId = _userId;
      if (userId == null) return;
      await client.from('user_titles').upsert({
        'user_id': userId,
        'title_id': titleId,
        'unlocked_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,title_id');
    } catch (e) {
      ChronosLogger.error('Erro ao desbloquear título', error: e);
    }
  }
}
