import 'package:chronos/features/adaptive_learning/domain/entities/adaptive_learning_entities.dart';
import 'package:chronos/features/adaptive_learning/domain/repositories/adaptive_learning_repository.dart';
import 'package:chronos/features/adaptive_learning/services/adaptive_quiz_service.dart';
import 'package:chronos/features/adaptive_learning/services/adaptive_recommendation_engine.dart';
import 'package:chronos/features/adaptive_learning/services/difficulty_detection_service.dart';
import 'package:chronos/features/adaptive_learning/services/learner_profile_service.dart';
import 'package:chronos/features/adaptive_learning/services/learning_report_service.dart';
import 'package:chronos/features/adaptive_learning/services/privacy_service.dart';
import 'package:chronos/features/adaptive_learning/services/study_plan_service.dart';
import 'package:chronos/features/adaptive_learning/services/tutor_service.dart';
import 'package:chronos/features/learning/domain/entities/learning_entities.dart';
import 'package:chronos/features/learning/domain/repositories/learning_repository.dart';
import 'package:chronos/features/learning_paths/domain/entities/learning_path_entities.dart';
import 'package:chronos/features/learning_paths/domain/repositories/learning_paths_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================
// Mocks
// ============================================================

class MockAdaptiveLearningRepository implements AdaptiveLearningRepository {
  LearnerProfile? _profile;
  final List<AdaptiveRecommendation> _recs = [];
  StudyPlan? _plan;
  final List<LearningReport> _reports = [];
  bool _deleted = false;

  @override
  Future<LearnerProfile?> getProfile(String userId) async => _profile;
  @override
  Future<void> upsertProfile(LearnerProfile profile) async => _profile = profile;
  @override
  Future<List<LearnerProfile>> getProfileHistory(String userId) async => _profile != null ? [_profile!] : [];
  @override
  Future<List<AdaptiveRecommendation>> getRecommendations(String userId, {int limit = 10}) async =>
      _recs.where((r) => !r.dismissed).take(limit).toList();
  @override
  Future<void> saveRecommendations(List<AdaptiveRecommendation> recommendations) async =>
      _recs.addAll(recommendations);
  @override
  Future<void> dismissRecommendation(String recommendationId) async {}
  @override
  Future<void> clearRecommendations(String userId) async => _recs.clear();
  @override
  Future<StudyPlan?> getCurrentPlan(String userId) async => _plan;
  @override
  Future<void> savePlan(StudyPlan plan) async => _plan = plan;
  @override
  Future<List<StudyPlan>> getPlanHistory(String userId, {int limit = 10}) async => _plan != null ? [_plan!] : [];
  @override
  Future<LearningReport?> getLatestReport(String userId, ReportPeriod period) async =>
      _reports.isNotEmpty ? _reports.last : null;
  @override
  Future<void> saveReport(LearningReport report) async => _reports.add(report);
  @override
  Future<List<LearningReport>> getReports(String userId, {int limit = 10}) async => _reports;
  @override
  Future<Map<String, dynamic>> exportAllData(String userId) async => {'exported': true};
  @override
  Future<void> deleteAllData(String userId) async => _deleted = true;

  bool get wasDeleted => _deleted;
}

class MockLearningRepository implements LearningRepository {
  final List<StudyRecord> _records = [];
  final List<QuizAnswer> _answers = [];
  final List<ReviewSchedule> _reviews = [];
  final List<StudyProgress> _progress = [];
  UserStudyStats? _stats;

  void addAnswer(QuizAnswer a) => _answers.add(a);
  void addReview(ReviewSchedule r) => _reviews.add(r);
  void addProgress(StudyProgress p) => _progress.add(p);
  void addRecord(StudyRecord r) => _records.add(r);

  @override
  Future<void> recordActivity(StudyRecord record) async => _records.add(record);
  @override
  Future<List<StudyRecord>> getHistory(String userId, {int limit = 50}) async => _records.take(limit).toList();
  @override
  Future<List<StudyRecord>> getRecentHistory(String userId, {int limit = 10}) async => _records.take(limit).toList();
  @override
  Future<StudyProgress?> getProgress(String userId, String entityId) async => null;
  @override
  Future<List<StudyProgress>> getAllProgress(String userId, {int limit = 50}) async => _progress;
  @override
  Future<List<StudyProgress>> getRecentProgress(String userId, {int limit = 5}) async => _progress.take(limit).toList();
  @override
  Future<void> upsertProgress(StudyProgress progress) async {}
  @override
  Future<void> updateStatus(String userId, String entityId, StudyStatus status) async {}
  @override
  Future<List<ReviewSchedule>> getPendingReviews(String userId) async => _reviews;
  @override
  Future<void> scheduleReview(ReviewSchedule review) async {}
  @override
  Future<void> completeReview(String reviewId) async {}
  @override
  Future<List<QuizQuestion>> getQuizQuestions(String entityId, {int limit = 5}) async => [];
  @override
  Future<void> saveQuizAnswer(QuizAnswer answer) async {}
  @override
  Future<List<QuizAnswer>> getQuizHistory(String userId, {String? entityId}) async {
    if (entityId != null) return _answers.where((a) => a.entityId == entityId).toList();
    return _answers;
  }
  @override
  Future<List<StudyGoal>> getGoals(String userId) async => [];
  @override
  Future<void> createGoal(StudyGoal goal) async {}
  @override
  Future<void> updateGoalProgress(String goalId, int currentValue) async {}
  @override
  Future<void> completeGoal(String goalId) async {}
  @override
  Future<List<Achievement>> getAchievements(String userId) async => [];
  @override
  Future<void> upsertAchievement(Achievement achievement) async {}
  @override
  Future<void> unlockAchievement(String userId, String code) async {}
  @override
  Future<UserStudyStats?> getStats(String userId) async => _stats;
  @override
  Future<void> updateStats(UserStudyStats stats) async {}
  @override
  Future<List<StudyChallenge>> getActiveChallenges(String userId) async => [];
  @override
  Future<void> createChallenge(StudyChallenge challenge) async {}
  @override
  Future<void> updateChallengeProgress(String challengeId, int currentValue) async {}
}

class MockLearningPathsRepository implements LearningPathsRepository {
  @override
  Future<List<LearningPath>> getAllPaths({PathCategory? category, PathDifficulty? difficulty}) async => [];
  @override
  Future<LearningPath?> getPath(String pathId) async => null;
  @override
  Future<List<LearningPath>> searchPaths(String query) async => [];
  @override
  Future<List<PathModule>> getModules(String pathId) async => [];
  @override
  Future<List<PathContent>> getModuleContents(String moduleId) async => [];
  @override
  Future<PathProgress?> getPathProgress(String userId, String pathId) async => null;
  @override
  Future<List<PathProgress>> getUserPaths(String userId) async => [];
  @override
  Future<List<PathProgress>> getInProgressPaths(String userId) async => [];
  @override
  Future<List<PathProgress>> getCompletedPaths(String userId) async => [];
  @override
  Future<void> upsertPathProgress(PathProgress progress) async {}
  @override
  Future<ModuleProgress?> getModuleProgress(String userId, String moduleId) async => null;
  @override
  Future<List<ModuleProgress>> getPathModuleProgress(String userId, String pathId) async => [];
  @override
  Future<void> upsertModuleProgress(ModuleProgress progress) async {}
  @override
  Future<List<PathCertificate>> getCertificates(String userId) async => [];
  @override
  Future<void> issueCertificate(PathCertificate certificate) async {}
}

// ============================================================
// Tests
// ============================================================

void main() {
  group('LearnerProfile Entity', () {
    test('fromJson/toJson roundtrip', () {
      final profile = LearnerProfile(
        id: 'p1',
        userId: 'user1',
        version: 2,
        estimatedLevel: LearnerLevel.intermediate,
        masteredTopics: ['rome', 'egypt'],
        difficultTopics: ['greece'],
        quizAccuracyRate: 0.72,
        lastUpdatedAt: DateTime(2025, 7, 23),
        createdAt: DateTime(2025, 7, 20),
      );
      final json = profile.toJson();
      final restored = LearnerProfile.fromJson(json);
      expect(restored.estimatedLevel, LearnerLevel.intermediate);
      expect(restored.masteredTopics, ['rome', 'egypt']);
      expect(restored.quizAccuracyRate, 0.72);
      expect(restored.version, 2);
    });

    test('copyWith preserves values', () {
      final profile = LearnerProfile(
        id: 'p1', userId: 'u1',
        estimatedLevel: LearnerLevel.beginner,
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      final updated = profile.copyWith(estimatedLevel: LearnerLevel.advanced);
      expect(updated.estimatedLevel, LearnerLevel.advanced);
      expect(updated.userId, 'u1');
    });
  });

  group('AdaptiveRecommendation Entity', () {
    test('fromJson/toJson', () {
      final rec = AdaptiveRecommendation(
        id: 'r1',
        userId: 'u1',
        entityId: 'char_caesar',
        entityType: 'character',
        entityName: 'Júlio César',
        type: RecommendationType.relatedContent,
        reason: 'Recomendado porque você estudou Roma.',
        score: 0.85,
        priority: 5,
        generatedAt: DateTime(2025, 7, 23),
      );
      final json = rec.toJson();
      final restored = AdaptiveRecommendation.fromJson(json);
      expect(restored.reason, contains('Roma'));
      expect(restored.type, RecommendationType.relatedContent);
      expect(restored.score, 0.85);
    });
  });

  group('StudyPlan Entity', () {
    test('fromJson/toJson with daily plans', () {
      final plan = StudyPlan(
        id: 'sp1',
        userId: 'u1',
        title: 'Plano ENEM',
        objective: StudyObjective.enem,
        weekStart: DateTime(2025, 7, 21),
        weekEnd: DateTime(2025, 7, 27),
        dailyPlans: const [
          DailyPlan(dayOfWeek: 1, items: [
            PlanItem(entityId: 'e1', entityType: 'character', entityName: 'César', type: PlanItemType.read),
          ], estimatedMinutes: 15),
        ],
        createdAt: DateTime(2025, 7, 20),
      );
      final json = plan.toJson();
      final restored = StudyPlan.fromJson(json);
      expect(restored.objective, StudyObjective.enem);
      expect(restored.dailyPlans, hasLength(1));
      expect(restored.dailyPlans.first.items.first.entityName, 'César');
    });
  });

  group('LearningReport Entity', () {
    test('fromJson/toJson', () {
      final report = LearningReport(
        id: 'lr1',
        userId: 'u1',
        period: ReportPeriod.weekly,
        periodStart: DateTime(2025, 7, 14),
        periodEnd: DateTime(2025, 7, 20),
        totalStudyTimeSeconds: 3600,
        contentsCompleted: 5,
        quizAccuracy: 0.75,
        masteredTopics: ['rome'],
        topicsToReview: ['greece'],
        recommendations: ['Revisar Grécia'],
        generatedAt: DateTime(2025, 7, 21),
      );
      final json = report.toJson();
      final restored = LearningReport.fromJson(json);
      expect(restored.period, ReportPeriod.weekly);
      expect(restored.quizAccuracy, 0.75);
      expect(restored.recommendations, ['Revisar Grécia']);
    });
  });

  group('LearnerProfileService', () {
    late MockAdaptiveLearningRepository adaptiveRepo;
    late MockLearningRepository learningRepo;
    late LearnerProfileService service;

    setUp(() {
      adaptiveRepo = MockAdaptiveLearningRepository();
      learningRepo = MockLearningRepository();
      service = LearnerProfileService(
        repository: adaptiveRepo,
        learningRepository: learningRepo,
      );
    });

    test('getProfile cria perfil padrão se não existe', () async {
      final profile = await service.getProfile();
      expect(profile.estimatedLevel, LearnerLevel.beginner);
      expect(profile.userId, 'local_user');
    });

    test('refreshProfile calcula nível do Learning Engine', () async {
      // Simular quiz answers com alta accuracy
      for (int i = 0; i < 60; i++) {
        learningRepo.addAnswer(QuizAnswer(
          id: 'a$i', userId: 'local_user', questionId: 'q$i',
          entityId: 'rome', selectedIndex: 0,
          isCorrect: i < 50, responseTimeMs: 2000, answeredAt: DateTime.now(),
        ));
      }
      final profile = await service.refreshProfile();
      expect(profile.estimatedLevel, LearnerLevel.advanced);
      expect(profile.quizAccuracyRate, closeTo(0.833, 0.01));
    });

    test('updatePreferences salva objetivo', () async {
      await service.getProfile();
      final updated = await service.updatePreferences(objective: StudyObjective.enem);
      expect(updated.primaryObjective, StudyObjective.enem);
    });
  });

  group('TutorService', () {
    late TutorService tutor;

    setUp(() {
      tutor = TutorService();
    });

    test('generateTutorPrompt para iniciante', () {
      final profile = LearnerProfile(
        id: 'p1', userId: 'u1', estimatedLevel: LearnerLevel.beginner,
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      final prompt = tutor.generateTutorPrompt(
        mode: TutorMode.explainBeginner,
        entityName: 'Cleópatra',
        entityType: 'character',
        profile: profile,
      );
      expect(prompt, contains('Tutor Chronos'));
      expect(prompt, contains('iniciante'));
      expect(prompt, contains('simples'));
    });

    test('generateTutorPrompt para prova', () {
      final profile = LearnerProfile(
        id: 'p1', userId: 'u1', estimatedLevel: LearnerLevel.intermediate,
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      final prompt = tutor.generateTutorPrompt(
        mode: TutorMode.highlightForExam,
        entityName: 'Roma',
        entityType: 'civilization',
        profile: profile,
      );
      expect(prompt, contains('ENEM'));
      expect(prompt, contains('vestibulares'));
    });

    test('generateContextualExplanation retorna explicação', () {
      final explanation = tutor.generateContextualExplanation(
        questionId: 'q1',
        correctAnswer: 'Egito',
        entityId: 'cleo',
        entityType: 'character',
        entityName: 'Cleópatra',
        relatedEvents: ['Batalha de Ácio'],
      );
      expect(explanation.correctAnswer, 'Egito');
      expect(explanation.relatedEvents, contains('Batalha de Ácio'));
    });
  });

  group('AdaptiveRecommendationEngine', () {
    late MockAdaptiveLearningRepository adaptiveRepo;
    late MockLearningRepository learningRepo;
    late MockLearningPathsRepository pathsRepo;
    late AdaptiveRecommendationEngine engine;

    setUp(() {
      adaptiveRepo = MockAdaptiveLearningRepository();
      learningRepo = MockLearningRepository();
      pathsRepo = MockLearningPathsRepository();
      engine = AdaptiveRecommendationEngine(
        adaptiveRepository: adaptiveRepo,
        learningRepository: learningRepo,
        pathsRepository: pathsRepo,
      );
    });

    test('generateRecommendations com revisões pendentes', () async {
      learningRepo.addReview(ReviewSchedule(
        id: 'r1', userId: 'local_user', entityId: 'rome',
        entityType: 'civilization', entityName: 'Roma',
        scheduledFor: DateTime.now(), intervalDays: 1, repetition: 0,
      ));
      final profile = LearnerProfile(
        id: 'p1', userId: 'local_user',
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      final recs = await engine.generateRecommendations(profile: profile);
      expect(recs, isNotEmpty);
      expect(recs.first.type, RecommendationType.review);
      expect(recs.first.reason, contains('Revisão programada'));
    });

    test('explainability: toda recomendação tem reason', () async {
      learningRepo.addRecord(StudyRecord(
        id: 's1', userId: 'local_user', entityId: 'egypt',
        entityType: 'civilization', entityName: 'Egito',
        activityType: StudyActivityType.read, durationSeconds: 60,
        startedAt: DateTime.now(),
      ));
      final profile = LearnerProfile(
        id: 'p1', userId: 'local_user',
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      final recs = await engine.generateRecommendations(profile: profile);
      for (final rec in recs) {
        expect(rec.reason, isNotEmpty);
      }
    });

    test('cache funciona', () async {
      final profile = LearnerProfile(
        id: 'p1', userId: 'local_user',
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      await engine.generateRecommendations(profile: profile);
      final cached = await engine.getRecommendations();
      expect(cached, isNotNull);
    });
  });

  group('AdaptiveQuizService', () {
    late MockLearningRepository learningRepo;
    late AdaptiveQuizService service;

    setUp(() {
      learningRepo = MockLearningRepository();
      service = AdaptiveQuizService(learningRepository: learningRepo);
    });

    test('retorna easy sem histórico', () async {
      final difficulty = await service.getAdaptiveDifficulty('entity1');
      expect(difficulty, QuizDifficulty.easy);
    });

    test('retorna hard com alta accuracy', () async {
      for (int i = 0; i < 10; i++) {
        learningRepo.addAnswer(QuizAnswer(
          id: 'a$i', userId: 'local_user', questionId: 'q$i',
          entityId: 'entity1', selectedIndex: 0,
          isCorrect: true, responseTimeMs: 1000, answeredAt: DateTime.now(),
        ));
      }
      final difficulty = await service.getAdaptiveDifficulty('entity1');
      expect(difficulty, QuizDifficulty.hard);
    });

    test('retorna easy com baixa accuracy', () async {
      for (int i = 0; i < 10; i++) {
        learningRepo.addAnswer(QuizAnswer(
          id: 'a$i', userId: 'local_user', questionId: 'q$i',
          entityId: 'entity1', selectedIndex: 1,
          isCorrect: false, responseTimeMs: 1000, answeredAt: DateTime.now(),
        ));
      }
      final difficulty = await service.getAdaptiveDifficulty('entity1');
      expect(difficulty, QuizDifficulty.easy);
    });

    test('shouldTriggerReview após 3 erros', () async {
      for (int i = 0; i < 3; i++) {
        learningRepo.addAnswer(QuizAnswer(
          id: 'a$i', userId: 'local_user', questionId: 'q$i',
          entityId: 'entity1', selectedIndex: 1,
          isCorrect: false, responseTimeMs: 1000, answeredAt: DateTime.now(),
        ));
      }
      expect(await service.shouldTriggerReview('entity1'), isTrue);
    });
  });

  group('StudyPlanService', () {
    late MockAdaptiveLearningRepository adaptiveRepo;
    late MockLearningRepository learningRepo;
    late MockLearningPathsRepository pathsRepo;
    late StudyPlanService service;

    setUp(() {
      adaptiveRepo = MockAdaptiveLearningRepository();
      learningRepo = MockLearningRepository();
      pathsRepo = MockLearningPathsRepository();
      service = StudyPlanService(
        adaptiveRepository: adaptiveRepo,
        learningRepository: learningRepo,
        pathsRepository: pathsRepo,
      );
    });

    test('generateWeeklyPlan cria plano com 7 dias', () async {
      final profile = LearnerProfile(
        id: 'p1', userId: 'local_user',
        availableMinutesPerDay: 20,
        primaryObjective: StudyObjective.enem,
        lastUpdatedAt: DateTime.now(), createdAt: DateTime.now(),
      );
      final plan = await service.generateWeeklyPlan(profile: profile);
      expect(plan.dailyPlans, hasLength(7));
      expect(plan.objective, StudyObjective.enem);
      expect(plan.title, contains('ENEM'));
    });
  });

  group('DifficultyDetectionService', () {
    late MockLearningRepository learningRepo;
    late DifficultyDetectionService service;

    setUp(() {
      learningRepo = MockLearningRepository();
      service = DifficultyDetectionService(learningRepository: learningRepo);
    });

    test('detecta baixa accuracy', () async {
      for (int i = 0; i < 5; i++) {
        learningRepo.addAnswer(QuizAnswer(
          id: 'a$i', userId: 'local_user', questionId: 'q$i',
          entityId: 'hard_topic', selectedIndex: 1,
          isCorrect: i == 0, responseTimeMs: 1000, answeredAt: DateTime.now(),
        ));
      }
      final alerts = await service.detectDifficulties();
      expect(alerts.any((a) => a.reason == DifficultyReason.lowAccuracy), isTrue);
    });

    test('detecta tempo excessivo', () async {
      learningRepo.addProgress(StudyProgress(
        id: 'sp1', userId: 'local_user', entityId: 'topic1',
        entityType: 'character', entityName: 'Test',
        totalReadTimeSeconds: 2000, viewCount: 5,
        firstAccess: DateTime.now().subtract(const Duration(days: 10)),
        lastAccess: DateTime.now(),
      ));
      final alerts = await service.detectDifficulties();
      expect(alerts.any((a) => a.reason == DifficultyReason.excessiveReadTime), isTrue);
    });
  });

  group('LearningReportService', () {
    late MockAdaptiveLearningRepository adaptiveRepo;
    late MockLearningRepository learningRepo;
    late LearningReportService service;

    setUp(() {
      adaptiveRepo = MockAdaptiveLearningRepository();
      learningRepo = MockLearningRepository();
      service = LearningReportService(
        adaptiveRepository: adaptiveRepo,
        learningRepository: learningRepo,
      );
    });

    test('generateWeeklyReport cria relatório', () async {
      learningRepo.addRecord(StudyRecord(
        id: 's1', userId: 'local_user', entityId: 'e1',
        entityType: 'character', entityName: 'Test',
        activityType: StudyActivityType.read, durationSeconds: 120,
        startedAt: DateTime.now().subtract(const Duration(days: 3)),
      ));
      final report = await service.generateWeeklyReport();
      expect(report.period, ReportPeriod.weekly);
      expect(report.userId, 'local_user');
    });
  });

  group('LearningPrivacyService', () {
    late MockAdaptiveLearningRepository repo;
    late LearningPrivacyService service;

    setUp(() {
      repo = MockAdaptiveLearningRepository();
      service = LearningPrivacyService(repository: repo);
    });

    test('exportAllData retorna dados', () async {
      final data = await service.exportAllData();
      expect(data, isNotEmpty);
      expect(data['exported'], isTrue);
    });

    test('deleteAllData limpa dados', () async {
      await service.deleteAllData();
      expect(repo.wasDeleted, isTrue);
    });
  });
}
