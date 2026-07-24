import '../../../core/di/service_locator.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../../learning_paths/domain/repositories/learning_paths_repository.dart';
import '../data/datasources/adaptive_learning_remote_datasource.dart';
import '../data/repositories/adaptive_learning_repository_impl.dart';
import '../domain/repositories/adaptive_learning_repository.dart';
import '../services/adaptive_quiz_service.dart';
import '../services/adaptive_recommendation_engine.dart';
import '../services/difficulty_detection_service.dart';
import '../services/learner_profile_service.dart';
import '../services/learning_report_service.dart';
import '../services/privacy_service.dart';
import '../services/study_plan_service.dart';
import '../services/tutor_service.dart';

/// Módulo de DI do Adaptive Learning.
class AdaptiveLearningDI {
  static void register() {
    final sl = ServiceLocator.instance;

    sl.registerLazySingleton<AdaptiveLearningRemoteDataSource>(
      () => AdaptiveLearningRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<AdaptiveLearningRepository>(
      () => AdaptiveLearningRepositoryImpl(remote: sl.get<AdaptiveLearningRemoteDataSource>()),
    );

    sl.registerLazySingleton<LearnerProfileService>(
      () => LearnerProfileService(
        repository: sl.get<AdaptiveLearningRepository>(),
        learningRepository: sl.get<LearningRepository>(),
      ),
    );

    sl.registerLazySingleton<TutorService>(() => TutorService());

    sl.registerLazySingleton<AdaptiveRecommendationEngine>(
      () => AdaptiveRecommendationEngine(
        adaptiveRepository: sl.get<AdaptiveLearningRepository>(),
        learningRepository: sl.get<LearningRepository>(),
        pathsRepository: sl.get<LearningPathsRepository>(),
      ),
    );

    sl.registerLazySingleton<AdaptiveQuizService>(
      () => AdaptiveQuizService(learningRepository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<StudyPlanService>(
      () => StudyPlanService(
        adaptiveRepository: sl.get<AdaptiveLearningRepository>(),
        learningRepository: sl.get<LearningRepository>(),
        pathsRepository: sl.get<LearningPathsRepository>(),
      ),
    );

    sl.registerLazySingleton<DifficultyDetectionService>(
      () => DifficultyDetectionService(learningRepository: sl.get<LearningRepository>()),
    );

    sl.registerLazySingleton<LearningReportService>(
      () => LearningReportService(
        adaptiveRepository: sl.get<AdaptiveLearningRepository>(),
        learningRepository: sl.get<LearningRepository>(),
      ),
    );

    sl.registerLazySingleton<LearningPrivacyService>(
      () => LearningPrivacyService(repository: sl.get<AdaptiveLearningRepository>()),
    );
  }
}
