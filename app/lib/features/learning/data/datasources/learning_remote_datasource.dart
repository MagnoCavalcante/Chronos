import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';

/// DataSource remoto da Learning Engine via Supabase.
abstract class LearningRemoteDataSource {
  Future<void> insertRecord(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchHistory(String userId, {int limit});
  Future<Map<String, dynamic>?> fetchProgress(String userId, String entityId);
  Future<List<Map<String, dynamic>>> fetchAllProgress(String userId, {int limit});
  Future<void> upsertProgress(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchPendingReviews(String userId);
  Future<void> insertReview(Map<String, dynamic> data);
  Future<void> completeReview(String reviewId);
  Future<List<Map<String, dynamic>>> fetchQuizQuestions(String entityId, {int limit});
  Future<void> insertQuizAnswer(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchQuizHistory(String userId, {String? entityId});
  Future<List<Map<String, dynamic>>> fetchGoals(String userId);
  Future<void> insertGoal(Map<String, dynamic> data);
  Future<void> updateGoal(String goalId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchAchievements(String userId);
  Future<void> upsertAchievement(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> fetchStats(String userId);
  Future<void> upsertStats(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchActiveChallenges(String userId);
  Future<void> insertChallenge(Map<String, dynamic> data);
  Future<void> updateChallenge(String challengeId, Map<String, dynamic> data);
}

/// Implementação concreta usando Supabase.
class LearningRemoteDataSourceImpl implements LearningRemoteDataSource {
  static const String _tag = 'LearningDataSource';

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insertRecord(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_history').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao inserir record: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String userId, {int limit = 50}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('study_history')
          .select()
          .eq('user_id', userId)
          .order('started_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar histórico: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchProgress(String userId, String entityId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('study_progress')
          .select()
          .eq('user_id', userId)
          .eq('entity_id', entityId)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar progresso: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllProgress(String userId, {int limit = 50}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('study_progress')
          .select()
          .eq('user_id', userId)
          .order('last_access', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar todo progresso: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> upsertProgress(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_progress').upsert(data, onConflict: 'user_id,entity_id');
    } catch (e) {
      ChronosLogger.error('Erro ao upsert progresso: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPendingReviews(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('study_reviews')
          .select()
          .eq('user_id', userId)
          .eq('completed', false)
          .lte('scheduled_for', DateTime.now().toIso8601String())
          .order('scheduled_for');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar revisões: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> insertReview(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_reviews').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao inserir revisão: $e', tag: _tag);
    }
  }

  @override
  Future<void> completeReview(String reviewId) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_reviews').update({
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
    } catch (e) {
      ChronosLogger.error('Erro ao completar revisão: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchQuizQuestions(String entityId, {int limit = 5}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('quiz_questions')
          .select()
          .eq('entity_id', entityId)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar quiz: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> insertQuizAnswer(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('quiz_answers').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao inserir resposta quiz: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchQuizHistory(String userId, {String? entityId}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('quiz_answers').select().eq('user_id', userId);
      if (entityId != null) {
        query = query.eq('entity_id', entityId);
      }
      final response = await query.order('answered_at', ascending: false).limit(100);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar quiz history: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchGoals(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('study_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar metas: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> insertGoal(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_goals').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao criar meta: $e', tag: _tag);
    }
  }

  @override
  Future<void> updateGoal(String goalId, Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_goals').update(data).eq('id', goalId);
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar meta: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAchievements(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .order('unlocked', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar conquistas: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> upsertAchievement(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('achievements').upsert(data, onConflict: 'user_id,code');
    } catch (e) {
      ChronosLogger.error('Erro ao upsert conquista: $e', tag: _tag);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchStats(String userId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('user_study_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar stats: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<void> upsertStats(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('user_study_stats').upsert(data, onConflict: 'user_id');
    } catch (e) {
      ChronosLogger.error('Erro ao upsert stats: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchActiveChallenges(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('study_challenges')
          .select()
          .eq('user_id', userId)
          .eq('completed', false)
          .gte('end_date', DateTime.now().toIso8601String())
          .order('end_date');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar desafios: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> insertChallenge(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_challenges').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao criar desafio: $e', tag: _tag);
    }
  }

  @override
  Future<void> updateChallenge(String challengeId, Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_challenges').update(data).eq('id', challengeId);
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar desafio: $e', tag: _tag);
    }
  }
}
