import '../../domain/entities/learning_path_entities.dart';
import '../../domain/repositories/learning_paths_repository.dart';
import '../datasources/learning_paths_remote_datasource.dart';

/// Implementação do repositório de Learning Paths.
class LearningPathsRepositoryImpl implements LearningPathsRepository {
  final LearningPathsRemoteDataSource _remote;

  LearningPathsRepositoryImpl({required LearningPathsRemoteDataSource remote}) : _remote = remote;

  @override
  Future<List<LearningPath>> getAllPaths({PathCategory? category, PathDifficulty? difficulty}) async {
    final data = await _remote.fetchAllPaths(
      category: category?.name,
      difficulty: difficulty?.name,
    );
    return data.map(LearningPath.fromJson).toList();
  }

  @override
  Future<LearningPath?> getPath(String pathId) async {
    final data = await _remote.fetchPath(pathId);
    if (data == null) return null;
    final path = LearningPath.fromJson(data);
    final modules = await getModules(pathId);
    return LearningPath(
      id: path.id,
      name: path.name,
      description: path.description,
      imageUrl: path.imageUrl,
      category: path.category,
      difficulty: path.difficulty,
      estimatedMinutes: path.estimatedMinutes,
      totalModules: path.totalModules,
      totalContents: path.totalContents,
      xpReward: path.xpReward,
      badgeCode: path.badgeCode,
      authorId: path.authorId,
      authorName: path.authorName,
      isPremium: path.isPremium,
      locale: path.locale,
      order: path.order,
      createdAt: path.createdAt,
      modules: modules,
    );
  }

  @override
  Future<List<LearningPath>> searchPaths(String query) async {
    final data = await _remote.searchPaths(query);
    return data.map(LearningPath.fromJson).toList();
  }

  @override
  Future<List<PathModule>> getModules(String pathId) async {
    final data = await _remote.fetchModules(pathId);
    final modules = <PathModule>[];
    for (final m in data) {
      final moduleId = m['id'] as String;
      final contents = await getModuleContents(moduleId);
      modules.add(PathModule(
        id: moduleId,
        pathId: m['path_id'] as String? ?? '',
        title: m['title'] as String? ?? '',
        description: m['description'] as String?,
        order: m['order'] as int? ?? 0,
        totalContents: m['total_contents'] as int? ?? contents.length,
        contents: contents,
      ));
    }
    return modules;
  }

  @override
  Future<List<PathContent>> getModuleContents(String moduleId) async {
    final data = await _remote.fetchModuleContents(moduleId);
    return data.map(PathContent.fromJson).toList();
  }

  @override
  Future<PathProgress?> getPathProgress(String userId, String pathId) async {
    final data = await _remote.fetchPathProgress(userId, pathId);
    if (data == null) return null;
    return PathProgress.fromJson(data);
  }

  @override
  Future<List<PathProgress>> getUserPaths(String userId) async {
    final data = await _remote.fetchUserPaths(userId);
    return data.map(PathProgress.fromJson).toList();
  }

  @override
  Future<List<PathProgress>> getInProgressPaths(String userId) async {
    final all = await getUserPaths(userId);
    return all.where((p) => p.status == PathStatus.inProgress).toList();
  }

  @override
  Future<List<PathProgress>> getCompletedPaths(String userId) async {
    final all = await getUserPaths(userId);
    return all.where((p) => p.status == PathStatus.completed).toList();
  }

  @override
  Future<void> upsertPathProgress(PathProgress progress) async {
    await _remote.upsertPathProgress(progress.toJson());
  }

  @override
  Future<ModuleProgress?> getModuleProgress(String userId, String moduleId) async {
    final data = await _remote.fetchModuleProgress(userId, moduleId);
    if (data == null) return null;
    return ModuleProgress.fromJson(data);
  }

  @override
  Future<List<ModuleProgress>> getPathModuleProgress(String userId, String pathId) async {
    final data = await _remote.fetchPathModuleProgress(userId, pathId);
    return data.map(ModuleProgress.fromJson).toList();
  }

  @override
  Future<void> upsertModuleProgress(ModuleProgress progress) async {
    await _remote.upsertModuleProgress(progress.toJson());
  }

  @override
  Future<List<PathCertificate>> getCertificates(String userId) async {
    final data = await _remote.fetchCertificates(userId);
    return data.map(PathCertificate.fromJson).toList();
  }

  @override
  Future<void> issueCertificate(PathCertificate certificate) async {
    await _remote.insertCertificate(certificate.toJson()..remove('id'));
  }
}
