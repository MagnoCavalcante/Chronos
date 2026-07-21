import '../../core/base/base_repository.dart';
import '../../core/utils/result.dart';
import '../entities/historical_location.dart';

/// Contrato conceitual de repositório pertencente à camada de Domínio.
///
/// Define de forma abstrata os métodos de persistência e recuperação das Localizações Históricas,
/// garantindo que as regras de negócio de nível superior e Casos de Uso não possuam
/// qualquer dependência direta de implementações físicas de banco de dados (ex: Supabase).
abstract class HistoricalLocationRepository extends BaseRepository {
  const HistoricalLocationRepository();

  /// Retorna a lista completa de todas as Localizações Históricas cadastradas.
  Future<Result<List<HistoricalLocation>>> getAll();

  /// Retorna uma Localização Histórica por seu identificador único.
  Future<Result<HistoricalLocation>> getById(String id);

  /// Retorna uma Localização Histórica por seu slug único.
  Future<Result<HistoricalLocation>> getBySlug(String slug);

  /// Retorna as Localizações Históricas que possuem uma determinada Localização pai.
  Future<Result<List<HistoricalLocation>>> getByParent(String parentLocationId);

  /// Retorna as Localizações Históricas filtradas por seu tipo geográfico/arqueológico.
  Future<Result<List<HistoricalLocation>>> getByType(LocationType type);

  /// Retorna as Localizações Históricas contidas dentro de limites de coordenadas geográficas (Bounding Box).
  Future<Result<List<HistoricalLocation>>> getWithinBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  );

  /// Retorna apenas as Localizações Históricas que estão ativas e publicadas.
  Future<Result<List<HistoricalLocation>>> getPublished();
}
