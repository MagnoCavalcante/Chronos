import '../entities/learning_path_entities.dart';

/// Contrato do repositório de Learning Paths.
abstract class LearningPathsRepository {
  // Catálogo
  Future<List<LearningPath>> getAllPaths({PathCategory? category, PathDifficulty? difficulty});
  Future<LearningPath?> getPath(String pathId);
  Future<List<LearningPath>> searchPaths(String query);

  // Módulos
  Future<List<PathModule>> getModules(String pathId);
  Future<List<PathContent>> getModuleContents(String moduleId);

  // Progresso da trilha
  Future<PathProgress?> getPathProgress(String userId, String pathId);
  Future<List<PathProgress>> getUserPaths(String userId);
  Future<List<PathProgress>> getInProgressPaths(String userId);
  Future<List<PathProgress>> getCompletedPaths(String userId);
  Future<void> upsertPathProgress(PathProgress progress);

  // Progresso do módulo
  Future<ModuleProgress?> getModuleProgress(String userId, String moduleId);
  Future<List<ModuleProgress>> getPathModuleProgress(String userId, String pathId);
  Future<void> upsertModuleProgress(ModuleProgress progress);

  // Certificados
  Future<List<PathCertificate>> getCertificates(String userId);
  Future<void> issueCertificate(PathCertificate certificate);
}
