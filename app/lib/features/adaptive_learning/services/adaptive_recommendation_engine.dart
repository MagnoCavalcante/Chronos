import '../../learning/domain/entities/learning_entities.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../../learning_paths/domain/repositories/learning_paths_repository.dart';
import '../domain/entities/adaptive_learning_entities.dart';
import '../domain/repositories/adaptive_learning_repository.dart';

/// Motor de Recomendações Adaptativas (desacoplado, ML-ready).
///
/// Implementa RecommendationStrategy para permitir futura substituição
/// por modelos de machine learning sem alterar o restante da aplicação.
///
/// Toda recomendação possui um motivo explícito (explainability).
class AdaptiveRecommendationEngine implements RecommendationStrategy {
  final AdaptiveLearningRepository _adaptiveRepo;
  final LearningRepository _learningRepo;
  final LearningPathsRepository _pathsRepo;
  final String _userId;

  /// Cache de recomendações (performance).
  List<AdaptiveRecommendation>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 15);

  AdaptiveRecommendationEngine({
    required AdaptiveLearningRepository adaptiveRepository,
    required LearningRepository learningRepository,
    required LearningPathsRepository pathsRepository,
    String userId = 'local_user',
  })  : _adaptiveRepo = adaptiveRepository,
        _learningRepo = learningRepository,
        _pathsRepo = pathsRepository,
        _userId = userId;

  @override
  Future<List<AdaptiveRecommendation>> generateRecommendations({
    required LearnerProfile profile,
    int limit = 10,
  }) async {
    // Check cache
    if (_cache != null && _cacheTime != null && DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!.take(limit).toList();
    }

    final recommendations = <AdaptiveRecommendation>[];

    // 1. Revisões pendentes (highest priority)
    await _addReviewRecommendations(recommendations, profile);

    // 2. Dificuldades (help user improve)
    await _addDifficultyRecommendations(recommendations, profile);

    // 3. Trilhas em andamento (continue learning)
    await _addPathRecommendations(recommendations, profile);

    // 4. Conteúdo novo baseado em favoritos
    await _addNewContentRecommendations(recommendations, profile);

    // Ordenar por prioridade + score
    recommendations.sort((a, b) {
      final pc = b.priority.compareTo(a.priority);
      if (pc != 0) return pc;
      return b.score.compareTo(a.score);
    });

    final result = recommendations.take(limit).toList();

    // Persist
    await _adaptiveRepo.clearRecommendations(_userId);
    await _adaptiveRepo.saveRecommendations(result);

    // Update cache
    _cache = result;
    _cacheTime = DateTime.now();

    return result;
  }

  /// Obtém recomendações (do cache/DB ou gera novas).
  Future<List<AdaptiveRecommendation>> getRecommendations({int limit = 10}) async {
    // Check cache
    if (_cache != null && _cacheTime != null && DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!.take(limit).toList();
    }

    final stored = await _adaptiveRepo.getRecommendations(_userId, limit: limit);
    if (stored.isNotEmpty) {
      _cache = stored;
      _cacheTime = DateTime.now();
      return stored;
    }

    // No stored recs, need profile to generate
    final profile = await _adaptiveRepo.getProfile(_userId);
    if (profile == null) return [];
    return generateRecommendations(profile: profile, limit: limit);
  }

  /// Invalida o cache.
  void invalidateCache() {
    _cache = null;
    _cacheTime = null;
  }

  Future<void> _addReviewRecommendations(List<AdaptiveRecommendation> recs, LearnerProfile profile) async {
    final reviews = await _learningRepo.getPendingReviews(_userId);
    for (final review in reviews.take(3)) {
      recs.add(AdaptiveRecommendation(
        id: '',
        userId: _userId,
        entityId: review.entityId,
        entityType: review.entityType,
        entityName: review.entityName,
        type: RecommendationType.review,
        reason: 'Revisão programada para hoje (repetição espaçada, intervalo: ${review.intervalDays} dias).',
        score: 1.0,
        priority: 10,
        generatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _addDifficultyRecommendations(List<AdaptiveRecommendation> recs, LearnerProfile profile) async {
    for (final topic in profile.difficultTopics.take(2)) {
      final accuracy = profile.topicAccuracy[topic] ?? 0.0;
      recs.add(AdaptiveRecommendation(
        id: '',
        userId: _userId,
        entityId: topic,
        entityType: 'topic',
        entityName: topic,
        type: RecommendationType.difficultyBased,
        reason: 'Recomendado porque teve dificuldade neste tema '
            '(taxa de acerto: ${(accuracy * 100).toStringAsFixed(0)}%).',
        score: 0.9 - accuracy,
        priority: 8,
        generatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _addPathRecommendations(List<AdaptiveRecommendation> recs, LearnerProfile profile) async {
    final inProgress = await _pathsRepo.getInProgressPaths(_userId);
    for (final pp in inProgress.take(2)) {
      recs.add(AdaptiveRecommendation(
        id: '',
        userId: _userId,
        entityId: pp.pathId,
        entityType: 'learning_path',
        entityName: pp.pathName,
        type: RecommendationType.pathBased,
        reason: 'Continue sua trilha "${pp.pathName}" '
            '(${(pp.progressPercent * 100).toStringAsFixed(0)}% concluído).',
        score: 0.7,
        priority: 6,
        generatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _addNewContentRecommendations(List<AdaptiveRecommendation> recs, LearnerProfile profile) async {
    final history = await _learningRepo.getRecentHistory(_userId, limit: 5);
    if (history.isEmpty) return;

    final lastStudied = history.first;
    recs.add(AdaptiveRecommendation(
      id: '',
      userId: _userId,
      entityId: lastStudied.entityId,
      entityType: lastStudied.entityType,
      entityName: lastStudied.entityName,
      type: RecommendationType.relatedContent,
      reason: 'Recomendado porque você estudou recentemente "${lastStudied.entityName}".',
      score: 0.5,
      priority: 4,
      generatedAt: DateTime.now(),
    ));
  }
}
