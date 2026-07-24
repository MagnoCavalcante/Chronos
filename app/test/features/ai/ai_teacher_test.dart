import 'package:chronos/features/adaptive_learning/domain/entities/adaptive_learning_entities.dart';
import 'package:chronos/features/adaptive_learning/domain/repositories/adaptive_learning_repository.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:chronos/features/ai/domain/entities/ai_teacher_entities.dart';
import 'package:chronos/features/ai/domain/repositories/ai_repository.dart';
import 'package:chronos/features/ai/domain/repositories/ai_teacher_repository.dart';
import 'package:chronos/features/ai/domain/repositories/conversation_repository.dart';
import 'package:chronos/features/ai/services/ai_quiz_generator_service.dart';
import 'package:chronos/features/ai/services/ai_service.dart';
import 'package:chronos/features/ai/services/ai_teacher_service.dart';
import 'package:chronos/features/ai/services/path_tutor_service.dart';
import 'package:chronos/features/ai/services/study_session_service.dart';
import 'package:chronos/features/ai/services/tutor_memory_service.dart';
import 'package:chronos/features/learning/domain/entities/learning_entities.dart';
import 'package:chronos/features/learning/domain/repositories/learning_repository.dart';
import 'package:chronos/features/learning_paths/domain/entities/learning_path_entities.dart';
import 'package:chronos/features/learning_paths/domain/repositories/learning_paths_repository.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';
import 'package:chronos/features/search/domain/repositories/search_repository.dart';
import 'package:chronos/features/search/domain/usecases/search_use_case.dart';
import 'package:chronos/features/ai/data/services/prompt_builder.dart';
import 'package:chronos/core/relationships/relationship_engine.dart';
import 'package:chronos/core/timeline/timeline_repository.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================
// Mocks
// ============================================================

class MockAIRepository implements AIRepository {
  @override
  Future<AiResponse> generate(AiRequest request) async {
    return AiResponse(
      text: 'Resposta sobre: ${request.question}',
      provider: AiProviderType.offline,
      suggestedQuestions: ['Pergunta sugerida 1'],
    );
  }

  @override
  Future<AiResponse?> getCached(String cacheKey) async => null;
  @override
  Future<void> cache(String cacheKey, AiResponse response) async {}
}

class MockConversationRepository implements ConversationRepository {
  final List<ConversationMessage> _messages = [];

  @override
  Future<List<ConversationMessage>> getHistory() async => _messages;
  @override
  Future<void> saveMessage(ConversationMessage message) async => _messages.add(message);
  @override
  Future<void> deleteMessage(String id) async => _messages.removeWhere((m) => m.id == id);
  @override
  Future<ConversationMessage> toggleFavorite(String id) async {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx < 0) throw Exception('Not found');
    final m = _messages[idx];
    _messages[idx] = m.copyWith(isFavorite: !m.isFavorite);
    return _messages[idx];
  }

  @override
  Future<ConversationMessage> togglePin(String id) async {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx < 0) throw Exception('Not found');
    final m = _messages[idx];
    _messages[idx] = m.copyWith(isPinned: !m.isPinned);
    return _messages[idx];
  }

  @override
  Future<List<ConversationMessage>> getFavorites() async =>
      _messages.where((m) => m.isFavorite).toList();
  @override
  Future<List<ConversationMessage>> getPinned() async =>
      _messages.where((m) => m.isPinned).toList();
  @override
  Future<List<ConversationMessage>> getRecent({int limit = 10}) async =>
      _messages.take(limit).toList();
  @override
  Future<void> clearHistory() async => _messages.clear();
}

class MockAdaptiveLearningRepository implements AdaptiveLearningRepository {
  @override
  Future<LearnerProfile?> getProfile(String userId) async => null;
  @override
  Future<void> upsertProfile(LearnerProfile profile) async {}
  @override
  Future<List<LearnerProfile>> getProfileHistory(String userId) async => [];
  @override
  Future<List<AdaptiveRecommendation>> getRecommendations(String userId,
          {int limit = 10}) async =>
      [];
  @override
  Future<void> saveRecommendations(List<AdaptiveRecommendation> recs) async {}
  @override
  Future<void> dismissRecommendation(String id) async {}
  @override
  Future<void> clearRecommendations(String userId) async {}
  @override
  Future<StudyPlan?> getCurrentPlan(String userId) async => null;
  @override
  Future<void> savePlan(StudyPlan plan) async {}
  @override
  Future<List<StudyPlan>> getPlanHistory(String userId, {int limit = 10}) async => [];
  @override
  Future<LearningReport?> getLatestReport(String userId, ReportPeriod period) async => null;
  @override
  Future<void> saveReport(LearningReport report) async {}
  @override
  Future<List<LearningReport>> getReports(String userId, {int limit = 10}) async => [];
  @override
  Future<Map<String, dynamic>> exportAllData(String userId) async => {};
  @override
  Future<void> deleteAllData(String userId) async {}
}

class MockAiTeacherRepository implements AiTeacherRepository {
  final Map<String, TutorSession> _sessions = {};
  final List<TutorMemoryEntry> _memory = [];

  @override
  Future<TutorSession?> getSession(String sessionId) async => _sessions[sessionId];
  @override
  Future<TutorSession?> getActiveSession(String userId) async {
    try {
      return _sessions.values.firstWhere(
        (s) => s.userId == userId && s.status == StudySessionStatus.active,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TutorSession>> getSessions(String userId, {int limit = 10}) async =>
      _sessions.values.where((s) => s.userId == userId).take(limit).toList();
  @override
  Future<void> saveSession(TutorSession session) async => _sessions[session.id] = session;

  @override
  Future<List<TutorMemoryEntry>> getMemory(String userId, {TutorMemoryType? type}) async {
    if (type != null) return _memory.where((m) => m.type == type).toList();
    return _memory;
  }

  @override
  Future<void> saveMemoryEntry(TutorMemoryEntry entry) async => _memory.add(entry);
  @override
  Future<void> clearMemory(String userId) async => _memory.clear();
}

class MockLearningRepository implements LearningRepository {
  @override
  Future<void> recordActivity(StudyRecord record) async {}
  @override
  Future<List<StudyRecord>> getHistory(String userId, {int limit = 50}) async => [];
  @override
  Future<List<StudyRecord>> getRecentHistory(String userId, {int limit = 10}) async => [];
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

class MockLearningPathsRepository implements LearningPathsRepository {
  @override
  Future<List<LearningPath>> getAllPaths({PathCategory? category, PathDifficulty? difficulty}) async => [];
  @override
  Future<LearningPath?> getPath(String pathId) async => LearningPath(
        id: 'p1',
        name: 'Egito Antigo',
        description: 'Trilha do Egito',
        category: PathCategory.antiquity,
        difficulty: PathDifficulty.beginner,
        createdAt: DateTime(2025, 1, 1),
      );
  @override
  Future<List<LearningPath>> searchPaths(String query) async => [];
  @override
  Future<List<PathModule>> getModules(String pathId) async => [
        const PathModule(id: 'm1', pathId: 'p1', title: 'Surgimento', description: 'Origens', order: 1),
        const PathModule(id: 'm2', pathId: 'p1', title: 'Reino Antigo', description: 'Pirâmides', order: 2),
      ];
  @override
  Future<List<PathContent>> getModuleContents(String moduleId) async => [
        const PathContent(id: 'c1', moduleId: 'm1', entityId: 'e1', entityType: 'character', entityName: 'Narmer', order: 1),
      ];
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
// Helper: build AiService with mocks (bypasses PromptBuilder)
// ============================================================

class SimpleAiService extends AiService {
  SimpleAiService()
      : super(
          promptBuilder: _DummyPromptBuilder(),
          repository: MockAIRepository(),
          conversation: MockConversationRepository(),
        );
}

class _DummyPromptBuilder extends PromptBuilder {
  _DummyPromptBuilder()
      : super(
          search: SearchUseCase(_DummySearchRepository()),
          relationshipEngine: RelationshipEngine(),
          timelineRepository: TimelineRepository(),
        );

  @override
  Future<AiRequest> buildRequest(String question, {AiMode? mode}) async {
    return AiRequest(
      question: question,
      mode: mode ?? AiMode.normal,
      prompt: question,
    );
  }
}

class _DummySearchRepository implements SearchRepository {
  @override
  Future<Result<SearchPage>> search(SearchQuery query) async {
    return const Result.success(SearchPage(results: [], hasMore: false));
  }
}

// ============================================================
// Tests
// ============================================================

void main() {
  // ============ Entities ============

  group('TutorSession Entity', () {
    test('fromJson/toJson roundtrip', () {
      final session = TutorSession(
        id: 'ts1',
        userId: 'u1',
        topic: 'Roma Antiga',
        level: ExplanationLevel.advanced,
        startedAt: DateTime(2025, 7, 24),
        steps: [
          SessionStep(
            type: SessionStepType.explanation,
            content: 'Roma foi fundada em...',
            timestamp: DateTime(2025, 7, 24),
          ),
        ],
      );
      final json = session.toJson();
      final restored = TutorSession.fromJson(json);
      expect(restored.topic, 'Roma Antiga');
      expect(restored.level, ExplanationLevel.advanced);
      expect(restored.steps, hasLength(1));
      expect(restored.steps.first.type, SessionStepType.explanation);
    });

    test('copyWith preserves values', () {
      final session = TutorSession(
        id: 's1', userId: 'u1', topic: 'Egito', startedAt: DateTime.now(),
      );
      final completed = session.copyWith(
        status: StudySessionStatus.completed,
        endedAt: DateTime.now(),
      );
      expect(completed.status, StudySessionStatus.completed);
      expect(completed.topic, 'Egito');
    });
  });

  group('TutorMemoryEntry Entity', () {
    test('fromJson/toJson roundtrip', () {
      final entry = TutorMemoryEntry(
        id: 'mem1',
        userId: 'u1',
        entityId: 'rome',
        entityName: 'Roma',
        type: TutorMemoryType.doubt,
        content: 'Por que Roma caiu?',
        recordedAt: DateTime(2025, 7, 24),
      );
      final json = entry.toJson();
      final restored = TutorMemoryEntry.fromJson(json);
      expect(restored.type, TutorMemoryType.doubt);
      expect(restored.content, 'Por que Roma caiu?');
    });
  });

  group('ExplanationLevel enum', () {
    test('all levels have labels', () {
      for (final level in ExplanationLevel.values) {
        expect(level.label, isNotEmpty);
      }
    });
  });

  group('AiQuizType enum', () {
    test('all types have labels', () {
      for (final type in AiQuizType.values) {
        expect(type.label, isNotEmpty);
      }
    });
  });

  // ============ AiTeacherService ============

  group('AiTeacherService', () {
    late AiTeacherService teacher;

    setUp(() {
      teacher = AiTeacherService(
        aiService: SimpleAiService(),
        adaptiveRepository: MockAdaptiveLearningRepository(),
      );
    });

    test('ask retorna resposta', () async {
      final response = await teacher.ask('Quem foi Cleópatra?');
      expect(response.text, contains('Cleópatra'));
    });

    test('askInContext usa contexto da página', () async {
      final response = await teacher.askInContext(
        question: 'Por que ela perdeu a guerra?',
        context: const PageContext(
          entityId: 'cleopatra',
          entityType: 'character',
          entityName: 'Cleópatra',
          summary: 'Última faraó do Egito.',
        ),
      );
      expect(response.text, isNotEmpty);
    });

    test('explain com nível básico', () async {
      final response = await teacher.explain(
        topic: 'Revolução Francesa',
        level: ExplanationLevel.basic,
      );
      expect(response.text, isNotEmpty);
    });

    test('compare gera comparação', () async {
      final response = await teacher.compare(entityA: 'Roma', entityB: 'Grécia');
      expect(response.text, isNotEmpty);
    });

    test('askTimeline retorna resposta temporal', () async {
      final response = await teacher.askTimeline('O que aconteceu depois de 476 d.C.?');
      expect(response.text, isNotEmpty);
    });

    test('explainRelation mostra cadeia', () async {
      final response = await teacher.explainRelation(
        entityA: 'Júlio César',
        entityB: 'Augusto',
      );
      expect(response.text, isNotEmpty);
    });

    test('getPostContentSuggestions retorna 4 sugestões', () {
      final suggestions = teacher.getPostContentSuggestions('Cleópatra');
      expect(suggestions, hasLength(4));
      expect(suggestions.first.type, TutorSuggestionType.summary);
      expect(suggestions.last.type, TutorSuggestionType.nextContent);
    });
  });

  // ============ AiQuizGeneratorService ============

  group('AiQuizGeneratorService', () {
    late AiQuizGeneratorService quizGen;

    setUp(() {
      quizGen = AiQuizGeneratorService(aiService: SimpleAiService());
    });

    test('generateMultipleChoice', () async {
      final response = await quizGen.generateMultipleChoice(
        entityName: 'Roma', entityType: 'civilization',
      );
      expect(response.text, isNotEmpty);
    });

    test('generateTrueFalse', () async {
      final response = await quizGen.generateTrueFalse(
        entityName: 'Roma', entityType: 'civilization',
      );
      expect(response.text, isNotEmpty);
    });

    test('generateShortAnswer', () async {
      final response = await quizGen.generateShortAnswer(
        entityName: 'Roma', entityType: 'civilization',
      );
      expect(response.text, isNotEmpty);
    });

    test('generateDiscursive', () async {
      final response = await quizGen.generateDiscursive(
        entityName: 'Roma', entityType: 'civilization',
      );
      expect(response.text, isNotEmpty);
    });

    test('generateMixed', () async {
      final response = await quizGen.generateMixed(
        entityName: 'Roma', entityType: 'civilization',
      );
      expect(response.text, isNotEmpty);
    });

    test('evaluateAnswer', () async {
      final response = await quizGen.evaluateAnswer(
        question: 'Quem fundou Roma?',
        userAnswer: 'Rômulo e Remo',
        entityName: 'Roma',
      );
      expect(response.text, isNotEmpty);
    });
  });

  // ============ StudySessionService ============

  group('StudySessionService', () {
    late StudySessionService sessionService;
    late MockAiTeacherRepository teacherRepo;

    setUp(() {
      teacherRepo = MockAiTeacherRepository();
      sessionService = StudySessionService(
        aiService: SimpleAiService(),
        repository: teacherRepo,
      );
    });

    test('startSession cria sessão ativa', () async {
      final session = await sessionService.startSession(topic: 'Roma Antiga');
      expect(session.status, StudySessionStatus.active);
      expect(session.topic, 'Roma Antiga');
      expect(session.steps, hasLength(1));
      expect(session.steps.first.type, SessionStepType.explanation);
    });

    test('submitAnswer registra resposta e correção', () async {
      final session = await sessionService.startSession(topic: 'Egito');
      final updated = await sessionService.submitAnswer(
        sessionId: session.id,
        answer: 'Os egípcios construíram pirâmides.',
      );
      expect(updated.steps.length, greaterThan(1));
    });

    test('endSession finaliza sessão', () async {
      final session = await sessionService.startSession(topic: 'Grécia');
      final ended = await sessionService.endSession(session.id);
      expect(ended.status, StudySessionStatus.completed);
      expect(ended.endedAt, isNotNull);
    });

    test('getActiveSession retorna sessão ativa', () async {
      await sessionService.startSession(topic: 'Test');
      final active = await sessionService.getActiveSession();
      expect(active, isNotNull);
    });
  });

  // ============ TutorMemoryService ============

  group('TutorMemoryService', () {
    late TutorMemoryService memoryService;
    late MockAiTeacherRepository teacherRepo;

    setUp(() {
      teacherRepo = MockAiTeacherRepository();
      memoryService = TutorMemoryService(
        repository: teacherRepo,
        learningRepository: MockLearningRepository(),
      );
    });

    test('recordDoubt salva dúvida', () async {
      await memoryService.recordDoubt(
        entityId: 'rome', entityName: 'Roma',
        question: 'Por que Roma caiu?',
      );
      final doubts = await memoryService.getFrequentDoubts();
      expect(doubts, hasLength(1));
      expect(doubts.first.content, 'Por que Roma caiu?');
    });

    test('recordDifficulty salva dificuldade', () async {
      await memoryService.recordDifficulty(
        entityId: 'greece', entityName: 'Grécia',
        description: 'Confusão entre períodos',
      );
      final diffs = await memoryService.getDifficulties();
      expect(diffs, hasLength(1));
    });

    test('recordMastery salva domínio', () async {
      await memoryService.recordMastery(entityId: 'egypt', entityName: 'Egito');
      final mastered = await memoryService.getMasteredTopics();
      expect(mastered, hasLength(1));
    });

    test('clearMemory limpa tudo', () async {
      await memoryService.recordDoubt(
        entityId: 'x', entityName: 'X', question: 'Q',
      );
      await memoryService.clearMemory();
      final all = await memoryService.getAllMemory();
      expect(all, isEmpty);
    });
  });

  // ============ PathTutorService ============

  group('PathTutorService', () {
    late PathTutorService pathTutor;

    setUp(() {
      pathTutor = PathTutorService(
        aiService: SimpleAiService(),
        pathsRepository: MockLearningPathsRepository(),
      );
    });

    test('explainModule retorna explicação', () async {
      final response = await pathTutor.explainModule(pathId: 'p1', moduleId: 'm1');
      expect(response.text, isNotEmpty);
    });

    test('reviewModule retorna revisão', () async {
      final response = await pathTutor.reviewModule(pathId: 'p1', moduleId: 'm1');
      expect(response.text, isNotEmpty);
    });

    test('practiceModule retorna exercícios', () async {
      final response = await pathTutor.practiceModule(pathId: 'p1', moduleId: 'm1');
      expect(response.text, isNotEmpty);
    });

    test('getModuleSuggestions retorna 3 sugestões', () {
      final suggestions = pathTutor.getModuleSuggestions('Surgimento');
      expect(suggestions, hasLength(3));
    });
  });

  // ============ RAG Interfaces ============

  group('RAG Interfaces', () {
    test('SemanticSearchResult has correct fields', () {
      const result = SemanticSearchResult(
        documentId: 'doc1', score: 0.95, content: 'Roma...',
      );
      expect(result.score, 0.95);
      expect(result.documentId, 'doc1');
    });

    test('RetrievedDocument has correct fields', () {
      const doc = RetrievedDocument(
        id: 'd1', content: 'Egito...', relevanceScore: 0.8,
      );
      expect(doc.relevanceScore, 0.8);
    });
  });
}
