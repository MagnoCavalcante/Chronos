import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/artifact.dart';
import '../repositories/artifact_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por retornar todos os artefatos históricos cadastrados.
class GetAllArtifacts extends BaseUseCase<List<Artifact>, NoParams> {
  final ArtifactRepository _repository;

  const GetAllArtifacts(this._repository);

  @override
  Future<Result<List<Artifact>>> call(NoParams params) async {
    return _repository.getAll();
  }
}
