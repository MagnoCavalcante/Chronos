import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';
import '../repositories/historical_location_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar localizações históricas filtradas por seu tipo geográfico/arqueológico.
class GetLocationsByType extends BaseUseCase<List<HistoricalLocation>, LocationType> {
  final HistoricalLocationRepository _repository;

  const GetLocationsByType(this._repository);

  @override
  Future<Result<List<HistoricalLocation>>> call(LocationType type) async {
    return _repository.getByType(type);
  }
}
