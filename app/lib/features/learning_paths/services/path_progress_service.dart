import '../../learning/domain/repositories/learning_repository.dart';
import '../../learning/domain/entities/learning_entities.dart';
import '../domain/entities/learning_path_entities.dart';
import '../domain/repositories/learning_paths_repository.dart';

/// Serviço de Progresso de Trilhas.
///
/// Gerencia desbloqueio de módulos, conclusão de conteúdos,
/// atualização de XP e integração com Learning Engine.
class PathProgressService {
  final LearningPathsRepository _pathsRepo;
  final LearningRepository _learningRepo;
  final String _userId;

  PathProgressService({
    required LearningPathsRepository pathsRepository,
    required LearningRepository learningRepository,
    String userId = 'local_user',
  })  : _pathsRepo = pathsRepository,
        _learningRepo = learningRepository,
        _userId = userId;

  /// Inicia uma trilha (cria progresso e desbloqueia primeiro módulo).
  Future<void> startPath(LearningPath path) async {
    final existing = await _pathsRepo.getPathProgress(_userId, path.id);
    if (existing != null) return;

    // Criar progresso da trilha
    final progress = PathProgress(
      id: '',
      userId: _userId,
      pathId: path.id,
      pathName: path.name,
      status: PathStatus.inProgress,
      totalModules: path.totalModules,
      totalContents: path.totalContents,
      startedAt: DateTime.now(),
      lastAccessAt: DateTime.now(),
    );
    await _pathsRepo.upsertPathProgress(progress);

    // Desbloquear primeiro módulo
    if (path.modules.isNotEmpty) {
      final firstModule = path.modules.first;
      await _pathsRepo.upsertModuleProgress(ModuleProgress(
        id: '',
        userId: _userId,
        moduleId: firstModule.id,
        pathId: path.id,
        status: ModuleStatus.unlocked,
        totalContents: firstModule.totalContents,
      ));

      // Bloquear os demais
      for (int i = 1; i < path.modules.length; i++) {
        await _pathsRepo.upsertModuleProgress(ModuleProgress(
          id: '',
          userId: _userId,
          moduleId: path.modules[i].id,
          pathId: path.id,
          status: ModuleStatus.locked,
          totalContents: path.modules[i].totalContents,
        ));
      }
    }
  }

  /// Marca um conteúdo como concluído dentro de um módulo.
  Future<ContentCompletionResult> completeContent({
    required String pathId,
    required String moduleId,
    required String entityId,
    required String entityType,
    required String entityName,
    int readTimeSeconds = 0,
  }) async {
    // Registrar no Learning Engine
    await _learningRepo.recordActivity(StudyRecord(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityType: entityType,
      entityName: entityName,
      activityType: StudyActivityType.read,
      durationSeconds: readTimeSeconds,
      startedAt: DateTime.now().subtract(Duration(seconds: readTimeSeconds)),
      completedAt: DateTime.now(),
    ));

    // Atualizar progresso do módulo
    final moduleProgress = await _pathsRepo.getModuleProgress(_userId, moduleId);
    final newCompleted = (moduleProgress?.completedContents ?? 0) + 1;
    final totalContents = moduleProgress?.totalContents ?? 1;
    final moduleCompleted = newCompleted >= totalContents;

    await _pathsRepo.upsertModuleProgress(ModuleProgress(
      id: moduleProgress?.id ?? '',
      userId: _userId,
      moduleId: moduleId,
      pathId: pathId,
      status: moduleCompleted ? ModuleStatus.completed : ModuleStatus.inProgress,
      completedContents: newCompleted,
      totalContents: totalContents,
      startedAt: moduleProgress?.startedAt ?? DateTime.now(),
      completedAt: moduleCompleted ? DateTime.now() : null,
    ));

    // Se módulo completado, desbloquear próximo
    bool nextModuleUnlocked = false;
    if (moduleCompleted) {
      nextModuleUnlocked = await _unlockNextModule(pathId, moduleId);
    }

    // Atualizar progresso da trilha
    final pathProgress = await _pathsRepo.getPathProgress(_userId, pathId);
    final pathCompletedContents = (pathProgress?.completedContents ?? 0) + 1;
    final pathCompletedModules = (pathProgress?.completedModules ?? 0) + (moduleCompleted ? 1 : 0);
    final pathTotalContents = pathProgress?.totalContents ?? 1;
    final pathCompleted = pathCompletedContents >= pathTotalContents;

    await _pathsRepo.upsertPathProgress(PathProgress(
      id: pathProgress?.id ?? '',
      userId: _userId,
      pathId: pathId,
      pathName: pathProgress?.pathName ?? '',
      status: pathCompleted ? PathStatus.completed : PathStatus.inProgress,
      completedModules: pathCompletedModules,
      completedContents: pathCompletedContents,
      totalModules: pathProgress?.totalModules ?? 0,
      totalContents: pathTotalContents,
      totalTimeSeconds: (pathProgress?.totalTimeSeconds ?? 0) + readTimeSeconds,
      startedAt: pathProgress?.startedAt ?? DateTime.now(),
      completedAt: pathCompleted ? DateTime.now() : null,
      lastAccessAt: DateTime.now(),
    ));

    return ContentCompletionResult(
      moduleCompleted: moduleCompleted,
      pathCompleted: pathCompleted,
      nextModuleUnlocked: nextModuleUnlocked,
      newCompletedContents: pathCompletedContents,
      totalContents: pathTotalContents,
    );
  }

  /// Obtém trilhas em andamento.
  Future<List<PathProgress>> getInProgressPaths() async {
    return _pathsRepo.getInProgressPaths(_userId);
  }

  /// Obtém trilhas concluídas.
  Future<List<PathProgress>> getCompletedPaths() async {
    return _pathsRepo.getCompletedPaths(_userId);
  }

  /// Obtém progresso de uma trilha específica.
  Future<PathProgress?> getPathProgress(String pathId) async {
    return _pathsRepo.getPathProgress(_userId, pathId);
  }

  /// Obtém status dos módulos de uma trilha.
  Future<List<ModuleProgress>> getModuleStatuses(String pathId) async {
    return _pathsRepo.getPathModuleProgress(_userId, pathId);
  }

  Future<bool> _unlockNextModule(String pathId, String completedModuleId) async {
    final path = await _pathsRepo.getPath(pathId);
    if (path == null) return false;

    final completedIdx = path.modules.indexWhere((m) => m.id == completedModuleId);
    if (completedIdx < 0 || completedIdx >= path.modules.length - 1) return false;

    final nextModule = path.modules[completedIdx + 1];
    await _pathsRepo.upsertModuleProgress(ModuleProgress(
      id: '',
      userId: _userId,
      moduleId: nextModule.id,
      pathId: pathId,
      status: ModuleStatus.unlocked,
      totalContents: nextModule.totalContents,
    ));
    return true;
  }
}

/// Resultado da conclusão de um conteúdo.
class ContentCompletionResult {
  final bool moduleCompleted;
  final bool pathCompleted;
  final bool nextModuleUnlocked;
  final int newCompletedContents;
  final int totalContents;

  const ContentCompletionResult({
    this.moduleCompleted = false,
    this.pathCompleted = false,
    this.nextModuleUnlocked = false,
    this.newCompletedContents = 0,
    this.totalContents = 0,
  });

  double get progressPercent =>
      totalContents > 0 ? (newCompletedContents / totalContents).clamp(0.0, 1.0) : 0.0;
}
