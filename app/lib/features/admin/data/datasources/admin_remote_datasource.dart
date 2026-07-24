import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/admin_entities.dart';

/// DataSource remoto (Supabase) para Admin Studio.
class AdminRemoteDataSource {
  static const _tag = 'AdminRemoteDS';

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // ── Dashboard ──

  Future<AdminDashboardStats> fetchDashboardStats() async {
    try {
      final client = _client;
      if (client == null) return const AdminDashboardStats();

      final contents = await client.from('managed_contents').select('entity_type, status');
      final contentsList = List<Map<String, dynamic>>.from(contents);

      int characters = 0, events = 0, civilizations = 0, artifacts = 0;
      int locations = 0, sources = 0, paths = 0, quizzes = 0;
      int published = 0, inReview = 0;

      for (final c in contentsList) {
        final type = c['entity_type'] as String? ?? '';
        final status = c['status'] as String? ?? '';
        if (status == 'published') published++;
        if (status == 'inReview') inReview++;
        switch (type) {
          case 'character': characters++; break;
          case 'event': events++; break;
          case 'civilization': civilizations++; break;
          case 'artifact': artifacts++; break;
          case 'location': locations++; break;
          case 'source': sources++; break;
          case 'learningPath': paths++; break;
          case 'quiz': quizzes++; break;
        }
      }

      return AdminDashboardStats(
        publishedContents: published,
        contentsInReview: inReview,
        characters: characters,
        events: events,
        civilizations: civilizations,
        artifacts: artifacts,
        locations: locations,
        sources: sources,
        learningPaths: paths,
        quizzes: quizzes,
      );
    } catch (e) {
      ChronosLogger.error('Erro fetchDashboardStats: $e', tag: _tag);
      return const AdminDashboardStats();
    }
  }

  // ── Conteúdo ──

  Future<List<Map<String, dynamic>>> fetchContents(
      String entityType, {String? status, int limit = 50, int offset = 0}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('managed_contents').select().eq('entity_type', entityType);
      if (status != null) query = query.eq('status', status);
      final response = await query.order('updated_at', ascending: false).range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro fetchContents: $e', tag: _tag);
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchContent(String id) async {
    try {
      final client = _client;
      if (client == null) return null;
      return await client.from('managed_contents').select().eq('id', id).maybeSingle();
    } catch (e) {
      ChronosLogger.error('Erro fetchContent: $e', tag: _tag);
      return null;
    }
  }

  Future<Map<String, dynamic>> insertContent(Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return data;
    final response = await client.from('managed_contents').insert(data).select().single();
    return response;
  }

  Future<Map<String, dynamic>> updateContent(String id, Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return data;
    final response = await client.from('managed_contents').update(data).eq('id', id).select().single();
    return response;
  }

  Future<void> deleteContent(String id) async {
    final client = _client;
    if (client == null) return;
    await client.from('managed_contents').delete().eq('id', id);
  }

  // ── Editorial ──

  Future<Map<String, dynamic>?> fetchEditorialEntry(String entityId) async {
    try {
      final client = _client;
      if (client == null) return null;
      return await client.from('editorial_flow').select().eq('entity_id', entityId).maybeSingle();
    } catch (e) {
      ChronosLogger.error('Erro fetchEditorialEntry: $e', tag: _tag);
      return null;
    }
  }

  Future<void> upsertEditorialEntry(Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return;
    await client.from('editorial_flow').upsert(data);
  }

  Future<List<Map<String, dynamic>>> fetchEntriesByStatus(String status, {int limit = 50}) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client.from('editorial_flow').select().eq('status', status)
          .order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro fetchEntriesByStatus: $e', tag: _tag);
      return [];
    }
  }

  // ── Versionamento ──

  Future<List<Map<String, dynamic>>> fetchVersions(String entityId) async {
    try {
      final client = _client;
      if (client == null) return [];
      final response = await client.from('content_versions').select().eq('entity_id', entityId)
          .order('version_number', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro fetchVersions: $e', tag: _tag);
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchVersion(String versionId) async {
    try {
      final client = _client;
      if (client == null) return null;
      return await client.from('content_versions').select().eq('id', versionId).maybeSingle();
    } catch (e) {
      ChronosLogger.error('Erro fetchVersion: $e', tag: _tag);
      return null;
    }
  }

  Future<void> insertVersion(Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return;
    await client.from('content_versions').insert(data);
  }

  // ── Auditoria ──

  Future<void> insertAuditLog(Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return;
    await client.from('audit_logs').insert(data);
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs(
      {String? userId, String? action, int limit = 100}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('audit_logs').select();
      if (userId != null) query = query.eq('user_id', userId);
      if (action != null) query = query.eq('action', action);
      final response = await query.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro fetchAuditLogs: $e', tag: _tag);
      return [];
    }
  }

  // ── Mídia ──

  Future<List<Map<String, dynamic>>> fetchMedia(
      {String? type, String? folder, int limit = 50}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('media_library').select();
      if (type != null) query = query.eq('type', type);
      if (folder != null) query = query.eq('folder', folder);
      final response = await query.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro fetchMedia: $e', tag: _tag);
      return [];
    }
  }

  Future<Map<String, dynamic>> insertMedia(Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return data;
    final response = await client.from('media_library').insert(data).select().single();
    return response;
  }

  Future<void> deleteMedia(String id) async {
    final client = _client;
    if (client == null) return;
    await client.from('media_library').delete().eq('id', id);
  }

  // ── Usuários ──

  Future<List<Map<String, dynamic>>> fetchUsers({String? role, int limit = 50}) async {
    try {
      final client = _client;
      if (client == null) return [];
      var query = client.from('admin_users').select();
      if (role != null) query = query.eq('role', role);
      final response = await query.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ChronosLogger.error('Erro fetchUsers: $e', tag: _tag);
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchUser(String userId) async {
    try {
      final client = _client;
      if (client == null) return null;
      return await client.from('admin_users').select().eq('id', userId).maybeSingle();
    } catch (e) {
      ChronosLogger.error('Erro fetchUser: $e', tag: _tag);
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    final client = _client;
    if (client == null) return;
    await client.from('admin_users').update(data).eq('id', userId);
  }
}
