import '../../core/base/base_repository.dart';
import '../../core/utils/result.dart';
import '../entities/era.dart';

/// Contrato conceitual de repositório pertencente à camada de Domínio.
///
/// Define de forma abstrata os métodos de persistência e recuperação das Eras,
/// garantindo que as regras de negócio de nível superior e Casos de Uso não possuam
/// qualquer dependência direta de implementações físicas de banco de dados (ex: Supabase).
/// Extende [BaseRepository] para padronizar operações comuns.
abstract class EraRepository extends BaseRepository<Era> {
  /// Retorna a lista completa de todas as Eras publicadas e ativas do ecossistema
  /// encapsulada em uma mônada de [Result].
  Future<Result<List<Era>>> getAllEras();
}

