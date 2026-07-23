import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_cache_service.dart';
import 'gamification_models.dart';
import 'level_calculator.dart';

/// Repositório para perfil gamificado do usuário.
class ProfileRepository {
  final SupabaseClient? _providedClient;
  final GamificationCacheService _cache = GamificationCacheService();

  ProfileRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get client => _client;

  String? get _userId => _client?.auth.currentUser?.id;

  Future<UserProfile?> getProfile() async {
    final client = _client;
    if (client == null) return _cache.getProfile();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getProfile();
      final response = await client.from('user_profiles')
          .select()
          .eq('user_id', userId)
          .limit(1);
      if (response.isEmpty) {
        return await _createDefaultProfile(client, userId);
      }
      final profile = UserProfile.fromJson(response.first);
      await _cache.cacheProfile(profile);
      return profile;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar perfil', error: e);
      return _cache.getProfile();
    }
  }

  Future<UserProfile> _createDefaultProfile(SupabaseClient client, String userId) async {
    final user = client.auth.currentUser;
    final displayName = user?.userMetadata?['display_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.email?.split('@').firstOrNull ??
        'Historiador';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    final profile = UserProfile(
      id: '',
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: null,
      titleId: null,
      totalXp: 0,
      currentLevel: 1,
      streakDays: 0,
      lastStudyDate: null,
      joinedAt: DateTime.tryParse(user?.createdAt ?? '') ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final response = await client.from('user_profiles')
          .insert(profile.toJson()..remove('id'))
          .select()
          .single();
      final created = UserProfile.fromJson(response);
      await _cache.cacheProfile(created);
      return created;
    } catch (e) {
      ChronosLogger.error('Erro ao criar perfil padrão', error: e);
      return profile;
    }
  }

  Future<UserProfile?> updateProfile(UserProfile profile) async {
    final client = _client;
    if (client == null) {
      await _cache.cacheProfile(profile);
      return profile;
    }
    try {
      final userId = _userId;
      if (userId == null) return null;
      final payload = profile.toJson()..remove('id');
      payload.remove('user_id');
      payload.remove('joined_at');
      final response = await client.from('user_profiles')
          .update(payload)
          .eq('user_id', userId)
          .select()
          .single();
      final updated = UserProfile.fromJson(response);
      await _cache.cacheProfile(updated);
      return updated;
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar perfil', error: e);
      await _cache.cacheProfile(profile);
      return profile;
    }
  }

  Future<UserProfile?> updateXpAndLevel(int totalXp, int level, String? titleId) async {
    final client = _client;
    if (client == null) {
      final cached = await _cache.getProfile();
      if (cached != null) {
        final updated = UserProfile(
          id: cached.id,
          userId: cached.userId,
          displayName: cached.displayName,
          avatarUrl: cached.avatarUrl,
          bio: cached.bio,
          titleId: titleId ?? cached.titleId,
          totalXp: totalXp,
          currentLevel: level,
          streakDays: cached.streakDays,
          lastStudyDate: cached.lastStudyDate,
          joinedAt: cached.joinedAt,
          updatedAt: DateTime.now(),
        );
        await _cache.cacheProfile(updated);
        return updated;
      }
      return null;
    }
    try {
      final userId = _userId;
      if (userId == null) return null;
      final response = await client.from('user_profiles')
          .update({
            'total_xp': totalXp,
            'current_level': level,
            'title_id': titleId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select()
          .single();
      final updated = UserProfile.fromJson(response);
      await _cache.cacheProfile(updated);
      return updated;
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar XP/level', error: e);
      return _cache.getProfile();
    }
  }

  /// Calcula nível e título atualizados com base no XP total.
  Future<UserProfile?> recalculate({List<Title>? titles}) async {
    final profile = await getProfile();
    if (profile == null) return null;
    final level = LevelCalculator.levelFromXp(profile.totalXp);
    final title = titles == null
        ? null
        : LevelCalculator.titleForProgress(titles, level, profile.totalXp);
    return updateXpAndLevel(profile.totalXp, level, title?.slug);
  }
}
