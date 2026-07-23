import '../../../core/di/service_locator.dart';
import '../../../core/relationships/relationship_engine.dart';
import '../../../core/timeline/timeline_repository.dart';
import '../../../domain/usecases/get_locations_within_bounds.dart';
import '../data/cache/map_cache_service.dart';
import '../data/providers/openstreetmap_provider.dart';
import '../data/services/animation_engine.dart';
import '../data/services/map_lazy_loader.dart';
import '../data/services/marker_clustering_service.dart';
import '../domain/providers/map_provider.dart';
import '../services/historical_map_engine.dart';

/// Módulo de Injeção de Dependências do sistema de mapas do CHRONOS.
class MapDI {
  static void register() {
    final sl = ServiceLocator.instance;

    // Provider abstrato — substituível por Google Maps, Mapbox, HERE no futuro
    sl.registerLazySingleton<MapProvider>(() => OpenStreetMapProvider());

    // Serviços de dados
    sl.registerLazySingleton<MarkerClusteringService>(() => MarkerClusteringService());
    sl.registerLazySingleton<MapCacheService>(() => MapCacheService());
    sl.registerLazySingleton<MapLazyLoader>(
      () => MapLazyLoader(getLocationsWithinBounds: sl.get<GetLocationsWithinBounds>()),
    );
    sl.registerLazySingleton<AnimationEngine>(
      () => AnimationEngine(mapProvider: sl.get<MapProvider>()),
    );

    // Engine central
    sl.registerLazySingleton<HistoricalMapEngine>(() => HistoricalMapEngine(
          mapProvider: sl.get<MapProvider>(),
          lazyLoader: sl.get<MapLazyLoader>(),
          clustering: sl.get<MarkerClusteringService>(),
          cache: sl.get<MapCacheService>(),
          animationEngine: sl.get<AnimationEngine>(),
          relationshipEngine: sl.get<RelationshipEngine>(),
          timelineRepository: sl.get<TimelineRepository>(),
        ));
  }
}
