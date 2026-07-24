import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço de Auditoria.
///
/// Registra: login, alterações, exclusões, publicações,
/// restaurações, ações administrativas.
class AuditService {
  final AdminRepository _repository;
  static const _tag = 'AuditService';

  AuditService({required AdminRepository repository})
      : _repository = repository;

  /// Registra login.
  Future<void> logLogin(String userId, {String? ipAddress}) async {
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_login',
      userId: userId,
      action: AuditActionType.login,
      ipAddress: ipAddress,
      createdAt: DateTime.now(),
    ));
  }

  /// Registra logout.
  Future<void> logLogout(String userId) async {
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_logout',
      userId: userId,
      action: AuditActionType.logout,
      createdAt: DateTime.now(),
    ));
  }

  /// Registra ação genérica.
  Future<void> log({
    required String userId,
    required AuditActionType action,
    String? entityId,
    AdminEntityType? entityType,
    String? entityName,
    Map<String, dynamic>? details,
  }) async {
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_${action.name}',
      userId: userId,
      action: action,
      entityId: entityId,
      entityType: entityType,
      entityName: entityName,
      details: details,
      createdAt: DateTime.now(),
    ));
    ChronosLogger.info('Audit: ${action.name} por $userId', tag: _tag);
  }

  /// Obtém logs de auditoria com filtros.
  Future<List<AuditLogEntry>> getLogs({
    String? userId,
    AuditActionType? action,
    int limit = 100,
  }) =>
      _repository.getAuditLogs(userId: userId, action: action, limit: limit);

  /// Obtém logs de um usuário específico.
  Future<List<AuditLogEntry>> getUserLogs(String userId, {int limit = 50}) =>
      _repository.getAuditLogs(userId: userId, limit: limit);

  /// Obtém logs de uma ação específica.
  Future<List<AuditLogEntry>> getActionLogs(AuditActionType action,
      {int limit = 50}) =>
      _repository.getAuditLogs(action: action, limit: limit);
}
