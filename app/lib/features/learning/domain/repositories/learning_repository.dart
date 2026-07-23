import '../entities/learning_entities.dart';

/// Contrato do repositório da Learning Engine.
abstract class LearningRepository {
  // Histórico
  Future<void> recordActivity(StudyRecord record);
  Future<List<StudyRecord>> getHistory(String userId, {int limit = 50});
  Future<List<StudyRecord>> getRecentHistory(String userId, {int limit = 10});

  // Progresso
  Future<StudyProgress?> getProgress(String userId, String entityId);
  Future<List<StudyProgress>> getAllProgress(String userId, {int limit = 50});
  Future<List<StudyProgress>> getRecentProgress(String userId, {int limit = 5});
  Future<void> upsertProgress(StudyProgress progress);
  Future<void> updateStatus(String userId, String entityId, StudyStatus status);

  // Revisões
  Future<List<ReviewSchedule>> getPendingReviews(String userId);
  Future<void> scheduleReview(ReviewSchedule review);
  Future<void> completeReview(String reviewId);

  // Quiz
  Future<List<QuizQuestion>> getQuizQuestions(String entityId, {int limit = 5});
  Future<void> saveQuizAnswer(QuizAnswer answer);
  Future<List<QuizAnswer>> getQuizHistory(String userId, {String? entityId});

  // Metas
  Future<List<StudyGoal>> getGoals(String userId);
  Future<void> createGoal(StudyGoal goal);
  Future<void> updateGoalProgress(String goalId, int currentValue);
  Future<void> completeGoal(String goalId);

  // Conquistas
  Future<List<Achievement>> getAchievements(String userId);
  Future<void> upsertAchievement(Achievement achievement);
  Future<void> unlockAchievement(String userId, String code);

  // Estatísticas
  Future<UserStudyStats?> getStats(String userId);
  Future<void> updateStats(UserStudyStats stats);

  // Desafios
  Future<List<StudyChallenge>> getActiveChallenges(String userId);
  Future<void> createChallenge(StudyChallenge challenge);
  Future<void> updateChallengeProgress(String challengeId, int currentValue);
}
