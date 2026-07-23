import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_models.dart';

/// Repositório para estatísticas e sessões de estudo.
class StatsRepository {
  final SupabaseClient? _providedClient;
  StatsRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try { return SupabaseConfig.client; } catch (_) { return null; }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<UserStats?> getStats() async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final response = await client.from('user_stats').select().eq('user_id', _userId!).maybeSingle();
      if (response == null) return null;
      return UserStats.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar estatísticas', error: e);
      return null;
    }
  }

  Future<bool> recordSession({
    required int durationSeconds,
    String? entityType,
    String? entityId,
  }) async {
    final client = _client;
    if (client == null || _userId == null) return false;
    try {
      final now = DateTime.now();
      await client.from('study_sessions').insert({
        'user_id': _userId!,
        'started_at': now.subtract(Duration(seconds: durationSeconds)).toIso8601String(),
        'ended_at': now.toIso8601String(),
        'duration_seconds': durationSeconds,
        'entity_type': entityType,
        'entity_id': entityId,
      });

      final current = await getStats() ?? UserStats(userId: _userId!, updatedAt: now);
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final weekly = Map<String, dynamic>.from(current.weeklyProgress);
      weekly[today] = (weekly[today] as int? ?? 0) + durationSeconds;

      await client.from('user_stats').upsert({
        'user_id': _userId!,
        'total_study_time_seconds': current.totalStudyTimeSeconds + durationSeconds,
        'items_studied': current.itemsStudied,
        'collections_completed': current.collectionsCompleted,
        'streak_days': current.streakDays,
        'last_study_date': now.toIso8601String(),
        'weekly_progress': weekly,
        'monthly_progress': current.monthlyProgress,
        'updated_at': now.toIso8601String(),
      });
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao registrar sessão', error: e);
      return false;
    }
  }
}
