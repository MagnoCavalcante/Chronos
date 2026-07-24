import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço de Gestão de Usuários.
///
/// Perfis: SuperAdmin, Admin, Editor, Revisor, Tradutor,
/// Moderador, Premium, Gratuito.
/// Permissões granulares por módulo.
class UserManagementService {
  final AdminRepository _repository;
  static const _tag = 'UserMgmtService';

  UserManagementService({required AdminRepository repository})
      : _repository = repository;

  /// Lista todos os usuários (com filtro opcional por role).
  Future<List<AdminUser>> listUsers({AdminRole? role, int limit = 50}) =>
      _repository.listUsers(role: role, limit: limit);

  /// Obtém usuário por id.
  Future<AdminUser?> getUser(String userId) => _repository.getUser(userId);

  /// Altera papel do usuário.
  Future<void> changeRole({
    required String userId,
    required AdminRole newRole,
    required String adminId,
  }) async {
    await _repository.updateUserRole(userId, newRole);
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_roleChange',
      userId: adminId,
      action: AuditActionType.roleChange,
      entityId: userId,
      details: {'new_role': newRole.name},
      createdAt: DateTime.now(),
    ));
    ChronosLogger.info('Role alterado: $userId → ${newRole.label}', tag: _tag);
  }

  /// Define permissões granulares.
  Future<void> setPermissions({
    required String userId,
    required List<AdminPermission> permissions,
    required String adminId,
  }) async {
    await _repository.updateUserPermissions(userId, permissions);
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_permChange',
      userId: adminId,
      action: AuditActionType.permissionChange,
      entityId: userId,
      details: {'modules': permissions.map((p) => p.module.name).toList()},
      createdAt: DateTime.now(),
    ));
    ChronosLogger.info('Permissões atualizadas: $userId', tag: _tag);
  }

  /// Desativa usuário.
  Future<void> deactivate({
    required String userId,
    required String adminId,
  }) async {
    await _repository.deactivateUser(userId);
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_deactivate',
      userId: adminId,
      action: AuditActionType.update,
      entityId: userId,
      details: {'action': 'deactivate'},
      createdAt: DateTime.now(),
    ));
    ChronosLogger.info('Usuário desativado: $userId', tag: _tag);
  }

  /// Retorna permissões padrão para um papel.
  List<AdminPermission> getDefaultPermissions(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminModule.values
            .map((m) => AdminPermission(
                module: m, actions: PermissionAction.values.toList()))
            .toList();
      case AdminRole.admin:
        return AdminModule.values
            .map((m) => AdminPermission(
                module: m,
                actions: [
                  PermissionAction.read,
                  PermissionAction.create,
                  PermissionAction.update,
                  PermissionAction.delete,
                  PermissionAction.publish,
                ]))
            .toList();
      case AdminRole.editor:
        return [
          AdminModule.characters,
          AdminModule.events,
          AdminModule.civilizations,
          AdminModule.artifacts,
          AdminModule.locations,
          AdminModule.sources,
          AdminModule.media,
        ]
            .map((m) => AdminPermission(
                module: m,
                actions: [
                  PermissionAction.read,
                  PermissionAction.create,
                  PermissionAction.update,
                ]))
            .toList();
      case AdminRole.reviewer:
        return [
          AdminModule.characters,
          AdminModule.events,
          AdminModule.civilizations,
          AdminModule.artifacts,
          AdminModule.locations,
          AdminModule.sources,
        ]
            .map((m) => AdminPermission(
                module: m,
                actions: [PermissionAction.read, PermissionAction.approve]))
            .toList();
      case AdminRole.translator:
        return [
          AdminModule.characters,
          AdminModule.events,
          AdminModule.civilizations,
        ]
            .map((m) => AdminPermission(
                module: m,
                actions: [PermissionAction.read, PermissionAction.update]))
            .toList();
      case AdminRole.moderator:
        return [AdminModule.users, AdminModule.audit]
            .map((m) => AdminPermission(
                module: m,
                actions: [PermissionAction.read, PermissionAction.update]))
            .toList();
      case AdminRole.premiumUser:
      case AdminRole.freeUser:
        return [
          AdminPermission(
              module: AdminModule.dashboard,
              actions: [PermissionAction.read]),
        ];
    }
  }
}
