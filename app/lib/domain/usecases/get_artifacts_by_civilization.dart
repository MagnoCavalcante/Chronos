import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/artifact.dart';
import '../repositories/artifact_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar artefatos vinculados a uma Civilização específica.
class GetArtifactsByCivilization extends BaseUseCase<List<Artifact>, String> {
  final ArtifactRepository _repository;

  const GetArtifactsByCivilization(this._repository);

  @override
  Future<Result<List<Artifact>>> call(String civilizationId) async {
    return _repository.getByCivilization(civilizationId);
  }
}
