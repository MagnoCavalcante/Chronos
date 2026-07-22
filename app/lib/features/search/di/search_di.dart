import 'package:chronos/core/di/service_locator.dart';
import '../data/datasources/search_remote_datasource.dart';
import '../data/repositories/supabase_search_repository.dart';
import '../domain/repositories/search_repository.dart';
import '../domain/usecases/search_use_case.dart';
import '../presentation/controllers/search_controller.dart';

class SearchDI {
  SearchDI._();

  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<SearchRemoteDataSource>(() => SupabaseSearchRemoteDataSource());
    sl.registerLazySingleton<SearchRepository>(
      () => SupabaseSearchRepository(dataSource: sl.get<SearchRemoteDataSource>()),
    );
    sl.registerLazySingleton<SearchUseCase>(() => SearchUseCase(sl.get<SearchRepository>()));
    sl.registerFactory<ChronosSearchController>(() => ChronosSearchController(search: sl.get<SearchUseCase>()));
  }
}
