import '../../domain/entities/learning_entities.dart';
import '../../domain/repositories/learning_repository.dart';
import '../datasources/learning_remote_datasource.dart';

/// Implementação do repositório da Learning Engine.
class LearningRepositoryImpl implements LearningRepository {
  final LearningRemoteDataSource _remote;

  LearningRepositoryImpl({required LearningRemoteDataSource remote}) : _remote = remote;

  @override
  Future<void> recordActivity(StudyRecord record) async {
    await _remote.insertRecord(record.toJson()..remove('id'));
  }

  @override
  Future<List<StudyRecord>> getHistory(String userId, {int limit = 50}) async {
    final data = await _remote.fetchHistory(userId, limit: limit);
    return data.map(StudyRecord.fromJson).toList();
  }

  @override
  Future<List<StudyRecord>> getRecentHistory(String userId, {int limit = 10}) async {
    return getHistory(userId, limit: limit);
  }

  @override
  Future<StudyProgress?> getProgress(String userId, String entityId) async {
    final data = await _remote.fetchProgress(userId, entityId);
    if (data == null) return null;
    return StudyProgress.fromJson(data);
  }

  @override
  Future<List<StudyProgress>> getAllProgress(String userId, {int limit = 50}) async {
    final data = await _remote.fetchAllProgress(userId, limit: limit);
    return data.map(StudyProgress.fromJson).toList();
  }

  @override
  Future<List<StudyProgress>> getRecentProgress(String userId, {int limit = 5}) async {
    final data = await _remote.fetchAllProgress(userId, limit: limit);
    return data.map(StudyProgress.fromJson).toList();
  }

  @override
  Future<void> upsertProgress(StudyProgress progress) async {
    await _remote.upsertProgress(progress.toJson());
  }

  @override
  Future<void> updateStatus(String userId, String entityId, StudyStatus status) async {
    final existing = await getProgress(userId, entityId);
    if (existing != null) {
      await upsertProgress(existing.copyWith(status: status));
    }
  }

  @override
  Future<List<ReviewSchedule>> getPendingReviews(String userId) async {
    final data = await _remote.fetchPendingReviews(userId);
    return data.map(ReviewSchedule.fromJson).toList();
  }

  @override
  Future<void> scheduleReview(ReviewSchedule review) async {
    await _remote.insertReview(review.toJson()..remove('id'));
  }

  @override
  Future<void> completeReview(String reviewId) async {
    await _remote.completeReview(reviewId);
  }

  @override
  Future<List<QuizQuestion>> getQuizQuestions(String entityId, {int limit = 5}) async {
    final data = await _remote.fetchQuizQuestions(entityId, limit: limit);
    return data.map(QuizQuestion.fromJson).toList();
  }

  @override
  Future<void> saveQuizAnswer(QuizAnswer answer) async {
    await _remote.insertQuizAnswer(answer.toJson()..remove('id'));
  }

  @override
  Future<List<QuizAnswer>> getQuizHistory(String userId, {String? entityId}) async {
    final data = await _remote.fetchQuizHistory(userId, entityId: entityId);
    return data.map(QuizAnswer.fromJson).toList();
  }

  @override
  Future<List<StudyGoal>> getGoals(String userId) async {
    final data = await _remote.fetchGoals(userId);
    return data.map(StudyGoal.fromJson).toList();
  }

  @override
  Future<void> createGoal(StudyGoal goal) async {
    await _remote.insertGoal(goal.toJson()..remove('id'));
  }

  @override
  Future<void> updateGoalProgress(String goalId, int currentValue) async {
    await _remote.updateGoal(goalId, {'current_value': currentValue});
  }

  @override
  Future<void> completeGoal(String goalId) async {
    await _remote.updateGoal(goalId, {
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Achievement>> getAchievements(String userId) async {
    final data = await _remote.fetchAchievements(userId);
    return data.map(Achievement.fromJson).toList();
  }

  @override
  Future<void> upsertAchievement(Achievement achievement) async {
    await _remote.upsertAchievement(achievement.toJson());
  }

  @override
  Future<void> unlockAchievement(String userId, String code) async {
    await _remote.upsertAchievement({
      'user_id': userId,
      'code': code,
      'unlocked': true,
      'unlocked_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<UserStudyStats?> getStats(String userId) async {
    final data = await _remote.fetchStats(userId);
    if (data == null) return null;
    return UserStudyStats.fromJson(data);
  }

  @override
  Future<void> updateStats(UserStudyStats stats) async {
    await _remote.upsertStats(stats.toJson());
  }

  @override
  Future<List<StudyChallenge>> getActiveChallenges(String userId) async {
    final data = await _remote.fetchActiveChallenges(userId);
    return data.map(StudyChallenge.fromJson).toList();
  }

  @override
  Future<void> createChallenge(StudyChallenge challenge) async {
    await _remote.insertChallenge(challenge.toJson()..remove('id'));
  }

  @override
  Future<void> updateChallengeProgress(String challengeId, int currentValue) async {
    await _remote.updateChallenge(challengeId, {'current_value': currentValue});
  }
}
