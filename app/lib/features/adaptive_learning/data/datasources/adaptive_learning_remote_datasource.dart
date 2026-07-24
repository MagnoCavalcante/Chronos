import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';

/// DataSource remoto de Adaptive Learning via Supabase.
abstract class AdaptiveLearningRemoteDataSource {
  Future<Map<String, dynamic>?> fetchProfile(String userId);
  Future<void> upsertProfile(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchProfileHistory(String userId);
  Future<List<Map<String, dynamic>>> fetchRecommendations(String userId, {int limit = 10});
  Future<void> insertRecommendations(List<Map<String, dynamic>> data);
  Future<void> dismissRecommendation(String id);
  Future<void> clearRecommendations(String userId);
  Future<Map<String, dynamic>?> fetchCurrentPlan(String userId);
  Future<void> upsertPlan(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchPlanHistory(String userId, {int limit = 10});
  Future<Map<String, dynamic>?> fetchLatestReport(String userId, String period);
  Future<void> insertReport(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchReports(String userId, {int limit = 10});
  Future<Map<String, dynamic>> exportAllData(String userId);
  Future<void> deleteAllData(String userId);
}

class AdaptiveLearningRemoteDataSourceImpl implements AdaptiveLearningRemoteDataSource {
  static const String _tag = 'AdaptiveLearningDS';

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('learner_profiles')
          .select()
          .eq('user_id', userId)
          .order('version', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar perfil: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<void> upsertProfile(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('learner_profiles').upsert(data, onConflict: 'user_id,version');
    } catch (e) {
      ChronosLogger.error('Erro ao salvar perfil: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProfileHistory(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('learner_profiles')
          .select()
          .eq('user_id', userId)
          .order('version', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar histórico perfil: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecommendations(String userId, {int limit = 10}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('adaptive_recommendations')
          .select()
          .eq('user_id', userId)
          .eq('dismissed', false)
          .order('priority', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar recomendações: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> insertRecommendations(List<Map<String, dynamic>> data) async {
    try {
      final client = _client;
      if (client == null) return;
      if (data.isEmpty) return;
      await client.from('adaptive_recommendations').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao inserir recomendações: $e', tag: _tag);
    }
  }

  @override
  Future<void> dismissRecommendation(String id) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('adaptive_recommendations').update({'dismissed': true}).eq('id', id);
    } catch (e) {
      ChronosLogger.error('Erro ao descartar recomendação: $e', tag: _tag);
    }
  }

  @override
  Future<void> clearRecommendations(String userId) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('adaptive_recommendations').delete().eq('user_id', userId);
    } catch (e) {
      ChronosLogger.error('Erro ao limpar recomendações: $e', tag: _tag);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchCurrentPlan(String userId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('study_plans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar plano: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<void> upsertPlan(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('study_plans').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar plano: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPlanHistory(String userId, {int limit = 10}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('study_plans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar planos: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchLatestReport(String userId, String period) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('learning_reports')
          .select()
          .eq('user_id', userId)
          .eq('period', period)
          .order('generated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar relatório: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<void> insertReport(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('learning_reports').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar relatório: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReports(String userId, {int limit = 10}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('learning_reports')
          .select()
          .eq('user_id', userId)
          .order('generated_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar relatórios: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> exportAllData(String userId) async {
    try {
      final client = _client;
      if (client == null) return {};
      final profiles = await fetchProfileHistory(userId);
      final recs = await fetchRecommendations(userId, limit: 1000);
      final plans = await fetchPlanHistory(userId, limit: 100);
      final reports = await fetchReports(userId, limit: 100);
      return {
        'profiles': profiles,
        'recommendations': recs,
        'study_plans': plans,
        'reports': reports,
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      ChronosLogger.error('Erro ao exportar dados: $e', tag: _tag);
      return {};
    }
  }

  @override
  Future<void> deleteAllData(String userId) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('adaptive_recommendations').delete().eq('user_id', userId);
      await client.from('learning_reports').delete().eq('user_id', userId);
      await client.from('study_plans').delete().eq('user_id', userId);
      await client.from('learner_profiles').delete().eq('user_id', userId);
    } catch (e) {
      ChronosLogger.error('Erro ao excluir dados: $e', tag: _tag);
    }
  }
}
