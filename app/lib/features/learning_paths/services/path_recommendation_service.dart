import '../domain/entities/learning_path_entities.dart';
import '../domain/repositories/learning_paths_repository.dart';

/// Serviço de Recomendações de Trilhas.
///
/// Sugere trilhas baseado no histórico e trilhas concluídas.
class PathRecommendationService {
  final LearningPathsRepository _repository;
  final String _userId;

  /// Mapeamento de trilhas relacionadas por categoria.
  static const Map<PathCategory, List<PathCategory>> _relatedCategories = {
    PathCategory.antiquity: [PathCategory.civilizations, PathCategory.empires, PathCategory.philosophy],
    PathCategory.civilizations: [PathCategory.antiquity, PathCategory.empires, PathCategory.greatWars],
    PathCategory.empires: [PathCategory.civilizations, PathCategory.greatWars, PathCategory.middleAges],
    PathCategory.middleAges: [PathCategory.empires, PathCategory.religions, PathCategory.modernAge],
    PathCategory.modernAge: [PathCategory.contemporaryAge, PathCategory.philosophy, PathCategory.arts],
    PathCategory.contemporaryAge: [PathCategory.greatWars, PathCategory.science, PathCategory.brazilHistory],
    PathCategory.greatWars: [PathCategory.contemporaryAge, PathCategory.empires, PathCategory.civilizations],
    PathCategory.philosophy: [PathCategory.antiquity, PathCategory.arts, PathCategory.religions],
    PathCategory.religions: [PathCategory.middleAges, PathCategory.philosophy, PathCategory.civilizations],
    PathCategory.brazilHistory: [PathCategory.contemporaryAge, PathCategory.modernAge],
    PathCategory.science: [PathCategory.contemporaryAge, PathCategory.modernAge],
    PathCategory.arts: [PathCategory.modernAge, PathCategory.philosophy],
  };

  PathRecommendationService({
    required LearningPathsRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Obtém recomendações baseadas nas trilhas concluídas.
  Future<List<LearningPath>> getRecommendations({int limit = 5}) async {
    final completedPaths = await _repository.getCompletedPaths(_userId);
    final inProgressPaths = await _repository.getInProgressPaths(_userId);
    final excludeIds = <String>{
      ...completedPaths.map((p) => p.pathId),
      ...inProgressPaths.map((p) => p.pathId),
    };

    if (completedPaths.isEmpty && inProgressPaths.isEmpty) {
      // Sem histórico: recomendar trilhas populares/iniciantes
      final all = await _repository.getAllPaths(difficulty: PathDifficulty.beginner);
      return all.take(limit).toList();
    }

    // Determinar categorias estudadas
    final studiedCategories = <PathCategory>{};
    final allPaths = await _repository.getAllPaths();
    for (final progress in [...completedPaths, ...inProgressPaths]) {
      final path = allPaths.firstWhere(
        (p) => p.id == progress.pathId,
        orElse: () => LearningPath(id: '', name: '', description: '', category: PathCategory.antiquity, createdAt: DateTime.now()),
      );
      if (path.id.isNotEmpty) studiedCategories.add(path.category);
    }

    // Buscar trilhas de categorias relacionadas
    final recommendedCategories = <PathCategory>{};
    for (final cat in studiedCategories) {
      final related = _relatedCategories[cat] ?? [];
      recommendedCategories.addAll(related);
    }

    final recommendations = <LearningPath>[];
    for (final path in allPaths) {
      if (excludeIds.contains(path.id)) continue;
      if (recommendedCategories.contains(path.category)) {
        recommendations.add(path);
        if (recommendations.length >= limit) break;
      }
    }

    // Se poucas recomendações, completar com outras não estudadas
    if (recommendations.length < limit) {
      for (final path in allPaths) {
        if (excludeIds.contains(path.id)) continue;
        if (!recommendations.contains(path)) {
          recommendations.add(path);
          if (recommendations.length >= limit) break;
        }
      }
    }

    return recommendations;
  }

  /// Gera texto de razão da recomendação.
  String getRecommendationReason(LearningPath recommended, List<PathProgress> completed) {
    if (completed.isEmpty) return 'Trilha recomendada para iniciantes';
    return 'Como você concluiu ${completed.last.pathName}...';
  }
}
