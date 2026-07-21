import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';
import '../repositories/historical_location_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por retornar todas as localizações históricas cadastradas.
class GetAllLocations extends BaseUseCase<List<HistoricalLocation>, NoParams> {
  final HistoricalLocationRepository _repository;

  const GetAllLocations(this._repository);

  @override
  Future<Result<List<HistoricalLocation>>> call(NoParams params) async {
    return _repository.getAll();
  }
}
