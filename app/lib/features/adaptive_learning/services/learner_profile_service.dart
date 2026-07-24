import '../../learning/domain/entities/learning_entities.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../domain/entities/adaptive_learning_entities.dart';
import '../domain/repositories/adaptive_learning_repository.dart';

/// Serviço de Perfil de Aprendizagem.
///
/// Atualiza automaticamente o perfil após cada interação.
/// Perfil versionado para evolução sem perder dados.
class LearnerProfileService {
  final AdaptiveLearningRepository _repository;
  final LearningRepository _learningRepo;
  final String _userId;

  LearnerProfileService({
    required AdaptiveLearningRepository repository,
    required LearningRepository learningRepository,
    String userId = 'local_user',
  })  : _repository = repository,
        _learningRepo = learningRepository,
        _userId = userId;

  /// Obtém o perfil atual (ou cria padrão).
  Future<LearnerProfile> getProfile() async {
    final existing = await _repository.getProfile(_userId);
    if (existing != null) return existing;
    final newProfile = LearnerProfile(
      id: '',
      userId: _userId,
      lastUpdatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _repository.upsertProfile(newProfile);
    return newProfile;
  }

  /// Atualiza o perfil com base nos dados mais recentes do Learning Engine.
  Future<LearnerProfile> refreshProfile() async {
    final current = await getProfile();
    final stats = await _learningRepo.getStats(_userId);
    final quizHistory = await _learningRepo.getQuizHistory(_userId);
    final history = await _learningRepo.getHistory(_userId, limit: 100);

    // Calcular taxa de acerto
    final totalQuiz = quizHistory.length;
    final correctQuiz = quizHistory.where((a) => a.isCorrect).length;
    final accuracy = totalQuiz > 0 ? correctQuiz / totalQuiz : 0.0;

    // Calcular tempo médio por conteúdo
    final readActivities = history.where((r) => r.activityType == StudyActivityType.read);
    final avgTime = readActivities.isNotEmpty
        ? readActivities.map((r) => r.durationSeconds).reduce((a, b) => a + b) / readActivities.length
        : 600.0;

    // Estimar nível
    final level = _estimateLevel(accuracy, totalQuiz, stats?.totalStudyTimeSeconds ?? 0);

    // Detectar tópicos dominados/difíceis
    final topicAccuracy = _calculateTopicAccuracy(quizHistory);
    final mastered = topicAccuracy.entries.where((e) => e.value >= 0.8).map((e) => e.key).toList();
    final difficult = topicAccuracy.entries.where((e) => e.value < 0.5).map((e) => e.key).toList();

    // Detectar favoritos (mais estudados)
    final topicCounts = <String, int>{};
    for (final r in history) {
      topicCounts[r.entityType] = (topicCounts[r.entityType] ?? 0) + 1;
    }
    final favorites = (topicCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => e.key)
        .toList();

    final updated = current.copyWith(
      estimatedLevel: level,
      quizAccuracyRate: accuracy,
      averageTimePerContentSeconds: avgTime,
      masteredTopics: mastered,
      difficultTopics: difficult,
      favoriteTopics: favorites,
      topicAccuracy: topicAccuracy,
      lastUpdatedAt: DateTime.now(),
    );

    await _repository.upsertProfile(updated);
    return updated;
  }

  /// Atualiza objetivo e tempo disponível.
  Future<LearnerProfile> updatePreferences({
    StudyObjective? objective,
    int? availableMinutesPerDay,
    List<ContentFormatPreference>? formatPreferences,
  }) async {
    final current = await getProfile();
    final updated = current.copyWith(
      primaryObjective: objective,
      availableMinutesPerDay: availableMinutesPerDay,
      formatPreferences: formatPreferences,
      lastUpdatedAt: DateTime.now(),
    );
    await _repository.upsertProfile(updated);
    return updated;
  }

  LearnerLevel _estimateLevel(double accuracy, int totalQuiz, int totalStudyTimeSec) {
    if (totalQuiz < 10 && totalStudyTimeSec < 3600) return LearnerLevel.beginner;
    if (accuracy >= 0.75 && totalQuiz >= 50) return LearnerLevel.advanced;
    if (accuracy >= 0.5 || totalQuiz >= 20) return LearnerLevel.intermediate;
    return LearnerLevel.beginner;
  }

  Map<String, double> _calculateTopicAccuracy(List<QuizAnswer> answers) {
    final topicCorrect = <String, int>{};
    final topicTotal = <String, int>{};
    for (final a in answers) {
      topicTotal[a.entityId] = (topicTotal[a.entityId] ?? 0) + 1;
      if (a.isCorrect) topicCorrect[a.entityId] = (topicCorrect[a.entityId] ?? 0) + 1;
    }
    return topicTotal.map((k, v) => MapEntry(k, (topicCorrect[k] ?? 0) / v));
  }
}
