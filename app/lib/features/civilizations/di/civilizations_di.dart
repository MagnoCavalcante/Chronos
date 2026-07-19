import 'package:chronos/core/di/service_locator.dart';
import '../data/datasources/civilization_remote_datasource.dart';
import '../data/repositories/civilization_repository_impl.dart';
import '../domain/repositories/civilization_repository.dart';
import '../domain/usecases/get_civilizations_usecase.dart';
import '../presentation/controllers/civilizations_controller.dart';

/// Inicializador de Dependências local para a feature de Civilizations.
class CivilizationsDI {
  CivilizationsDI._();

  /// Registra todas as dependências da feature no ServiceLocator central.
  static void register() {
    final sl = ServiceLocator.instance;

    // 1. Data Source
    sl.registerLazySingleton<CivilizationRemoteDataSource>(
      () => CivilizationRemoteDataSourceImpl(),
    );

    // 2. Repository
    sl.registerLazySingleton<CivilizationRepository>(
      () => CivilizationRepositoryImpl(
        remoteDataSource: sl.get<CivilizationRemoteDataSource>(),
      ),
    );

    // 3. Use Case
    sl.registerLazySingleton<GetCivilizationsUseCase>(
      () => GetCivilizationsUseCase(
        repository: sl.get<CivilizationRepository>(),
      ),
    );

    // 4. Controller
    sl.registerFactory<CivilizationsController>(
      () => CivilizationsController(
        useCase: sl.get<GetCivilizationsUseCase>(),
      ),
    );
  }
}
