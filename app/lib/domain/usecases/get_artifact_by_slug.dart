import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/artifact.dart';
import '../repositories/artifact_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar um artefato histórico pelo seu slug único.
class GetArtifactBySlug extends BaseUseCase<Artifact, String> {
  final ArtifactRepository _repository;

  const GetArtifactBySlug(this._repository);

  @override
  Future<Result<Artifact>> call(String slug) async {
    return _repository.getBySlug(slug);
  }
}
