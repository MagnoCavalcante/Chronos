import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_cache_service.dart';
import 'gamification_models.dart';

/// Repositório de conquistas e badges.
class AchievementsRepository {
  final SupabaseClient? _providedClient;
  final GamificationCacheService _cache = GamificationCacheService();

  AchievementsRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  /// Retorna catálogo completo de conquistas.
  Future<List<Achievement>> getAchievementsCatalog() async {
    final client = _client;
    if (client == null) {
      final cached = await _cache.getAchievements();
      return cached.map((e) => e.achievement).toList();
    }
    try {
      final response = await client.from('achievements').select().order('name', ascending: true);
      return response.map((e) => Achievement.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar catálogo de conquistas', error: e);
      final cached = await _cache.getAchievements();
      return cached.map((e) => e.achievement).toList();
    }
  }

  /// Retorna conquistas do usuário com progresso.
  Future<List<UserAchievement>> getUserAchievements() async {
    final client = _client;
    if (client == null) return _cache.getAchievements();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getAchievements();
      final response = await client.from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', userId)
          .order('unlocked_at', ascending: true);
      final list = response.map((e) => UserAchievement.fromJson(e)).toList();
      await _cache.cacheAchievements(list);
      return list;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar conquistas do usuário', error: e);
      return _cache.getAchievements();
    }
  }

  /// Atualiza progresso de uma conquista. Desbloqueia se atingir o critério.
  Future<List<UserAchievement>> updateProgress(String achievementId, int progress) async {
    final client = _client;
    if (client == null) return _cache.getAchievements();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getAchievements();

      final existing = await client.from('user_achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .limit(1);

      final achievement = await _getAchievement(client, achievementId);
      if (achievement == null) return _cache.getAchievements();

      final unlocked = progress >= achievement.criteriaValue;
      final payload = {
        'user_id': userId,
        'achievement_id': achievementId,
        'progress': progress.clamp(0, achievement.criteriaValue),
        'unlocked_at': unlocked ? DateTime.now().toIso8601String() : null,
      };

      if (existing.isEmpty) {
        await client.from('user_achievements').insert(payload);
      } else {
        await client.from('user_achievements')
            .update(payload)
            .eq('user_id', userId)
            .eq('achievement_id', achievementId);
      }

      return getUserAchievements();
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar progresso da conquista', error: e);
      return _cache.getAchievements();
    }
  }

  Future<Achievement?> _getAchievement(SupabaseClient client, String id) async {
    try {
      final response = await client.from('achievements').select().eq('id', id).limit(1);
      if (response.isEmpty) return null;
      return Achievement.fromJson(response.first);
    } catch (_) {
      return null;
    }
  }
}
