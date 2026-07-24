import '../entities/admin_entities.dart';

/// Repositório de dados do Admin Studio.
abstract class AdminRepository {
  // ── Dashboard ──
  Future<AdminDashboardStats> getDashboardStats();

  // ── Conteúdo Gerenciável (CRUD genérico) ──
  Future<List<ManagedContent>> listContents(AdminEntityType type,
      {EditorialStatus? status, int limit = 50, int offset = 0});
  Future<ManagedContent?> getContent(String id);
  Future<ManagedContent> createContent(ManagedContent content);
  Future<ManagedContent> updateContent(ManagedContent content);
  Future<void> deleteContent(String id);

  // ── Fluxo Editorial ──
  Future<EditorialEntry?> getEditorialEntry(String entityId);
  Future<void> upsertEditorialEntry(EditorialEntry entry);
  Future<List<EditorialEntry>> getEntriesByStatus(EditorialStatus status,
      {int limit = 50});

  // ── Versionamento ──
  Future<List<ContentVersion>> getVersions(String entityId);
  Future<ContentVersion?> getVersion(String versionId);
  Future<void> saveVersion(ContentVersion version);

  // ── Auditoria ──
  Future<void> logAudit(AuditLogEntry entry);
  Future<List<AuditLogEntry>> getAuditLogs(
      {String? userId, AuditActionType? action, int limit = 100});

  // ── Mídia ──
  Future<List<MediaAsset>> listMedia(
      {MediaType? type, String? folder, int limit = 50});
  Future<MediaAsset> saveMedia(MediaAsset asset);
  Future<void> deleteMedia(String id);

  // ── Usuários ──
  Future<List<AdminUser>> listUsers({AdminRole? role, int limit = 50});
  Future<AdminUser?> getUser(String userId);
  Future<void> updateUserRole(String userId, AdminRole role);
  Future<void> updateUserPermissions(
      String userId, List<AdminPermission> permissions);
  Future<void> deactivateUser(String userId);
}
