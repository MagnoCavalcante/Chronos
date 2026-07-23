import '../../../core/di/service_locator.dart';
import '../../knowledge_base/services/knowledge_graph_service.dart';
import '../data/datasources/learning_remote_datasource.dart';
import '../data/repositories/learning_repository_impl.dart';
import '../domain/repositories/learning_repository.dart';
import '../services/achievements_service.dart';
import '../services/goals_service.dart';
import '../services/quiz_engine_service.dart';
import '../services/recommendation_service.dart';
import '../services/spaced_repetition_service.dart';
import '../services/stats_service.dart';
import '../services/study_tracker_service.dart';

/// Módulo de DI da Learning Engine.
class LearningDI {
  static void register() {
    final sl = ServiceLocator.instance;

    sl.registerLazySingleton<LearningRemoteDataSource>(
      () => LearningRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<LearningRepository>(
      () => LearningRepositoryImpl(remote: sl.get<LearningRemoteDataSource>()),
    );

    sl.registerLazySingleton<StudyTrackerService>(
      () => StudyTrackerService(repository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<SpacedRepetitionService>(
      () => SpacedRepetitionService(repository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<QuizEngineService>(
      () => QuizEngineService(repository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<GoalsService>(
      () => GoalsService(repository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<AchievementsService>(
      () => AchievementsService(repository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<StatsService>(
      () => StatsService(repository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<RecommendationService>(
      () => RecommendationService(
        repository: sl.get<LearningRepository>(),
        graphService: sl.get<KnowledgeGraphService>(),
      ),
    );
  }
}
