import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';
import '../repositories/historical_location_repository.dart';

/// Parâmetros necessários para a busca de localizações históricas dentro de um limite geográfico (Bounding Box).
class GetLocationsWithinBoundsParams {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const GetLocationsWithinBoundsParams({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

/// Caso de Uso (Use Case) de negócio responsável por buscar localizações históricas contidas dentro de limites de coordenadas geográficas.
class GetLocationsWithinBounds extends BaseUseCase<List<HistoricalLocation>, GetLocationsWithinBoundsParams> {
  final HistoricalLocationRepository _repository;

  const GetLocationsWithinBounds(this._repository);

  @override
  Future<Result<List<HistoricalLocation>>> call(GetLocationsWithinBoundsParams params) async {
    return _repository.getWithinBounds(
      params.minLat,
      params.maxLat,
      params.minLng,
      params.maxLng,
    );
  }
}
