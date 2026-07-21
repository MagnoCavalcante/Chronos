import '../../core/di/service_locator.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/historical_event_repository.dart';
import '../datasources/historical_event_remote_datasource.dart';

/// Implementação concreta do repositório de Eventos Históricos na camada de Dados (Data Layer).
///
/// Responsável por coordenar a busca através do [HistoricalEventRemoteDataSource],
/// gerenciar o mapeamento de exceções específicas de infraestrutura para [Failure]s puras,
/// e realizar a transformação estrutural dos modelos persistentes de dados em entidades imutáveis de domínio.
class HistoricalEventRepositoryImpl implements HistoricalEventRepository {
  final HistoricalEventRemoteDataSource _remoteDataSource;
  static const String _tag = 'HistoricalEventRepositoryImpl';

  /// Construtor preparado para Injeção de Dependências (DI) externa (ex: GetIt ou ServiceLocator).
  ///
  /// Caso nenhuma dependência seja informada, utiliza o [ServiceLocator] para resolução.
  HistoricalEventRepositoryImpl({HistoricalEventRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? locate<HistoricalEventRemoteDataSource>();

  @override
  Future<Result<List<HistoricalEvent>>> getAllHistoricalEvents() async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de todos os Eventos Históricos...',
      tag: _tag,
    );

    try {
      // Solicita a lista de modelos de persistência remota
      final models = await _remoteDataSource.getAllHistoricalEvents();

      ChronosLogger.info(
        'Operação concluída com sucesso! Total de registros carregados: ${models.length}',
        tag: _tag,
      );

      // Retorna uma coleção estritamente imutável para segurança das camadas superiores.
      // Como HistoricalEventModel estende Event (HistoricalEvent), a coleção é compatível.
      return Result.success(List.unmodifiable(models));
    } on HistoricalEventDataSourceException catch (e) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de eventos históricos. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
        tag: _tag,
        error: e.originalError,
      );

      Failure failure;
      switch (e.type) {
        case HistoricalEventDataSourceErrorType.network:
          failure = NetworkFailure(e.message, originalError: e.originalError);
          break;
        case HistoricalEventDataSourceErrorType.authentication:
          failure = AuthenticationFailure(e.message, originalError: e.originalError);
          break;
        case HistoricalEventDataSourceErrorType.database:
          failure = DatabaseFailure(e.message, originalError: e.originalError);
          break;
        case HistoricalEventDataSourceErrorType.emptyResponse:
          failure = ValidationFailure(e.message, originalError: e);
          break;
        case HistoricalEventDataSourceErrorType.unknown:
          failure = UnknownFailure(e.message, originalError: e.originalError);
          break;
      }
      return Result.failure(failure);
    } catch (e) {
      ChronosLogger.error(
        'Erro inesperado na ponte de dados do repositório de eventos históricos: $e',
        tag: _tag,
        error: e,
      );

      // Captura e encapsula de forma preventiva qualquer outra anomalia inesperada de execução
      return Result.failure(UnknownFailure(
        'Erro inesperado na ponte de dados do repositório: $e',
        originalError: e,
      ));
    }
  }
}
