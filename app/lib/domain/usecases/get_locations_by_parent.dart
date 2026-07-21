import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';
import '../repositories/historical_location_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar localizações históricas filhas de uma localização pai específica.
class GetLocationsByParent extends BaseUseCase<List<HistoricalLocation>, String> {
  final HistoricalLocationRepository _repository;

  const GetLocationsByParent(this._repository);

  @override
  Future<Result<List<HistoricalLocation>>> call(String parentLocationId) async {
    return _repository.getByParent(parentLocationId);
  }
}
