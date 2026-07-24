import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço de Gestão de Entidades (CRUD completo).
///
/// Suporta: Personagens, Eventos, Civilizações, Artefatos,
/// Localizações, Fontes, Trilhas, Quizzes.
///
/// Toda operação gera versão e log de auditoria.
class EntityManagementService {
  final AdminRepository _repository;
  static const _tag = 'EntityMgmtService';

  EntityManagementService({required AdminRepository repository})
      : _repository = repository;

  /// Lista conteúdos por tipo de entidade.
  Future<List<ManagedContent>> list(
    AdminEntityType type, {
    EditorialStatus? status,
    int limit = 50,
    int offset = 0,
  }) =>
      _repository.listContents(type, status: status, limit: limit, offset: offset);

  /// Obtém um conteúdo por id.
  Future<ManagedContent?> get(String id) => _repository.getContent(id);

  /// Cria novo conteúdo (inicia como rascunho).
  Future<ManagedContent> create({
    required AdminEntityType entityType,
    required String name,
    required Map<String, dynamic> fields,
    required String userId,
    List<String> tags = const [],
    List<EditorBlock> blocks = const [],
  }) async {
    final now = DateTime.now();
    final content = ManagedContent(
      id: '${now.millisecondsSinceEpoch}_${entityType.name}',
      entityType: entityType,
      name: name,
      status: EditorialStatus.draft,
      fields: fields,
      tags: tags,
      blocks: blocks,
      createdBy: userId,
      currentVersion: 1,
      createdAt: now,
      updatedAt: now,
    );

    final created = await _repository.createContent(content);

    // Criar versão inicial
    await _repository.saveVersion(ContentVersion(
      id: '${created.id}_v1',
      entityId: created.id,
      entityType: entityType,
      versionNumber: 1,
      data: created.toJson(),
      authorId: userId,
      changeDescription: 'Criação inicial',
      createdAt: now,
    ));

    // Criar entrada editorial
    await _repository.upsertEditorialEntry(EditorialEntry(
      id: '${created.id}_editorial',
      entityId: created.id,
      entityType: entityType,
      status: EditorialStatus.draft,
      createdBy: userId,
      createdAt: now,
    ));

    // Log de auditoria
    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_create',
      userId: userId,
      action: AuditActionType.create,
      entityId: created.id,
      entityType: entityType,
      entityName: name,
      createdAt: now,
    ));

    ChronosLogger.info('Conteúdo criado: $name (${entityType.label})', tag: _tag);
    return created;
  }

  /// Atualiza conteúdo existente (gera nova versão).
  Future<ManagedContent> update({
    required ManagedContent content,
    required String userId,
    String? changeDescription,
  }) async {
    final now = DateTime.now();
    final newVersion = content.currentVersion + 1;
    final updated = content.copyWith(
      updatedBy: userId,
      currentVersion: newVersion,
      updatedAt: now,
    );

    final result = await _repository.updateContent(updated);

    // Salvar nova versão
    await _repository.saveVersion(ContentVersion(
      id: '${content.id}_v$newVersion',
      entityId: content.id,
      entityType: content.entityType,
      versionNumber: newVersion,
      data: result.toJson(),
      authorId: userId,
      changeDescription: changeDescription ?? 'Atualização',
      createdAt: now,
    ));

    // Log de auditoria
    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_update',
      userId: userId,
      action: AuditActionType.update,
      entityId: content.id,
      entityType: content.entityType,
      entityName: content.name,
      details: {'version': newVersion, 'change': changeDescription},
      createdAt: now,
    ));

    ChronosLogger.info('Conteúdo atualizado: ${content.name} (v$newVersion)', tag: _tag);
    return result;
  }

  /// Exclui conteúdo.
  Future<void> delete({
    required String contentId,
    required String userId,
    String? entityName,
  }) async {
    await _repository.deleteContent(contentId);
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_delete',
      userId: userId,
      action: AuditActionType.delete,
      entityId: contentId,
      entityName: entityName,
      createdAt: DateTime.now(),
    ));
    ChronosLogger.info('Conteúdo excluído: $contentId', tag: _tag);
  }

  /// Restaura uma versão anterior.
  Future<ManagedContent?> restoreVersion({
    required String contentId,
    required String versionId,
    required String userId,
  }) async {
    final version = await _repository.getVersion(versionId);
    if (version == null) return null;

    final restored = ManagedContent.fromJson(version.data);
    final now = DateTime.now();
    final newVersion = restored.currentVersion + 1;

    final updated = restored.copyWith(
      updatedBy: userId,
      currentVersion: newVersion,
      updatedAt: now,
    );

    final result = await _repository.updateContent(updated);

    await _repository.saveVersion(ContentVersion(
      id: '${contentId}_v$newVersion',
      entityId: contentId,
      entityType: restored.entityType,
      versionNumber: newVersion,
      data: result.toJson(),
      authorId: userId,
      changeDescription: 'Restaurado da versão ${version.versionNumber}',
      createdAt: now,
    ));

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_restore',
      userId: userId,
      action: AuditActionType.restore,
      entityId: contentId,
      entityName: restored.name,
      details: {'restored_from_version': version.versionNumber},
      createdAt: now,
    ));

    ChronosLogger.info(
        'Versão restaurada: ${restored.name} (v${version.versionNumber} → v$newVersion)',
        tag: _tag);
    return result;
  }

  /// Obtém histórico de versões.
  Future<List<ContentVersion>> getVersionHistory(String entityId) =>
      _repository.getVersions(entityId);
}
