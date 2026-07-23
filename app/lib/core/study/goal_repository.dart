import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_models.dart';

/// Repositório para metas de estudo.
class GoalRepository {
  final SupabaseClient? _providedClient;
  GoalRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try { return SupabaseConfig.client; } catch (_) { return null; }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<List<StudyGoal>> getGoals() async {
    final client = _client;
    if (client == null || _userId == null) return [];
    try {
      final response = await client.from('study_goals').select().eq('user_id', _userId!).order('created_at', ascending: false);
      return response.map((e) => StudyGoal.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar metas', error: e);
      return [];
    }
  }

  Future<StudyGoal?> createGoal({
    required String title,
    required String targetType,
    required int targetValue,
    DateTime? deadline,
  }) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final response = await client.from('study_goals').insert({
        'user_id': _userId!,
        'title': title,
        'target_type': targetType,
        'target_value': targetValue,
        'deadline': deadline?.toIso8601String(),
      }).select().single();
      return StudyGoal.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao criar meta', error: e);
      return null;
    }
  }

  Future<StudyGoal?> updateGoalProgress(String goalId, int delta) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final current = await client.from('study_goals').select().eq('id', goalId).single();
      final goal = StudyGoal.fromJson(current);
      final newValue = goal.currentValue + delta;
      final completed = newValue >= goal.targetValue;
      final response = await client.from('study_goals').update({
        'current_value': newValue,
        'completed': completed,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', goalId).select().single();
      return StudyGoal.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar meta', error: e);
      return null;
    }
  }

  Future<bool> deleteGoal(String id) async {
    final client = _client;
    if (client == null || _userId == null) return false;
    try {
      await client.from('study_goals').delete().eq('id', id);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao excluir meta', error: e);
      return false;
    }
  }
}
