import '../../../core/di/service_locator.dart';
import '../../../core/relationships/relationship_engine.dart';
import '../../../core/timeline/timeline_repository.dart';
import '../../../features/search/domain/usecases/search_use_case.dart';
import '../../adaptive_learning/domain/repositories/adaptive_learning_repository.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../../learning_paths/domain/repositories/learning_paths_repository.dart';
import '../data/repositories/ai_repository_impl.dart';
import '../data/repositories/ai_teacher_repository_impl.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../data/services/prompt_builder.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/ai_teacher_repository.dart';
import '../domain/repositories/conversation_repository.dart';
import '../presentation/controllers/conversation_controller.dart';
import '../services/ai_quiz_generator_service.dart';
import '../services/ai_service.dart';
import '../services/ai_teacher_service.dart';
import '../services/path_tutor_service.dart';
import '../services/study_session_service.dart';
import '../services/tutor_memory_service.dart';

/// Injeção de dependências do módulo Chronos AI.
class AiDI {
  AiDI._();

  static void register() {
    final sl = ServiceLocator.instance;

    sl.registerLazySingleton<PromptBuilder>(() => PromptBuilder(
          search: sl.get<SearchUseCase>(),
          relationshipEngine: RelationshipEngine(),
          timelineRepository: TimelineRepository(),
        ));

    sl.registerLazySingleton<AIRepository>(() => AIRepositoryImpl());
    sl.registerLazySingleton<ConversationRepository>(() => ConversationRepositoryImpl());

    sl.registerLazySingleton<AiService>(() => AiService(
          promptBuilder: sl.get<PromptBuilder>(),
          repository: sl.get<AIRepository>(),
          conversation: sl.get<ConversationRepository>(),
        ));

    sl.registerFactory<ConversationController>(() => ConversationController(
          aiService: sl.get<AiService>(),
        ));

    // Sprint 8.5.0 — AI Teacher
    sl.registerLazySingleton<AiTeacherRepository>(() => AiTeacherRepositoryImpl());

    sl.registerLazySingleton<AiTeacherService>(() => AiTeacherService(
          aiService: sl.get<AiService>(),
          adaptiveRepository: sl.get<AdaptiveLearningRepository>(),
        ));

    sl.registerLazySingleton<AiQuizGeneratorService>(() => AiQuizGeneratorService(
          aiService: sl.get<AiService>(),
        ));

    sl.registerLazySingleton<StudySessionService>(() => StudySessionService(
          aiService: sl.get<AiService>(),
          repository: sl.get<AiTeacherRepository>(),
        ));

    sl.registerLazySingleton<TutorMemoryService>(() => TutorMemoryService(
          repository: sl.get<AiTeacherRepository>(),
          learningRepository: sl.get<LearningRepository>(),
        ));

    sl.registerLazySingleton<PathTutorService>(() => PathTutorService(
          aiService: sl.get<AiService>(),
          pathsRepository: sl.get<LearningPathsRepository>(),
        ));
  }
}
