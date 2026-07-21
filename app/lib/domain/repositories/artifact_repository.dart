import '../../core/utils/result.dart';
import '../entities/artifact.dart';

/// Contrato conceitual de repositório pertencente à camada de Domínio.
///
/// Define de forma abstrata os métodos de persistência e recuperação dos Artefatos,
/// garantindo que as regras de negócio de nível superior e Casos de Uso não possuam
/// qualquer dependência direta de implementações físicas de banco de dados (ex: Supabase).
abstract class ArtifactRepository {
  /// Retorna a lista completa de todos os Artefatos cadastrados.
  Future<Result<List<Artifact>>> getAll();

  /// Retorna um Artefato pelo seu identificador único.
  Future<Result<Artifact>> getById(String id);

  /// Retorna um Artefato pelo seu slug.
  Future<Result<Artifact>> getBySlug(String slug);

  /// Retorna os Artefatos associados a uma Civilização específica.
  Future<Result<List<Artifact>>> getByCivilization(String civilizationId);

  /// Retorna os Artefatos associados a uma Localização específica.
  Future<Result<List<Artifact>>> getByLocation(String locationId);

  /// Retorna a lista completa de todos os Artefatos publicados.
  Future<Result<List<Artifact>>> getPublished();
}
