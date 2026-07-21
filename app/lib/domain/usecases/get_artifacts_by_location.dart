import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/artifact.dart';
import '../repositories/artifact_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar artefatos vinculados a uma Localização específica.
class GetArtifactsByLocation extends BaseUseCase<List<Artifact>, String> {
  final ArtifactRepository _repository;

  const GetArtifactsByLocation(this._repository);

  @override
  Future<Result<List<Artifact>>> call(String locationId) async {
    return _repository.getByLocation(locationId);
  }
}
