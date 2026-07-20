import '../../core/di/service_locator.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/historical_event_repository.dart';
import '../datasources/historical_event_remote_datasource.dart';

/// Implementação concreta do repositório de Eventos Históricos na camada de Dados (Data Layer).
///
/// Responsável por coordenar a busca através do [HistoricalEventRemoteDataSource],
/// gerenciar o mapeamento de exceções específicas de infraestrutura para [Failure]s puras,
/// e realizar a transformação estrutural dos modelos persistentes de dados em entidades imutáveis de domínio.
/// O tratamento de erros é centralizado em [BaseRemoteDatasource].
class HistoricalEventRepositoryImpl implements HistoricalEventRepository {
  final HistoricalEventRemoteDataSource _remoteDataSource;

  /// Construtor preparado para Injeção de Dependências (DI) externa (ex: GetIt ou ServiceLocator).
  ///
  /// Caso nenhuma dependência seja informada, utiliza o [ServiceLocator] para resolução.
  HistoricalEventRepositoryImpl({HistoricalEventRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? locate<HistoricalEventRemoteDataSource>();

  @override
  Future<Result<List<HistoricalEvent>>> getAllHistoricalEvents() async {
    try {
      // Solicita a lista de modelos de persistência remota
      final models = await _remoteDataSource.getAllHistoricalEvents();

      // Retorna uma coleção estritamente imutável para segurança das camadas superiores.
      // Como HistoricalEventModel estende Event (HistoricalEvent), a coleção é compatível.
      return Result.success(List.unmodifiable(models));
    } on ServerException catch (e) {
      // Mapeamento explícito de exceções técnicas da infraestrutura de dados para Failures do Domínio (Requisito 9)
      Failure failure;
      switch (e.type) {
        case ServerExceptionType.network:
          failure = NetworkFailure(e.message, originalError: e.originalError);
          break;
        case ServerExceptionType.authentication:
          failure = AuthenticationFailure(e.message, originalError: e.originalError);
          break;
        case ServerExceptionType.database:
          failure = DatabaseFailure(e.message, originalError: e.originalError);
          break;
        case ServerExceptionType.emptyResponse:
          failure = ValidationFailure(e.message, originalError: e);
          break;
        case ServerExceptionType.unknown:
          failure = UnknownFailure(e.message, originalError: e.originalError);
          break;
      }
      return Result.failure(failure);
    } catch (e) {
      // Captura e encapsula de forma preventiva qualquer outra anomalia inesperada de execução
      return Result.failure(UnknownFailure(
        'Erro inesperado na ponte de dados do repositório: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Result<HistoricalEvent>> getById(String id) {
    // Não implementado para HistoricalEvent - pode ser adicionado no futuro
    throw UnimplementedError('getById não implementado para HistoricalEventRepository');
  }

  @override
  Future<Result<void>> delete(String id) {
    // Não implementado para HistoricalEvent - pode ser adicionado no futuro
    throw UnimplementedError('delete não implementado para HistoricalEventRepository');
  }

  @override
  Future<Result<HistoricalEvent>> save(HistoricalEvent entity) {
    // Não implementado para HistoricalEvent - pode ser adicionado no futuro
    throw UnimplementedError('save não implementado para HistoricalEventRepository');
  }

  @override
  Future<Result<HistoricalEvent>> update(HistoricalEvent entity) {
    // Não implementado para HistoricalEvent - pode ser adicionado no futuro
    throw UnimplementedError('update não implementado para HistoricalEventRepository');
  }
}
