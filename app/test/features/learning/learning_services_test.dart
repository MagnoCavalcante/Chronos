import 'package:chronos/features/learning/domain/entities/learning_entities.dart';
import 'package:chronos/features/learning/domain/repositories/learning_repository.dart';
import 'package:chronos/features/learning/services/achievements_service.dart';
import 'package:chronos/features/learning/services/goals_service.dart';
import 'package:chronos/features/learning/services/quiz_engine_service.dart';
import 'package:chronos/features/learning/services/spaced_repetition_service.dart';
import 'package:chronos/features/learning/services/stats_service.dart';
import 'package:chronos/features/learning/services/study_tracker_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock repository para testes dos serviços de Learning.
class MockLearningRepository implements LearningRepository {
  final List<StudyRecord> _records = [];
  final Map<String, StudyProgress> _progress = {};
  final List<ReviewSchedule> _reviews = [];
  final List<QuizQuestion> _questions = [];
  final List<QuizAnswer> _answers = [];
  final List<StudyGoal> _goals = [];
  final List<Achievement> _achievements = [];
  UserStudyStats? _stats;
  final List<StudyChallenge> _challenges = [];

  @override
  Future<void> recordActivity(StudyRecord record) async {
    _records.add(record);
  }

  @override
  Future<List<StudyRecord>> getHistory(String userId, {int limit = 50}) async {
    return _records.take(limit).toList();
  }

  @override
  Future<List<StudyRecord>> getRecentHistory(String userId, {int limit = 10}) async {
    return _records.take(limit).toList();
  }

  @override
  Future<StudyProgress?> getProgress(String userId, String entityId) async {
    return _progress[entityId];
  }

  @override
  Future<List<StudyProgress>> getAllProgress(String userId, {int limit = 50}) async {
    return _progress.values.take(limit).toList();
  }

  @override
  Future<List<StudyProgress>> getRecentProgress(String userId, {int limit = 5}) async {
    return _progress.values.take(limit).toList();
  }

  @override
  Future<void> upsertProgress(StudyProgress progress) async {
    _progress[progress.entityId] = progress;
  }

  @override
  Future<void> updateStatus(String userId, String entityId, StudyStatus status) async {
    final existing = _progress[entityId];
    if (existing != null) {
      _progress[entityId] = existing.copyWith(status: status);
    }
  }

  @override
  Future<List<ReviewSchedule>> getPendingReviews(String userId) async {
    return _reviews.where((r) => !r.completed).toList();
  }

  @override
  Future<void> scheduleReview(ReviewSchedule review) async {
    _reviews.add(review);
  }

  @override
  Future<void> completeReview(String reviewId) async {
    // Simular completar revisão
  }

  @override
  Future<List<QuizQuestion>> getQuizQuestions(String entityId, {int limit = 5}) async {
    return _questions.where((q) => q.entityId == entityId).take(limit).toList();
  }

  @override
  Future<void> saveQuizAnswer(QuizAnswer answer) async {
    _answers.add(answer);
  }

  @override
  Future<List<QuizAnswer>> getQuizHistory(String userId, {String? entityId}) async {
    if (entityId != null) {
      return _answers.where((a) => a.entityId == entityId).toList();
    }
    return _answers;
  }

  @override
  Future<List<StudyGoal>> getGoals(String userId) async {
    return _goals;
  }

  @override
  Future<void> createGoal(StudyGoal goal) async {
    _goals.add(goal);
  }

  @override
  Future<void> updateGoalProgress(String goalId, int currentValue) async {}

  @override
  Future<void> completeGoal(String goalId) async {}

  @override
  Future<List<Achievement>> getAchievements(String userId) async {
    return _achievements;
  }

  @override
  Future<void> upsertAchievement(Achievement achievement) async {
    _achievements.add(achievement);
  }

  @override
  Future<void> unlockAchievement(String userId, String code) async {}

  @override
  Future<UserStudyStats?> getStats(String userId) async {
    return _stats;
  }

  @override
  Future<void> updateStats(UserStudyStats stats) async {
    _stats = stats;
  }

  @override
  Future<List<StudyChallenge>> getActiveChallenges(String userId) async {
    return _challenges.where((c) => !c.completed).toList();
  }

  @override
  Future<void> createChallenge(StudyChallenge challenge) async {
    _challenges.add(challenge);
  }

  @override
  Future<void> updateChallengeProgress(String challengeId, int currentValue) async {}

  // Helpers para testes
  void addQuestion(QuizQuestion q) => _questions.add(q);
  void setStats(UserStudyStats s) => _stats = s;
}

void main() {
  group('StudyTrackerService', () {
    late MockLearningRepository repo;
    late StudyTrackerService tracker;

    setUp(() {
      repo = MockLearningRepository();
      tracker = StudyTrackerService(repository: repo);
    });

    test('recordView registra atividade e cria progresso', () async {
      await tracker.recordView('char_1', 'character', 'Cleópatra');
      final history = await repo.getHistory('local_user');
      expect(history, hasLength(1));
      expect(history.first.activityType, StudyActivityType.view);

      final progress = await repo.getProgress('local_user', 'char_1');
      expect(progress, isNotNull);
      expect(progress!.viewCount, 1);
      expect(progress.status, StudyStatus.inProgress);
    });

    test('recordView incrementa viewCount em progresso existente', () async {
      await tracker.recordView('char_1', 'character', 'Cleópatra');
      await tracker.recordView('char_1', 'character', 'Cleópatra');
      final progress = await repo.getProgress('local_user', 'char_1');
      expect(progress!.viewCount, 2);
    });

    test('startReading/stopReading registra duração', () async {
      tracker.startReading('char_1', 'character', 'César');
      expect(tracker.isTracking, isTrue);
      await tracker.stopReading();
      expect(tracker.isTracking, isFalse);
      final history = await repo.getHistory('local_user');
      expect(history, hasLength(1));
      expect(history.first.activityType, StudyActivityType.read);
    });

    test('markContent atualiza status', () async {
      await tracker.recordView('char_1', 'character', 'Test');
      await tracker.markContent('char_1', StudyStatus.mastered);
      final progress = await repo.getProgress('local_user', 'char_1');
      expect(progress!.status, StudyStatus.mastered);
    });

    test('getContinueFromWhereYouLeft retorna progresso recente', () async {
      await tracker.recordView('char_1', 'character', 'A');
      await tracker.recordView('char_2', 'character', 'B');
      final recent = await tracker.getContinueFromWhereYouLeft();
      expect(recent, hasLength(2));
    });
  });

  group('SpacedRepetitionService', () {
    late MockLearningRepository repo;
    late SpacedRepetitionService srs;

    setUp(() {
      repo = MockLearningRepository();
      srs = SpacedRepetitionService(repository: repo);
    });

    test('scheduleFirstReview cria revisão com 1 dia', () async {
      await srs.scheduleFirstReview(
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Cleópatra',
      );
      final reviews = await repo.getPendingReviews('local_user');
      expect(reviews, hasLength(1));
      expect(reviews.first.intervalDays, 1);
    });

    test('completeReview agenda próxima revisão', () async {
      final review = ReviewSchedule(
        id: 'rev1',
        userId: 'local_user',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Test',
        scheduledFor: DateTime.now(),
        intervalDays: 1,
        repetition: 0,
      );
      await srs.completeReview(review, quality: 4);
      // Deve ter agendado próxima revisão
      final pending = await repo.getPendingReviews('local_user');
      expect(pending, hasLength(1));
    });

    test('defaultIntervals contém 1, 3, 7, 15, 30', () {
      expect(SpacedRepetitionService.defaultIntervals, [1, 3, 7, 15, 30]);
    });
  });

  group('QuizEngineService', () {
    late MockLearningRepository repo;
    late QuizEngineService quiz;

    setUp(() {
      repo = MockLearningRepository();
      quiz = QuizEngineService(repository: repo);
      repo.addQuestion(const QuizQuestion(
        id: 'q1',
        entityId: 'char_cleo',
        entityType: 'character',
        question: 'Qual civilização ela governou?',
        options: ['Egito', 'Roma', 'Grécia', 'Pérsia'],
        correctIndex: 0,
      ));
    });

    test('getQuestions retorna perguntas', () async {
      final questions = await quiz.getQuestions('char_cleo');
      expect(questions, hasLength(1));
      expect(questions.first.question, contains('civilização'));
    });

    test('submitAnswer registra resposta correta', () async {
      final answer = await quiz.submitAnswer(
        questionId: 'q1',
        entityId: 'char_cleo',
        selectedIndex: 0,
        correctIndex: 0,
        responseTimeMs: 3000,
      );
      expect(answer.isCorrect, isTrue);
    });

    test('submitAnswer registra resposta errada', () async {
      final answer = await quiz.submitAnswer(
        questionId: 'q1',
        entityId: 'char_cleo',
        selectedIndex: 2,
        correctIndex: 0,
        responseTimeMs: 5000,
      );
      expect(answer.isCorrect, isFalse);
    });

    test('getEntityQuizStats calcula accuracy', () async {
      await quiz.submitAnswer(
        questionId: 'q1', entityId: 'char_cleo',
        selectedIndex: 0, correctIndex: 0, responseTimeMs: 1000,
      );
      await quiz.submitAnswer(
        questionId: 'q1', entityId: 'char_cleo',
        selectedIndex: 1, correctIndex: 0, responseTimeMs: 1000,
      );
      final stats = await quiz.getEntityQuizStats('char_cleo');
      expect(stats.totalAnswered, 2);
      expect(stats.totalCorrect, 1);
      expect(stats.accuracy, 0.5);
    });
  });

  group('GoalsService', () {
    late MockLearningRepository repo;
    late GoalsService goals;

    setUp(() {
      repo = MockLearningRepository();
      goals = GoalsService(repository: repo);
    });

    test('createGoal adiciona meta', () async {
      await goals.createGoal(
        title: 'Estudar 20 minutos',
        type: GoalType.dailyMinutes,
        targetValue: 20,
      );
      final all = await goals.getGoals();
      expect(all, hasLength(1));
      expect(all.first.title, 'Estudar 20 minutos');
    });

    test('createDefaultGoals cria metas padrão', () async {
      await goals.createDefaultGoals();
      final all = await goals.getGoals();
      expect(all, hasLength(3));
    });

    test('createDefaultGoals não duplica', () async {
      await goals.createDefaultGoals();
      await goals.createDefaultGoals();
      final all = await goals.getGoals();
      expect(all, hasLength(3));
    });
  });

  group('AchievementsService', () {
    late MockLearningRepository repo;
    late AchievementsService achievements;

    setUp(() {
      repo = MockLearningRepository();
      achievements = AchievementsService(repository: repo);
    });

    test('calculateLevel retorna nível correto', () {
      expect(achievements.calculateLevel(0), UserLevel.novice);
      expect(achievements.calculateLevel(99), UserLevel.novice);
      expect(achievements.calculateLevel(100), UserLevel.apprentice);
      expect(achievements.calculateLevel(500), UserLevel.scholar);
      expect(achievements.calculateLevel(1500), UserLevel.historian);
      expect(achievements.calculateLevel(4000), UserLevel.master);
      expect(achievements.calculateLevel(10000), UserLevel.grandMaster);
    });

    test('calculateLevelProgress retorna progresso', () {
      final progress = achievements.calculateLevelProgress(300);
      // 300 XP, apprentice (100-499), progress = (300-100)/(500-100) = 0.5
      expect(progress, closeTo(0.5, 0.01));
    });

    test('xpPerActivity está configurado', () {
      expect(AchievementsService.xpPerActivity[StudyActivityType.read], 15);
      expect(AchievementsService.xpPerActivity[StudyActivityType.quiz], 20);
    });
  });

  group('StatsService', () {
    late MockLearningRepository repo;
    late StatsService stats;

    setUp(() {
      repo = MockLearningRepository();
      stats = StatsService(repository: repo);
    });

    test('getStats retorna stats default quando não existe', () async {
      final result = await stats.getStats();
      expect(result.userId, 'local_user');
      expect(result.totalStudyTimeSeconds, 0);
    });

    test('recordStudySession atualiza tempo e contadores', () async {
      await stats.recordStudySession(entityType: 'character', durationSeconds: 120);
      final result = await stats.getStats();
      expect(result.totalStudyTimeSeconds, 120);
      expect(result.totalCharactersStudied, 1);
      expect(result.consecutiveDays, 1);
    });

    test('recordQuizResult atualiza contadores de quiz', () async {
      repo.setStats(const UserStudyStats(userId: 'local_user'));
      await stats.recordQuizResult(isCorrect: true);
      final result = await stats.getStats();
      expect(result.totalQuizAnswered, 1);
      expect(result.totalQuizCorrect, 1);
    });

    test('getFavoriteHour retorna hora mais estudada', () {
      const s = UserStudyStats(
        userId: 'u1',
        hourlyDistribution: {10: 5, 14: 8, 20: 3},
      );
      expect(stats.getFavoriteHour(s), 14);
    });
  });
}
