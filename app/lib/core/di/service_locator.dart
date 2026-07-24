import '../../features/historical_characters/di/historical_characters_di.dart';
import '../../features/civilizations/di/civilizations_di.dart';
import '../../features/ai/di/ai_di.dart';
import '../../features/map/di/map_di.dart';
import '../../features/presentation_mode/di/presentation_mode_di.dart';
import '../../features/export/di/export_di.dart';
import '../../features/accessibility/di/accessibility_di.dart';
import '../../features/analytics/di/analytics_di.dart';
import '../../features/onboarding/di/onboarding_di.dart';
import '../../features/feedback/di/feedback_di.dart';
import '../../features/whats_new/di/whats_new_di.dart';
import '../../features/dev_tools/di/dev_tools_di.dart';
import '../../features/beta/di/beta_di.dart';
import '../../features/knowledge_base/di/knowledge_base_di.dart';
import '../../features/learning/di/learning_di.dart';
import '../../features/learning_paths/di/learning_paths_di.dart';
import '../../features/adaptive_learning/di/adaptive_learning_di.dart';
import '../../features/admin/di/admin_di.dart';
import '../navigation/navigation_service.dart';
import '../../data/datasources/era_remote_datasource.dart';
import '../../data/datasources/historical_event_remote_datasource.dart';
import '../../data/datasources/artifact_remote_datasource.dart';
import '../../data/datasources/historical_location_remote_datasource.dart';
import '../../data/repositories/era_repository_impl.dart';
import '../../data/repositories/historical_event_repository_impl.dart';
import '../../data/repositories/artifact_repository_impl.dart';
import '../../data/repositories/historical_location_repository_impl.dart';
import '../../domain/repositories/era_repository.dart';
import '../../domain/repositories/historical_event_repository.dart';
import '../../domain/repositories/artifact_repository.dart';
import '../../domain/repositories/historical_location_repository.dart';
import '../../domain/usecases/get_all_eras_usecase.dart';
import '../../domain/usecases/get_historical_events_usecase.dart';
import '../../domain/usecases/get_all_artifacts.dart';
import '../../domain/usecases/get_artifact_by_id.dart';
import '../../domain/usecases/get_artifact_by_slug.dart';
import '../../domain/usecases/get_artifacts_by_civilization.dart';
import '../../domain/usecases/get_artifacts_by_location.dart';
import '../../domain/usecases/get_all_locations.dart';
import '../../domain/usecases/get_location_by_id.dart';
import '../../domain/usecases/get_location_by_slug.dart';
import '../../domain/usecases/get_locations_by_parent.dart';
import '../../domain/usecases/get_locations_by_type.dart';
import '../../domain/usecases/get_locations_within_bounds.dart';
import '../../presentation/controllers/eras_controller.dart';
import '../../presentation/controllers/historical_events_controller.dart';
import '../../presentation/controllers/artifacts_controller.dart';
import '../../presentation/controllers/historical_locations_controller.dart';
import '../../features/search/di/search_di.dart';

/// Um Service Locator leve, puro-Dart e tipado para o ecossistema CHRONOS.
/// 
/// Permite o registro e resolução centralizada de dependências (DataSources, Repositories, UseCases, Controllers),
/// eliminando acoplamentos rígidos e viabilizando a injeção de dublês de teste (Mocks/Fakes).
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();
  
  /// Ponto de acesso unificado ao Service Locator.
  static ServiceLocator get instance => _instance;

  final Map<Type, Object Function()> _factories = {};
  final Map<Type, Object> _singletons = {};

  /// Registra um fábrica que produzirá um Singleton preguiçoso (Lazy Singleton).
  /// 
  /// A instância real será inicializada apenas no momento em que for solicitada pela primeira vez.
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _factories[T] = () {
      if (!_singletons.containsKey(T)) {
        _singletons[T] = factory();
      }
      return _singletons[T]!;
    };
  }

  /// Registra uma dependência no formato Factory.
  /// 
  /// Uma nova instância será construída toda vez que o tipo correspondente for solicitado.
  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Registra uma instância de Singleton pré-existente e imediata.
  void registerSingleton<T extends Object>(T instance) {
    _singletons[T] = instance;
    _factories[T] = () => instance;
  }

  /// Obtém a instância registrada para o tipo de objeto [T].
  /// 
  /// Lança um [StateError] caso o tipo [T] solicitado não possua registros correspondentes.
  T get<T extends Object>() {
    final factory = _factories[T];
    if (factory == null) {
      throw StateError('Nenhuma dependência registrada para o tipo especificado: $T');
    }
    return factory() as T;
  }

  /// Verifica se uma dependência está registrada para o tipo [T].
  bool isRegistered<T extends Object>() {
    return _factories.containsKey(T) || _singletons.containsKey(T);
  }

  /// Limpa todos os registros ativos, facilitando a reinicialização em suítes de testes automatizados.
  void reset() {
    _factories.clear();
    _singletons.clear();
  }
}

/// Helper global de sintaxe simplificada (atalho) para resolução de dependências no CHRONOS.
T locate<T extends Object>() => ServiceLocator.instance.get<T>();

/// Inicializa e registra todos os componentes oficiais de dependência do ecossistema CHRONOS.
void setupServiceLocator() {
  final sl = ServiceLocator.instance;
  sl.reset();

  // 0. Infraestrutura Global e Navegação
  sl.registerLazySingleton<NavigationService>(() => NavigationServiceImpl());

  // 1. Data Sources (Fontes de dados de infraestrutura)
  sl.registerLazySingleton<EraRemoteDataSource>(() => EraRemoteDataSourceImpl());
  sl.registerLazySingleton<HistoricalEventRemoteDataSource>(() => HistoricalEventRemoteDataSourceImpl());
  sl.registerLazySingleton<ArtifactRemoteDataSource>(() => ArtifactRemoteDataSourceImpl());
  sl.registerLazySingleton<HistoricalLocationRemoteDataSource>(() => HistoricalLocationRemoteDataSourceImpl());

  // 2. Repositories (Camada de dados pura/decapolada)
  sl.registerLazySingleton<EraRepository>(() => EraRepositoryImpl(sl.get<EraRemoteDataSource>()));
  sl.registerLazySingleton<HistoricalEventRepository>(() => HistoricalEventRepositoryImpl(
    remoteDataSource: sl.get<HistoricalEventRemoteDataSource>(),
  ));
  sl.registerLazySingleton<ArtifactRepository>(() => ArtifactRepositoryImpl(sl.get<ArtifactRemoteDataSource>()));
  sl.registerLazySingleton<HistoricalLocationRepository>(() => HistoricalLocationRepositoryImpl(sl.get<HistoricalLocationRemoteDataSource>()));

  // 3. Use Cases (Camada de domínio/negócio puro)
  sl.registerLazySingleton<GetAllErasUseCase>(() => GetAllErasUseCase(sl.get<EraRepository>()));
  sl.registerLazySingleton<GetHistoricalEventsUseCase>(() => GetHistoricalEventsUseCase(
    repository: sl.get<HistoricalEventRepository>(),
  ));
  sl.registerLazySingleton<GetAllArtifacts>(() => GetAllArtifacts(sl.get<ArtifactRepository>()));
  sl.registerLazySingleton<GetArtifactById>(() => GetArtifactById(sl.get<ArtifactRepository>()));
  sl.registerLazySingleton<GetArtifactBySlug>(() => GetArtifactBySlug(sl.get<ArtifactRepository>()));
  sl.registerLazySingleton<GetArtifactsByCivilization>(() => GetArtifactsByCivilization(sl.get<ArtifactRepository>()));
  sl.registerLazySingleton<GetArtifactsByLocation>(() => GetArtifactsByLocation(sl.get<ArtifactRepository>()));
  sl.registerLazySingleton<GetAllLocations>(() => GetAllLocations(sl.get<HistoricalLocationRepository>()));
  sl.registerLazySingleton<GetLocationById>(() => GetLocationById(sl.get<HistoricalLocationRepository>()));
  sl.registerLazySingleton<GetLocationBySlug>(() => GetLocationBySlug(sl.get<HistoricalLocationRepository>()));
  sl.registerLazySingleton<GetLocationsByParent>(() => GetLocationsByParent(sl.get<HistoricalLocationRepository>()));
  sl.registerLazySingleton<GetLocationsByType>(() => GetLocationsByType(sl.get<HistoricalLocationRepository>()));
  sl.registerLazySingleton<GetLocationsWithinBounds>(() => GetLocationsWithinBounds(sl.get<HistoricalLocationRepository>()));

  // 4. Controllers (Camada de apresentação/gerenciamento de estado reativo)
  sl.registerFactory<ErasController>(() => ErasController(getAllErasUseCase: sl.get<GetAllErasUseCase>()));
  sl.registerFactory<HistoricalEventsController>(() => HistoricalEventsController(
    useCase: sl.get<GetHistoricalEventsUseCase>(),
  ));
  sl.registerFactory<ArtifactsController>(() => ArtifactsController(
    getAllArtifacts: sl.get<GetAllArtifacts>(),
    getArtifactById: sl.get<GetArtifactById>(),
    getArtifactBySlug: sl.get<GetArtifactBySlug>(),
    getArtifactsByCivilization: sl.get<GetArtifactsByCivilization>(),
    getArtifactsByLocation: sl.get<GetArtifactsByLocation>(),
  ));
  sl.registerFactory<HistoricalLocationsController>(() => HistoricalLocationsController(
    getAllLocations: sl.get<GetAllLocations>(),
    getLocationById: sl.get<GetLocationById>(),
    getLocationBySlug: sl.get<GetLocationBySlug>(),
    getLocationsByParent: sl.get<GetLocationsByParent>(),
    getLocationsByType: sl.get<GetLocationsByType>(),
    getLocationsWithinBounds: sl.get<GetLocationsWithinBounds>(),
  ));
  HistoricalCharactersDI.register();
  CivilizationsDI.register();
  SearchDI.register();
  MapDI.register();
  PresentationModeDI.register();
  ExportDI.register();
  AccessibilityDI.register();
  AnalyticsDI.register();
  OnboardingDI.register();
  FeedbackDI.register();
  WhatsNewDI.register();
  DevToolsDI.register();
  BetaDI.register();
  KnowledgeBaseDI.register();
  LearningDI.register();
  LearningPathsDI.register();
  AdaptiveLearningDI.register();
  AiDI.register();
  AdminDI.register();
}

