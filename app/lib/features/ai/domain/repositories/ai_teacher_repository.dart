import '../entities/ai_teacher_entities.dart';

/// Repositório de persistência do Tutor de IA.
abstract class AiTeacherRepository {
  // Sessões de estudo
  Future<TutorSession?> getSession(String sessionId);
  Future<TutorSession?> getActiveSession(String userId);
  Future<List<TutorSession>> getSessions(String userId, {int limit = 10});
  Future<void> saveSession(TutorSession session);

  // Memória do tutor
  Future<List<TutorMemoryEntry>> getMemory(String userId, {TutorMemoryType? type});
  Future<void> saveMemoryEntry(TutorMemoryEntry entry);
  Future<void> clearMemory(String userId);
}
