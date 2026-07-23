import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_models.dart';

/// Repositório que gera resumos semanais de estudo.
class WeeklySummaryRepository {
  final SupabaseClient? _providedClient;

  WeeklySummaryRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<WeeklySummary?> getCurrentWeekSummary() async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = _userId;
      if (userId == null) return null;
      final now = DateTime.now();
      final start = now.subtract(Duration(days: now.weekday % 7));
      final end = start.add(const Duration(days: 6));
      final response = await client.from('weekly_summaries')
          .select()
          .eq('user_id', userId)
          .eq('week_start', _dateToIso(start))
          .limit(1);
      if (response.isEmpty) return await generateSummary();
      return WeeklySummary.fromJson(response.first);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar resumo semanal', error: e);
      return null;
    }
  }

  Future<WeeklySummary?> generateSummary() async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = _userId;
      if (userId == null) return null;
      final now = DateTime.now();
      final start = now.subtract(Duration(days: now.weekday % 7));
      final end = start.add(const Duration(days: 6));

      final xpResponse = await client.from('xp_events')
          .select('amount')
          .eq('user_id', userId)
          .gte('created_at', start.toUtc().toIso8601String());
      final totalXp = (xpResponse as List<dynamic>).fold<int>(0, (s, e) => s + ((e as Map<String, dynamic>)['amount'] as int? ?? 0));

      final statsResponse = await client.from('user_stats')
          .select('total_study_time_seconds')
          .eq('user_id', userId)
          .limit(1);
      final totalSeconds = statsResponse.isEmpty
          ? 0
          : statsResponse.first['total_study_time_seconds'] as int? ?? 0;
      final hoursStudied = totalSeconds ~/ 3600;

      final achievementsResponse = await client.from('user_achievements')
          .select('achievement_id')
          .eq('user_id', userId)
          .not('unlocked_at', 'is', null);
      final achievementsCount = achievementsResponse.length;

      final collectionsResponse = await client.from('collections')
          .select('id,ativo')
          .eq('user_id', userId)
          .gte('created_at', start.toUtc().toIso8601String());
      final collectionsStarted = collectionsResponse.length;

      final completedCollectionsResponse = await client.from('collections')
          .select('id')
          .eq('user_id', userId);
      final collectionsCompleted = completedCollectionsResponse.where((c) => c['ativo'] == false).length;

      final progressResponse = await client.from('study_progress')
          .select('entity_type')
          .eq('user_id', userId)
          .gte('updated_at', start.toUtc().toIso8601String());
      final categoryCounts = <String, int>{};
      for (final row in progressResponse as List<dynamic>) {
        final type = (row as Map<String, dynamic>)['entity_type'] as String? ?? 'outro';
        categoryCounts[type] = (categoryCounts[type] ?? 0) + 1;
      }
      final topCategories = (categoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .map((e) => e.key)
          .take(3)
          .toList();

      final payload = {
        'user_id': userId,
        'week_start': _dateToIso(start),
        'week_end': _dateToIso(end),
        'total_xp': totalXp,
        'hours_studied': hoursStudied,
        'achievements_count': achievementsCount,
        'collections_started': collectionsStarted,
        'collections_completed': collectionsCompleted,
        'top_categories': topCategories,
      };

      final response = await client.from('weekly_summaries')
          .upsert(payload, onConflict: 'user_id,week_start')
          .select()
          .single();
      return WeeklySummary.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao gerar resumo semanal', error: e);
      return null;
    }
  }

  String _dateToIso(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
