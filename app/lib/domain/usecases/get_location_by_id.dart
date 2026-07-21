import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';
import '../repositories/historical_location_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar uma localização histórica pelo seu ID único.
class GetLocationById extends BaseUseCase<HistoricalLocation, String> {
  final HistoricalLocationRepository _repository;

  const GetLocationById(this._repository);

  @override
  Future<Result<HistoricalLocation>> call(String id) async {
    return _repository.getById(id);
  }
}
