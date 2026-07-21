import 'package:chronos/core/di/service_locator.dart';
import '../data/datasources/civilization_remote_datasource.dart';
import '../data/repositories/civilization_repository_impl.dart';
import '../domain/repositories/civilization_repository.dart';
import '../domain/usecases/get_all_civilizations.dart';
import '../domain/usecases/get_civilization_by_id.dart';
import '../domain/usecases/get_civilization_by_slug.dart';
import '../presentation/controllers/civilizations_controller.dart';

/// Inicializador de Dependências local para a feature de Civilizations.
class CivilizationsDI {
  CivilizationsDI._();

  /// Registra todas as dependências da feature no ServiceLocator central.
  static void register() {
    final sl = ServiceLocator.instance;

    // 1. Data Source
    if (!sl.isRegistered<CivilizationRemoteDataSource>()) {
      sl.registerLazySingleton<CivilizationRemoteDataSource>(
        () => CivilizationRemoteDataSourceImpl(),
      );
    }

    // 2. Repository
    if (!sl.isRegistered<CivilizationRepository>()) {
      sl.registerLazySingleton<CivilizationRepository>(
        () => CivilizationRepositoryImpl(
          remoteDataSource: sl.get<CivilizationRemoteDataSource>(),
        ),
      );
    }

    // 3. Use Cases
    if (!sl.isRegistered<GetAllCivilizations>()) {
      sl.registerLazySingleton<GetAllCivilizations>(
        () => GetAllCivilizations(
          sl.get<CivilizationRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<GetCivilizationById>()) {
      sl.registerLazySingleton<GetCivilizationById>(
        () => GetCivilizationById(
          sl.get<CivilizationRepository>(),
        ),
      );
    }

    if (!sl.isRegistered<GetCivilizationBySlug>()) {
      sl.registerLazySingleton<GetCivilizationBySlug>(
        () => GetCivilizationBySlug(
          sl.get<CivilizationRepository>(),
        ),
      );
    }

    // 4. Controller
    if (!sl.isRegistered<CivilizationsController>()) {
      sl.registerFactory<CivilizationsController>(
        () => CivilizationsController(
          getAllCivilizations: sl.get<GetAllCivilizations>(),
          getCivilizationById: sl.get<GetCivilizationById>(),
          getCivilizationBySlug: sl.get<GetCivilizationBySlug>(),
        ),
      );
    }
  }
}
