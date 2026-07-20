import '../../core/base/base_repository.dart';
import '../../core/utils/result.dart';
import '../entities/event.dart';

/// Contrato conceitual de repositório pertencente à camada de Domínio.
///
/// Define de forma abstrata os métodos de persistência e recuperação dos Eventos Históricos,
/// garantindo que as regras de negócio de nível superior e Casos de Uso não possuam
/// qualquer dependência direta de implementações físicas de banco de dados (ex: Supabase).
/// Extende [BaseRepository] para padronizar operações comuns.
abstract class HistoricalEventRepository extends BaseRepository<HistoricalEvent> {
  /// Retorna a lista completa de todos os Eventos Históricos publicados e ativos
  /// do ecossistema encapsulada em uma mônada de [Result].
  Future<Result<List<HistoricalEvent>>> getAllHistoricalEvents();
}
