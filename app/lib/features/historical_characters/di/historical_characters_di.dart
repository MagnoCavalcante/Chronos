import 'package:chronos/core/di/service_locator.dart';
import '../data/datasources/historical_character_remote_datasource.dart';
import '../data/repositories/historical_character_repository_impl.dart';
import '../domain/repositories/historical_character_repository.dart';
import '../domain/usecases/get_all_historical_characters.dart';
import '../domain/usecases/get_historical_character_by_id.dart';
import '../domain/usecases/get_historical_character_by_slug.dart';
import '../presentation/controllers/historical_characters_controller.dart';

/// Inicializador de Dependências local para a feature de HistoricalCharacters.
class HistoricalCharactersDI {
  HistoricalCharactersDI._();

  /// Registra todas as dependências da feature no ServiceLocator central.
  static void register() {
    final sl = ServiceLocator.instance;

    // 1. Data Source
    sl.registerLazySingleton<HistoricalCharacterRemoteDataSource>(
      () => HistoricalCharacterRemoteDataSourceImpl(),
    );

    // 2. Repository
    sl.registerLazySingleton<HistoricalCharacterRepository>(
      () => HistoricalCharacterRepositoryImpl(
        remoteDataSource: sl.get<HistoricalCharacterRemoteDataSource>(),
      ),
    );

    // 3. Use Cases
    sl.registerLazySingleton<GetAllHistoricalCharacters>(
      () => GetAllHistoricalCharacters(
        repository: sl.get<HistoricalCharacterRepository>(),
      ),
    );

    sl.registerLazySingleton<GetHistoricalCharacterById>(
      () => GetHistoricalCharacterById(
        repository: sl.get<HistoricalCharacterRepository>(),
      ),
    );

    sl.registerLazySingleton<GetHistoricalCharacterBySlug>(
      () => GetHistoricalCharacterBySlug(
        repository: sl.get<HistoricalCharacterRepository>(),
      ),
    );

    // 4. Controller
    sl.registerFactory<HistoricalCharactersController>(
      () => HistoricalCharactersController(
        useCase: sl.get<GetAllHistoricalCharacters>(),
      ),
    );
  }
}
