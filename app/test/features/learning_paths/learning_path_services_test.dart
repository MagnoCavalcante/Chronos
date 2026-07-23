import 'package:chronos/features/learning/domain/entities/learning_entities.dart';
import 'package:chronos/features/learning/domain/repositories/learning_repository.dart';
import 'package:chronos/features/learning_paths/domain/entities/learning_path_entities.dart';
import 'package:chronos/features/learning_paths/domain/repositories/learning_paths_repository.dart';
import 'package:chronos/features/learning_paths/services/certificate_service.dart';
import 'package:chronos/features/learning_paths/services/path_progress_service.dart';
import 'package:chronos/features/learning_paths/services/path_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLearningPathsRepository implements LearningPathsRepository {
  final List<LearningPath> _paths = [];
  final Map<String, PathProgress> _progress = {};
  final Map<String, ModuleProgress> _moduleProgress = {};
  final List<PathCertificate> _certificates = [];

  void addPath(LearningPath path) => _paths.add(path);

  @override
  Future<List<LearningPath>> getAllPaths({PathCategory? category, PathDifficulty? difficulty}) async {
    var result = _paths.toList();
    if (category != null) result = result.where((p) => p.category == category).toList();
    if (difficulty != null) result = result.where((p) => p.difficulty == difficulty).toList();
    return result;
  }

  @override
  Future<LearningPath?> getPath(String pathId) async {
    return _paths.where((p) => p.id == pathId).firstOrNull;
  }

  @override
  Future<List<LearningPath>> searchPaths(String query) async {
    return _paths.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<PathModule>> getModules(String pathId) async {
    final path = _paths.where((p) => p.id == pathId).firstOrNull;
    return path?.modules ?? [];
  }

  @override
  Future<List<PathContent>> getModuleContents(String moduleId) async => [];

  @override
  Future<PathProgress?> getPathProgress(String userId, String pathId) async {
    return _progress['$userId:$pathId'];
  }

  @override
  Future<List<PathProgress>> getUserPaths(String userId) async {
    return _progress.values.where((p) => p.userId == userId).toList();
  }

  @override
  Future<List<PathProgress>> getInProgressPaths(String userId) async {
    return _progress.values.where((p) => p.userId == userId && p.status == PathStatus.inProgress).toList();
  }

  @override
  Future<List<PathProgress>> getCompletedPaths(String userId) async {
    return _progress.values.where((p) => p.userId == userId && p.status == PathStatus.completed).toList();
  }

  @override
  Future<void> upsertPathProgress(PathProgress progress) async {
    _progress['${progress.userId}:${progress.pathId}'] = progress;
  }

  @override
  Future<ModuleProgress?> getModuleProgress(String userId, String moduleId) async {
    return _moduleProgress['$userId:$moduleId'];
  }

  @override
  Future<List<ModuleProgress>> getPathModuleProgress(String userId, String pathId) async {
    return _moduleProgress.values.where((m) => m.pathId == pathId).toList();
  }

  @override
  Future<void> upsertModuleProgress(ModuleProgress progress) async {
    _moduleProgress['${progress.userId}:${progress.moduleId}'] = progress;
  }

  @override
  Future<List<PathCertificate>> getCertificates(String userId) async {
    return _certificates.where((c) => c.userId == userId).toList();
  }

  @override
  Future<void> issueCertificate(PathCertificate certificate) async {
    _certificates.add(certificate);
  }
}

class MockLearningRepository implements LearningRepository {
  final List<StudyRecord> _records = [];

  @override
  Future<void> recordActivity(StudyRecord record) async => _records.add(record);
  @override
  Future<List<StudyRecord>> getHistory(String userId, {int limit = 50}) async => _records;
  @override
  Future<List<StudyRecord>> getRecentHistory(String userId, {int limit = 10}) async => _records;
  @override
  Future<StudyProgress?> getProgress(String userId, String entityId) async => null;
  @override
  Future<List<StudyProgress>> getAllProgress(String userId, {int limit = 50}) async => [];
  @override
  Future<List<StudyProgress>> getRecentProgress(String userId, {int limit = 5}) async => [];
  @override
  Future<void> upsertProgress(StudyProgress progress) async {}
  @override
  Future<void> updateStatus(String userId, String entityId, StudyStatus status) async {}
  @override
  Future<List<ReviewSchedule>> getPendingReviews(String userId) async => [];
  @override
  Future<void> scheduleReview(ReviewSchedule review) async {}
  @override
  Future<void> completeReview(String reviewId) async {}
  @override
  Future<List<QuizQuestion>> getQuizQuestions(String entityId, {int limit = 5}) async => [];
  @override
  Future<void> saveQuizAnswer(QuizAnswer answer) async {}
  @override
  Future<List<QuizAnswer>> getQuizHistory(String userId, {String? entityId}) async => [];
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
  Future<UserStudyStats?> getStats(String userId) async => null;
  @override
  Future<void> updateStats(UserStudyStats stats) async {}
  @override
  Future<List<StudyChallenge>> getActiveChallenges(String userId) async => [];
  @override
  Future<void> createChallenge(StudyChallenge challenge) async {}
  @override
  Future<void> updateChallengeProgress(String challengeId, int currentValue) async {}
}

void main() {
  group('PathProgressService', () {
    late MockLearningPathsRepository pathsRepo;
    late MockLearningRepository learningRepo;
    late PathProgressService service;

    setUp(() {
      pathsRepo = MockLearningPathsRepository();
      learningRepo = MockLearningRepository();
      service = PathProgressService(
        pathsRepository: pathsRepo,
        learningRepository: learningRepo,
      );
    });

    test('startPath cria progresso e desbloqueia primeiro módulo', () async {
      final path = LearningPath(
        id: 'p1',
        name: 'Egito',
        description: 'Test',
        category: PathCategory.antiquity,
        totalModules: 2,
        totalContents: 6,
        createdAt: DateTime.now(),
        modules: const [
          PathModule(id: 'm1', pathId: 'p1', title: 'Módulo 1', order: 1, totalContents: 3),
          PathModule(id: 'm2', pathId: 'p1', title: 'Módulo 2', order: 2, totalContents: 3),
        ],
      );
      pathsRepo.addPath(path);

      await service.startPath(path);

      final progress = await pathsRepo.getPathProgress('local_user', 'p1');
      expect(progress, isNotNull);
      expect(progress!.status, PathStatus.inProgress);

      final m1 = await pathsRepo.getModuleProgress('local_user', 'm1');
      expect(m1!.status, ModuleStatus.unlocked);

      final m2 = await pathsRepo.getModuleProgress('local_user', 'm2');
      expect(m2!.status, ModuleStatus.locked);
    });

    test('startPath não duplica progresso existente', () async {
      final path = LearningPath(
        id: 'p1', name: 'Egito', description: '',
        category: PathCategory.antiquity, createdAt: DateTime.now(),
        modules: const [PathModule(id: 'm1', pathId: 'p1', title: 'M1', totalContents: 3)],
      );
      pathsRepo.addPath(path);
      await service.startPath(path);
      await service.startPath(path); // segunda vez

      final all = await pathsRepo.getUserPaths('local_user');
      expect(all, hasLength(1));
    });

    test('completeContent atualiza progresso do módulo', () async {
      final path = LearningPath(
        id: 'p1', name: 'Egito', description: '',
        category: PathCategory.antiquity, createdAt: DateTime.now(),
        totalModules: 1, totalContents: 3,
        modules: const [
          PathModule(id: 'm1', pathId: 'p1', title: 'M1', order: 1, totalContents: 3),
        ],
      );
      pathsRepo.addPath(path);
      await service.startPath(path);

      final result = await service.completeContent(
        pathId: 'p1',
        moduleId: 'm1',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Test',
      );

      expect(result.moduleCompleted, isFalse);
      expect(result.newCompletedContents, 1);
    });

    test('completeContent marca módulo completed quando último conteúdo', () async {
      final path = LearningPath(
        id: 'p1', name: 'Egito', description: '',
        category: PathCategory.antiquity, createdAt: DateTime.now(),
        totalModules: 1, totalContents: 1,
        modules: const [
          PathModule(id: 'm1', pathId: 'p1', title: 'M1', order: 1, totalContents: 1),
        ],
      );
      pathsRepo.addPath(path);
      await service.startPath(path);

      final result = await service.completeContent(
        pathId: 'p1',
        moduleId: 'm1',
        entityId: 'char_1',
        entityType: 'character',
        entityName: 'Test',
      );

      expect(result.moduleCompleted, isTrue);
      expect(result.pathCompleted, isTrue);
    });
  });

  group('CertificateService', () {
    late MockLearningPathsRepository repo;
    late CertificateService certService;

    setUp(() {
      repo = MockLearningPathsRepository();
      certService = CertificateService(repository: repo);
    });

    test('issueCertificate cria certificado', () async {
      await certService.issueCertificate(
        pathId: 'p1',
        pathName: 'Egito Antigo',
        userName: 'Magno',
        totalTimeSeconds: 5400,
        totalContentsCompleted: 9,
        xpEarned: 200,
      );

      final certs = await certService.getCertificates();
      expect(certs, hasLength(1));
      expect(certs.first.pathName, 'Egito Antigo');
    });

    test('hasCertificate retorna true quando existe', () async {
      await certService.issueCertificate(
        pathId: 'p1', pathName: 'Test', userName: 'User',
        totalTimeSeconds: 0, totalContentsCompleted: 0, xpEarned: 0,
      );
      expect(await certService.hasCertificate('p1'), isTrue);
      expect(await certService.hasCertificate('p2'), isFalse);
    });
  });

  group('PathRecommendationService', () {
    late MockLearningPathsRepository repo;
    late PathRecommendationService recService;

    setUp(() {
      repo = MockLearningPathsRepository();
      recService = PathRecommendationService(repository: repo);

      repo.addPath(LearningPath(
        id: 'p1', name: 'Egito', description: '',
        category: PathCategory.antiquity, createdAt: DateTime.now(),
      ));
      repo.addPath(LearningPath(
        id: 'p2', name: 'Roma', description: '',
        category: PathCategory.civilizations, createdAt: DateTime.now(),
      ));
      repo.addPath(LearningPath(
        id: 'p3', name: 'Grécia', description: '',
        category: PathCategory.antiquity, difficulty: PathDifficulty.beginner, createdAt: DateTime.now(),
      ));
    });

    test('recommends beginner paths when no history', () async {
      final recs = await recService.getRecommendations();
      expect(recs, isNotEmpty);
    });

    test('recommends related categories after completion', () async {
      // Simular trilha concluída
      await repo.upsertPathProgress(PathProgress(
        id: 'pp1', userId: 'local_user', pathId: 'p1', pathName: 'Egito',
        status: PathStatus.completed,
        startedAt: DateTime.now(), lastAccessAt: DateTime.now(),
      ));

      final recs = await recService.getRecommendations();
      // Deve recomendar civilizations (Roma) pois é related a antiquity
      expect(recs.any((r) => r.id == 'p2'), isTrue);
    });
  });
}
