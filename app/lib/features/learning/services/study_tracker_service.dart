import 'package:flutter/foundation.dart';

import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Serviço de rastreamento de estudo.
///
/// Registra automaticamente: conteúdos visualizados, tempo de leitura,
/// último acesso, frequência de estudo e data da última revisão.
class StudyTrackerService extends ChangeNotifier {
  final LearningRepository _repository;
  final String _userId;

  DateTime? _sessionStart;
  String? _currentEntityId;
  String? _currentEntityType;
  String? _currentEntityName;

  StudyTrackerService({
    required LearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  String get userId => _userId;
  bool get isTracking => _sessionStart != null;

  /// Inicia rastreamento de leitura de uma entidade.
  void startReading(String entityId, String entityType, String entityName) {
    _sessionStart = DateTime.now();
    _currentEntityId = entityId;
    _currentEntityType = entityType;
    _currentEntityName = entityName;
  }

  /// Finaliza rastreamento e persiste no banco.
  Future<void> stopReading() async {
    if (_sessionStart == null || _currentEntityId == null) return;

    final duration = DateTime.now().difference(_sessionStart!).inSeconds;
    final entityId = _currentEntityId!;
    final entityType = _currentEntityType!;
    final entityName = _currentEntityName ?? '';

    // Registrar atividade
    final record = StudyRecord(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityType: entityType,
      entityName: entityName,
      activityType: StudyActivityType.read,
      durationSeconds: duration,
      startedAt: _sessionStart!,
      completedAt: DateTime.now(),
    );
    await _repository.recordActivity(record);

    // Atualizar progresso
    await _updateProgress(entityId, entityType, entityName, duration);

    // Limpar sessão
    _sessionStart = null;
    _currentEntityId = null;
    _currentEntityType = null;
    _currentEntityName = null;
    notifyListeners();
  }

  /// Registra uma visualização rápida (sem tempo de leitura).
  Future<void> recordView(String entityId, String entityType, String entityName) async {
    final record = StudyRecord(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityType: entityType,
      entityName: entityName,
      activityType: StudyActivityType.view,
      durationSeconds: 0,
      startedAt: DateTime.now(),
    );
    await _repository.recordActivity(record);
    await _updateProgress(entityId, entityType, entityName, 0);
  }

  /// Obtém histórico recente ("Continue de onde parou").
  Future<List<StudyProgress>> getContinueFromWhereYouLeft({int limit = 5}) async {
    return _repository.getRecentProgress(_userId, limit: limit);
  }

  /// Obtém todo o histórico do usuário.
  Future<List<StudyRecord>> getFullHistory({int limit = 50}) async {
    return _repository.getHistory(_userId, limit: limit);
  }

  /// Obtém progresso de uma entidade específica.
  Future<StudyProgress?> getEntityProgress(String entityId) async {
    return _repository.getProgress(_userId, entityId);
  }

  /// Marca conteúdo com um status (Estudado, Revisar depois, etc.).
  Future<void> markContent(String entityId, StudyStatus status) async {
    await _repository.updateStatus(_userId, entityId, status);
    notifyListeners();
  }

  Future<void> _updateProgress(
    String entityId,
    String entityType,
    String entityName,
    int durationSeconds,
  ) async {
    final existing = await _repository.getProgress(_userId, entityId);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        totalReadTimeSeconds: existing.totalReadTimeSeconds + durationSeconds,
        viewCount: existing.viewCount + 1,
        lastAccess: now,
        status: existing.status == StudyStatus.notStarted
            ? StudyStatus.inProgress
            : existing.status,
      );
      await _repository.upsertProgress(updated);
    } else {
      final progress = StudyProgress(
        id: '',
        userId: _userId,
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
        status: StudyStatus.inProgress,
        totalReadTimeSeconds: durationSeconds,
        viewCount: 1,
        firstAccess: now,
        lastAccess: now,
      );
      await _repository.upsertProgress(progress);
    }
  }
}
