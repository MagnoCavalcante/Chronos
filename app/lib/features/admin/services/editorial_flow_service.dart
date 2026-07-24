import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço de Fluxo Editorial.
///
/// Gerencia o ciclo de vida do conteúdo:
/// Rascunho → Em Revisão → Aprovado → Publicado → Arquivado
///
/// Registra quem criou, revisou e aprovou cada conteúdo.
class EditorialFlowService {
  final AdminRepository _repository;
  static const _tag = 'EditorialFlowService';

  EditorialFlowService({required AdminRepository repository})
      : _repository = repository;

  /// Envia conteúdo para revisão.
  Future<EditorialEntry> submitForReview({
    required String entityId,
    required AdminEntityType entityType,
    required String userId,
  }) async {
    final existing = await _repository.getEditorialEntry(entityId);
    final now = DateTime.now();

    final entry = existing?.copyWith(
          status: EditorialStatus.inReview,
        ) ??
        EditorialEntry(
          id: '${entityId}_editorial',
          entityId: entityId,
          entityType: entityType,
          status: EditorialStatus.inReview,
          createdBy: userId,
          createdAt: now,
        );

    await _repository.upsertEditorialEntry(entry);

    // Atualizar status do conteúdo
    final content = await _repository.getContent(entityId);
    if (content != null) {
      await _repository.updateContent(
          content.copyWith(status: EditorialStatus.inReview, updatedAt: now));
    }

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_review',
      userId: userId,
      action: AuditActionType.update,
      entityId: entityId,
      entityType: entityType,
      details: {'status_change': 'draft → inReview'},
      createdAt: now,
    ));

    ChronosLogger.info('Enviado para revisão: $entityId', tag: _tag);
    return entry;
  }

  /// Aprova conteúdo.
  Future<EditorialEntry?> approve({
    required String entityId,
    required String reviewerId,
  }) async {
    final existing = await _repository.getEditorialEntry(entityId);
    if (existing == null) return null;
    final now = DateTime.now();

    final entry = existing.copyWith(
      status: EditorialStatus.approved,
      approvedBy: reviewerId,
      approvedAt: now,
    );
    await _repository.upsertEditorialEntry(entry);

    final content = await _repository.getContent(entityId);
    if (content != null) {
      await _repository.updateContent(
          content.copyWith(status: EditorialStatus.approved, updatedAt: now));
    }

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_approve',
      userId: reviewerId,
      action: AuditActionType.approve,
      entityId: entityId,
      entityType: existing.entityType,
      createdAt: now,
    ));

    ChronosLogger.info('Aprovado: $entityId por $reviewerId', tag: _tag);
    return entry;
  }

  /// Rejeita conteúdo (retorna ao rascunho).
  Future<EditorialEntry?> reject({
    required String entityId,
    required String reviewerId,
    required String reason,
  }) async {
    final existing = await _repository.getEditorialEntry(entityId);
    if (existing == null) return null;
    final now = DateTime.now();

    final entry = existing.copyWith(
      status: EditorialStatus.draft,
      reviewedBy: reviewerId,
      reviewedAt: now,
      rejectionReason: reason,
    );
    await _repository.upsertEditorialEntry(entry);

    final content = await _repository.getContent(entityId);
    if (content != null) {
      await _repository.updateContent(
          content.copyWith(status: EditorialStatus.draft, updatedAt: now));
    }

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_reject',
      userId: reviewerId,
      action: AuditActionType.reject,
      entityId: entityId,
      entityType: existing.entityType,
      details: {'reason': reason},
      createdAt: now,
    ));

    ChronosLogger.info('Rejeitado: $entityId — $reason', tag: _tag);
    return entry;
  }

  /// Publica conteúdo aprovado.
  Future<EditorialEntry?> publish({
    required String entityId,
    required String publisherId,
  }) async {
    final existing = await _repository.getEditorialEntry(entityId);
    if (existing == null) return null;
    final now = DateTime.now();

    final entry = existing.copyWith(
      status: EditorialStatus.published,
      publishedAt: now,
    );
    await _repository.upsertEditorialEntry(entry);

    final content = await _repository.getContent(entityId);
    if (content != null) {
      await _repository.updateContent(
          content.copyWith(status: EditorialStatus.published, updatedAt: now));
    }

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_publish',
      userId: publisherId,
      action: AuditActionType.publish,
      entityId: entityId,
      entityType: existing.entityType,
      createdAt: now,
    ));

    ChronosLogger.info('Publicado: $entityId', tag: _tag);
    return entry;
  }

  /// Arquiva conteúdo.
  Future<EditorialEntry?> archive({
    required String entityId,
    required String userId,
  }) async {
    final existing = await _repository.getEditorialEntry(entityId);
    if (existing == null) return null;
    final now = DateTime.now();

    final entry = existing.copyWith(
      status: EditorialStatus.archived,
      archivedAt: now,
    );
    await _repository.upsertEditorialEntry(entry);

    final content = await _repository.getContent(entityId);
    if (content != null) {
      await _repository.updateContent(
          content.copyWith(status: EditorialStatus.archived, updatedAt: now));
    }

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_archive',
      userId: userId,
      action: AuditActionType.archive,
      entityId: entityId,
      entityType: existing.entityType,
      createdAt: now,
    ));

    ChronosLogger.info('Arquivado: $entityId', tag: _tag);
    return entry;
  }

  /// Lista conteúdos por status editorial.
  Future<List<EditorialEntry>> listByStatus(EditorialStatus status,
      {int limit = 50}) =>
      _repository.getEntriesByStatus(status, limit: limit);

  /// Obtém entrada editorial de uma entidade.
  Future<EditorialEntry?> getEntry(String entityId) =>
      _repository.getEditorialEntry(entityId);
}
