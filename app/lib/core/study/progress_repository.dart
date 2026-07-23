import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_cache_service.dart';
import 'study_models.dart';

/// Repositório para progresso de estudo.
class ProgressRepository {
  final SupabaseClient? _providedClient;
  final StudyCacheService _cache = StudyCacheService();

  ProgressRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  Future<StudyProgress?> getProgress(String entityType, String entityId) async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;
      final response = await client.from('study_progress')
          .select()
          .eq('user_id', userId)
          .eq('entity_type', entityType)
          .eq('entity_id', entityId)
          .maybeSingle();
      if (response == null) return null;
      return StudyProgress.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar progresso', error: e);
      return null;
    }
  }

  Future<List<StudyProgress>> getInProgressItems() async {
    final client = _client;
    if (client == null) return _cache.getProgress();
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return _cache.getProgress();
      final response = await client.from('study_progress')
          .select()
          .eq('user_id', userId)
          .neq('status', 'completed')
          .order('updated_at', ascending: false);
      final list = response.map((e) => StudyProgress.fromJson(e)).toList();
      await _cache.cacheProgress(list);
      return list;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar itens em estudo', error: e);
      return _cache.getProgress();
    }
  }

  Future<StudyProgress?> updateProgress({
    required String entityType,
    required String entityId,
    required StudyStatus status,
    required int progressPercent,
    int? addedSeconds,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;
      final existing = await getProgress(entityType, entityId);
      final now = DateTime.now().toIso8601String();
      final payload = {
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'status': status.apiValue,
        'progress_percent': progressPercent,
        'updated_at': now,
      };
      if (existing == null) {
        if (status != StudyStatus.notStarted) payload['started_at'] = now;
        if (status == StudyStatus.completed) payload['completed_at'] = now;
        if (addedSeconds != null) payload['total_study_time_seconds'] = addedSeconds;
        final response = await client.from('study_progress').insert(payload).select().single();
        return StudyProgress.fromJson(response);
      } else {
        if (status != StudyStatus.notStarted && existing.startedAt == null) payload['started_at'] = now;
        if (status == StudyStatus.completed) payload['completed_at'] = now;
        if (addedSeconds != null) {
          payload['total_study_time_seconds'] = existing.totalStudyTimeSeconds + addedSeconds;
        }
        final response = await client.from('study_progress').update(payload).eq('id', existing.id).select().single();
        return StudyProgress.fromJson(response);
      }
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar progresso', error: e);
      return null;
    }
  }

  Future<StudyProgress?> getContinueStudying() async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;
      final response = await client.from('study_progress')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return StudyProgress.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar continue estudando', error: e);
      return null;
    }
  }
}
