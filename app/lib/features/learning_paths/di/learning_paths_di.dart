import '../../../core/di/service_locator.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../data/datasources/learning_paths_remote_datasource.dart';
import '../data/repositories/learning_paths_repository_impl.dart';
import '../domain/repositories/learning_paths_repository.dart';
import '../services/certificate_service.dart';
import '../services/path_progress_service.dart';
import '../services/path_recommendation_service.dart';

/// Módulo de DI das Learning Paths.
class LearningPathsDI {
  static void register() {
    final sl = ServiceLocator.instance;

    sl.registerLazySingleton<LearningPathsRemoteDataSource>(
      () => LearningPathsRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<LearningPathsRepository>(
      () => LearningPathsRepositoryImpl(remote: sl.get<LearningPathsRemoteDataSource>()),
    );

    sl.registerLazySingleton<PathProgressService>(
      () => PathProgressService(
        pathsRepository: sl.get<LearningPathsRepository>(),
        learningRepository: sl.get<LearningRepository>(),
      ),
    );

    sl.registerLazySingleton<CertificateService>(
      () => CertificateService(repository: sl.get<LearningPathsRepository>()),
    );

    sl.registerLazySingleton<PathRecommendationService>(
      () => PathRecommendationService(repository: sl.get<LearningPathsRepository>()),
    );
  }
}
