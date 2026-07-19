import '../../features/civilizations/di/civilizations_di.dart';
import '../../features/historical_characters/di/historical_characters_di.dart';
import '../navigation/navigation_service.dart';
import '../../data/datasources/era_remote_datasource.dart';
import '../../data/datasources/historical_event_remote_datasource.dart';
import '../../data/repositories/era_repository_impl.dart';
import '../../data/repositories/historical_event_repository_impl.dart';
import '../../domain/repositories/era_repository.dart';
import '../../domain/repositories/historical_event_repository.dart';
import '../../domain/usecases/get_all_eras_usecase.dart';
import '../../domain/usecases/get_historical_events_usecase.dart';
import '../../presentation/controllers/eras_controller.dart';
import '../../presentation/controllers/historical_events_controller.dart';

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

  // 0. Infraestrutura Global e Navegação
  sl.registerLazySingleton<NavigationService>(() => NavigationServiceImpl());

  // 1. Data Sources (Fontes de dados de infraestrutura)
  sl.registerLazySingleton<EraRemoteDataSource>(() => EraRemoteDataSourceImpl());
  sl.registerLazySingleton<HistoricalEventRemoteDataSource>(() => HistoricalEventRemoteDataSourceImpl());

  // 2. Repositories (Camada de dados pura/decapolada)
  sl.registerLazySingleton<EraRepository>(() => EraRepositoryImpl(sl.get<EraRemoteDataSource>()));
  sl.registerLazySingleton<HistoricalEventRepository>(() => HistoricalEventRepositoryImpl(
    remoteDataSource: sl.get<HistoricalEventRemoteDataSource>(),
  ));

  // 3. Use Cases (Camada de domínio/negócio puro)
  sl.registerLazySingleton<GetAllErasUseCase>(() => GetAllErasUseCase(sl.get<EraRepository>()));
  sl.registerLazySingleton<GetHistoricalEventsUseCase>(() => GetHistoricalEventsUseCase(
    repository: sl.get<HistoricalEventRepository>(),
  ));

  // 4. Controllers (Camada de apresentação/gerenciamento de estado reativo)
  sl.registerFactory<ErasController>(() => ErasController(getAllErasUseCase: sl.get<GetAllErasUseCase>()));
  sl.registerFactory<HistoricalEventsController>(() => HistoricalEventsController(
    useCase: sl.get<GetHistoricalEventsUseCase>(),
  ));
  HistoricalCharactersDI.register();
  CivilizationsDI.register();
}

