import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';

/// DataSource remoto de Learning Paths via Supabase.
abstract class LearningPathsRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchAllPaths({String? category, String? difficulty});
  Future<Map<String, dynamic>?> fetchPath(String pathId);
  Future<List<Map<String, dynamic>>> searchPaths(String query);
  Future<List<Map<String, dynamic>>> fetchModules(String pathId);
  Future<List<Map<String, dynamic>>> fetchModuleContents(String moduleId);
  Future<Map<String, dynamic>?> fetchPathProgress(String userId, String pathId);
  Future<List<Map<String, dynamic>>> fetchUserPaths(String userId);
  Future<void> upsertPathProgress(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> fetchModuleProgress(String userId, String moduleId);
  Future<List<Map<String, dynamic>>> fetchPathModuleProgress(String userId, String pathId);
  Future<void> upsertModuleProgress(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchCertificates(String userId);
  Future<void> insertCertificate(Map<String, dynamic> data);
}

/// Implementação concreta usando Supabase.
class LearningPathsRemoteDataSourceImpl implements LearningPathsRemoteDataSource {
  static const String _tag = 'LearningPathsDS';

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllPaths({String? category, String? difficulty}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('learning_paths').select();
      if (category != null) query = query.eq('category', category);
      if (difficulty != null) query = query.eq('difficulty', difficulty);
      final response = await query.order('order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar trilhas: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchPath(String pathId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('learning_paths')
          .select()
          .eq('id', pathId)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar trilha: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchPaths(String query) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('learning_paths')
          .select()
          .ilike('name', '%$query%')
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao pesquisar trilhas: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchModules(String pathId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('path_modules')
          .select()
          .eq('path_id', pathId)
          .order('order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar módulos: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchModuleContents(String moduleId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('path_contents')
          .select()
          .eq('module_id', moduleId)
          .order('order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar conteúdos: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchPathProgress(String userId, String pathId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('path_progress')
          .select()
          .eq('user_id', userId)
          .eq('path_id', pathId)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar progresso trilha: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserPaths(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('path_progress')
          .select()
          .eq('user_id', userId)
          .order('last_access_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar trilhas do usuário: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> upsertPathProgress(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('path_progress').upsert(data, onConflict: 'user_id,path_id');
    } catch (e) {
      ChronosLogger.error('Erro ao upsert progresso trilha: $e', tag: _tag);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchModuleProgress(String userId, String moduleId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('module_progress')
          .select()
          .eq('user_id', userId)
          .eq('module_id', moduleId)
          .maybeSingle();
      return response;
    } catch (e) {
      ChronosLogger.error('Erro ao buscar progresso módulo: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPathModuleProgress(String userId, String pathId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('module_progress')
          .select()
          .eq('user_id', userId)
          .eq('path_id', pathId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar progresso módulos: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> upsertModuleProgress(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('module_progress').upsert(data, onConflict: 'user_id,module_id');
    } catch (e) {
      ChronosLogger.error('Erro ao upsert progresso módulo: $e', tag: _tag);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCertificates(String userId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('path_certificates')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar certificados: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> insertCertificate(Map<String, dynamic> data) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('path_certificates').insert(data);
    } catch (e) {
      ChronosLogger.error('Erro ao inserir certificado: $e', tag: _tag);
    }
  }
}
