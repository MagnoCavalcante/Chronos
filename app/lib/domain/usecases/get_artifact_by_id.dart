import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/artifact.dart';
import '../repositories/artifact_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar um artefato histórico pelo seu ID único.
class GetArtifactById extends BaseUseCase<Artifact, String> {
  final ArtifactRepository _repository;

  const GetArtifactById(this._repository);

  @override
  Future<Result<Artifact>> call(String id) async {
    return _repository.getById(id);
  }
}
