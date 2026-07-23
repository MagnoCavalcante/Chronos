import '../../../core/di/service_locator.dart';
import '../data/cache/knowledge_cache_service.dart';
import '../data/datasources/knowledge_remote_datasource.dart';
import '../data/repositories/knowledge_repository_impl.dart';
import '../domain/repositories/knowledge_repository.dart';
import '../services/knowledge_graph_service.dart';

/// Módulo de DI da Knowledge Base.
class KnowledgeBaseDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<KnowledgeCacheService>(() => KnowledgeCacheService());
    sl.registerLazySingleton<KnowledgeRemoteDataSource>(() => KnowledgeRemoteDataSourceImpl());
    sl.registerLazySingleton<KnowledgeRepository>(() => KnowledgeRepositoryImpl(
          remote: sl.get<KnowledgeRemoteDataSource>(),
          cache: sl.get<KnowledgeCacheService>(),
        ));
    sl.registerLazySingleton<KnowledgeGraphService>(() => KnowledgeGraphService(
          repository: sl.get<KnowledgeRepository>(),
        ));
  }
}
