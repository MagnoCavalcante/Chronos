import '../../../core/di/service_locator.dart';
import '../../../core/relationships/relationship_engine.dart';
import '../../../core/timeline/timeline_repository.dart';
import '../../../features/search/domain/usecases/search_use_case.dart';
import '../data/repositories/ai_repository_impl.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../data/services/prompt_builder.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/conversation_repository.dart';
import '../presentation/controllers/conversation_controller.dart';
import '../services/ai_service.dart';

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
  }
}
