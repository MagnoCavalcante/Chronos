import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';
import '../repositories/historical_location_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar uma localização histórica pelo seu slug único.
class GetLocationBySlug extends BaseUseCase<HistoricalLocation, String> {
  final HistoricalLocationRepository _repository;

  const GetLocationBySlug(this._repository);

  @override
  Future<Result<HistoricalLocation>> call(String slug) async {
    return _repository.getBySlug(slug);
  }
}
