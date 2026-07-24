import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/ai_teacher_entities.dart';
import '../../domain/repositories/ai_teacher_repository.dart';

class AiTeacherRepositoryImpl implements AiTeacherRepository {
  static const _tag = 'AiTeacherRepo';

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TutorSession?> getSession(String sessionId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('tutor_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();
      if (response == null) return null;
      return TutorSession.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar sessão: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<TutorSession?> getActiveSession(String userId) async {
    try {
      final client = _client;
      if (client == null) return null;
      final response = await client
          .from('tutor_sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('started_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return TutorSession.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar sessão ativa: $e', tag: _tag);
      return null;
    }
  }

  @override
  Future<List<TutorSession>> getSessions(String userId, {int limit = 10}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client
          .from('tutor_sessions')
          .select()
          .eq('user_id', userId)
          .order('started_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response)
          .map(TutorSession.fromJson)
          .toList();
    } catch (e) {
      ChronosLogger.error('Erro ao buscar sessões: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> saveSession(TutorSession session) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('tutor_sessions').upsert(session.toJson());
    } catch (e) {
      ChronosLogger.error('Erro ao salvar sessão: $e', tag: _tag);
    }
  }

  @override
  Future<List<TutorMemoryEntry>> getMemory(String userId, {TutorMemoryType? type}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('tutor_memory').select().eq('user_id', userId);
      if (type != null) {
        query = query.eq('type', type.name);
      }
      final response = await query.order('recorded_at', ascending: false);
      return List<Map<String, dynamic>>.from(response)
          .map(TutorMemoryEntry.fromJson)
          .toList();
    } catch (e) {
      ChronosLogger.error('Erro ao buscar memória: $e', tag: _tag);
      return [];
    }
  }

  @override
  Future<void> saveMemoryEntry(TutorMemoryEntry entry) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('tutor_memory').insert(entry.toJson()..remove('id'));
    } catch (e) {
      ChronosLogger.error('Erro ao salvar memória: $e', tag: _tag);
    }
  }

  @override
  Future<void> clearMemory(String userId) async {
    try {
      final client = _client;
      if (client == null) return;
      await client.from('tutor_memory').delete().eq('user_id', userId);
    } catch (e) {
      ChronosLogger.error('Erro ao limpar memória: $e', tag: _tag);
    }
  }
}
