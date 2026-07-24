import '../../../core/utils/logger.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../domain/entities/ai_teacher_entities.dart';
import '../domain/repositories/ai_teacher_repository.dart';

/// Serviço de Memória do Tutor.
///
/// Registra dúvidas, assuntos difíceis, assuntos dominados e progresso.
/// Integra com o Learning Engine para alimentar perfil de aprendizagem.
class TutorMemoryService {
  final AiTeacherRepository _repository;
  final LearningRepository _learningRepo;
  final String _userId;

  static const _tag = 'TutorMemoryService';

  TutorMemoryService({
    required AiTeacherRepository repository,
    required LearningRepository learningRepository,
    String userId = 'local_user',
  })  : _repository = repository,
        _learningRepo = learningRepository,
        _userId = userId;

  /// Registra dúvida do aluno.
  Future<void> recordDoubt({
    required String entityId,
    required String entityName,
    required String question,
  }) async {
    await _repository.saveMemoryEntry(TutorMemoryEntry(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityName: entityName,
      type: TutorMemoryType.doubt,
      content: question,
      recordedAt: DateTime.now(),
    ));
    ChronosLogger.info('Dúvida registrada: $entityName → $question', tag: _tag);
  }

  /// Registra dificuldade detectada.
  Future<void> recordDifficulty({
    required String entityId,
    required String entityName,
    required String description,
  }) async {
    await _repository.saveMemoryEntry(TutorMemoryEntry(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityName: entityName,
      type: TutorMemoryType.difficulty,
      content: description,
      recordedAt: DateTime.now(),
    ));
    ChronosLogger.info('Dificuldade registrada: $entityName', tag: _tag);
  }

  /// Registra tópico dominado.
  Future<void> recordMastery({
    required String entityId,
    required String entityName,
  }) async {
    await _repository.saveMemoryEntry(TutorMemoryEntry(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityName: entityName,
      type: TutorMemoryType.mastered,
      content: 'Dominado pelo aluno',
      recordedAt: DateTime.now(),
    ));
    ChronosLogger.info('Mastery registrada: $entityName', tag: _tag);
  }

  /// Registra progresso de estudo.
  Future<void> recordProgress({
    required String entityId,
    required String entityName,
    required String progressDescription,
  }) async {
    await _repository.saveMemoryEntry(TutorMemoryEntry(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityName: entityName,
      type: TutorMemoryType.progress,
      content: progressDescription,
      recordedAt: DateTime.now(),
    ));
  }

  /// Obtém dúvidas frequentes do aluno.
  Future<List<TutorMemoryEntry>> getFrequentDoubts() async {
    return _repository.getMemory(_userId, type: TutorMemoryType.doubt);
  }

  /// Obtém assuntos difíceis.
  Future<List<TutorMemoryEntry>> getDifficulties() async {
    return _repository.getMemory(_userId, type: TutorMemoryType.difficulty);
  }

  /// Obtém assuntos dominados.
  Future<List<TutorMemoryEntry>> getMasteredTopics() async {
    return _repository.getMemory(_userId, type: TutorMemoryType.mastered);
  }

  /// Obtém todo o progresso registrado.
  Future<List<TutorMemoryEntry>> getProgress() async {
    return _repository.getMemory(_userId, type: TutorMemoryType.progress);
  }

  /// Obtém toda a memória do tutor.
  Future<List<TutorMemoryEntry>> getAllMemory() async {
    return _repository.getMemory(_userId);
  }

  /// Limpa toda a memória do tutor.
  Future<void> clearMemory() async {
    await _repository.clearMemory(_userId);
    ChronosLogger.info('Memória do tutor limpa', tag: _tag);
  }
}
