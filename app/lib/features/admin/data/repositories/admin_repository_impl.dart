import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

/// Implementação do AdminRepository usando Supabase.
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _ds;

  AdminRepositoryImpl({required AdminRemoteDataSource dataSource}) : _ds = dataSource;

  // ── Dashboard ──

  @override
  Future<AdminDashboardStats> getDashboardStats() => _ds.fetchDashboardStats();

  // ── Conteúdo ──

  @override
  Future<List<ManagedContent>> listContents(AdminEntityType type,
      {EditorialStatus? status, int limit = 50, int offset = 0}) async {
    final rows = await _ds.fetchContents(type.name,
        status: status?.name, limit: limit, offset: offset);
    return rows.map(ManagedContent.fromJson).toList();
  }

  @override
  Future<ManagedContent?> getContent(String id) async {
    final row = await _ds.fetchContent(id);
    return row != null ? ManagedContent.fromJson(row) : null;
  }

  @override
  Future<ManagedContent> createContent(ManagedContent content) async {
    final row = await _ds.insertContent(content.toJson());
    return ManagedContent.fromJson(row);
  }

  @override
  Future<ManagedContent> updateContent(ManagedContent content) async {
    final row = await _ds.updateContent(content.id, content.toJson());
    return ManagedContent.fromJson(row);
  }

  @override
  Future<void> deleteContent(String id) => _ds.deleteContent(id);

  // ── Editorial ──

  @override
  Future<EditorialEntry?> getEditorialEntry(String entityId) async {
    final row = await _ds.fetchEditorialEntry(entityId);
    return row != null ? EditorialEntry.fromJson(row) : null;
  }

  @override
  Future<void> upsertEditorialEntry(EditorialEntry entry) =>
      _ds.upsertEditorialEntry(entry.toJson());

  @override
  Future<List<EditorialEntry>> getEntriesByStatus(EditorialStatus status,
      {int limit = 50}) async {
    final rows = await _ds.fetchEntriesByStatus(status.name, limit: limit);
    return rows.map(EditorialEntry.fromJson).toList();
  }

  // ── Versionamento ──

  @override
  Future<List<ContentVersion>> getVersions(String entityId) async {
    final rows = await _ds.fetchVersions(entityId);
    return rows.map(ContentVersion.fromJson).toList();
  }

  @override
  Future<ContentVersion?> getVersion(String versionId) async {
    final row = await _ds.fetchVersion(versionId);
    return row != null ? ContentVersion.fromJson(row) : null;
  }

  @override
  Future<void> saveVersion(ContentVersion version) =>
      _ds.insertVersion(version.toJson());

  // ── Auditoria ──

  @override
  Future<void> logAudit(AuditLogEntry entry) =>
      _ds.insertAuditLog(entry.toJson());

  @override
  Future<List<AuditLogEntry>> getAuditLogs(
      {String? userId, AuditActionType? action, int limit = 100}) async {
    final rows = await _ds.fetchAuditLogs(
        userId: userId, action: action?.name, limit: limit);
    return rows.map(AuditLogEntry.fromJson).toList();
  }

  // ── Mídia ──

  @override
  Future<List<MediaAsset>> listMedia(
      {MediaType? type, String? folder, int limit = 50}) async {
    final rows =
        await _ds.fetchMedia(type: type?.name, folder: folder, limit: limit);
    return rows.map(MediaAsset.fromJson).toList();
  }

  @override
  Future<MediaAsset> saveMedia(MediaAsset asset) async {
    final row = await _ds.insertMedia(asset.toJson());
    return MediaAsset.fromJson(row);
  }

  @override
  Future<void> deleteMedia(String id) => _ds.deleteMedia(id);

  // ── Usuários ──

  @override
  Future<List<AdminUser>> listUsers({AdminRole? role, int limit = 50}) async {
    final rows = await _ds.fetchUsers(role: role?.name, limit: limit);
    return rows.map(AdminUser.fromJson).toList();
  }

  @override
  Future<AdminUser?> getUser(String userId) async {
    final row = await _ds.fetchUser(userId);
    return row != null ? AdminUser.fromJson(row) : null;
  }

  @override
  Future<void> updateUserRole(String userId, AdminRole role) =>
      _ds.updateUser(userId, {'role': role.name});

  @override
  Future<void> updateUserPermissions(
      String userId, List<AdminPermission> permissions) =>
      _ds.updateUser(userId, {
        'permissions': permissions.map((p) => p.toJson()).toList(),
      });

  @override
  Future<void> deactivateUser(String userId) =>
      _ds.updateUser(userId, {'is_active': false});
}
