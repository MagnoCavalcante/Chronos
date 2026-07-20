import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/era.dart';
import '../../domain/repositories/era_repository.dart';
import '../datasources/era_remote_datasource.dart';

/// Implementação concreta do repositório de Eras na camada de Dados (Data Layer).
///
/// Responsável por coordenar a busca através do [EraRemoteDataSource],
/// gerenciar o mapeamento de exceções específicas de infraestrutura para [Failure]s puras,
/// e realizar a transformação estrutural dos modelos persistentes de dados em entidades imutáveis de domínio.
/// O tratamento de erros é centralizado em [BaseRemoteDatasource].
class EraRepositoryImpl implements EraRepository {
  final EraRemoteDataSource _remoteDataSource;

  /// Construtor preparado para Injeção de Dependências (DI) externa (ex: GetIt ou Provider).
  ///
  /// Garante que o repositório seja testável unitariamente de forma simples utilizando mocks.
  const EraRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<Era>>> getAllEras() async {
    try {
      // Solicita a lista de modelos de persistência
      final models = await _remoteDataSource.getAllEras();

      // Transforma modelos de dados físicos em entidades puras imutáveis de domínio
      final List<Era> entities = models.map((model) => model.toEntity()).toList();

      // Retorna uma coleção estritamente imutável para segurança das camadas superiores (Requisito 8)
      return Result.success(List.unmodifiable(entities));
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
  Future<Result<Era>> getById(String id) {
    // Não implementado para Era - pode ser adicionado no futuro
    throw UnimplementedError('getById não implementado para EraRepository');
  }

  @override
  Future<Result<void>> delete(String id) {
    // Não implementado para Era - pode ser adicionado no futuro
    throw UnimplementedError('delete não implementado para EraRepository');
  }

  @override
  Future<Result<Era>> save(Era entity) {
    // Não implementado para Era - pode ser adicionado no futuro
    throw UnimplementedError('save não implementado para EraRepository');
  }

  @override
  Future<Result<Era>> update(Era entity) {
    // Não implementado para Era - pode ser adicionado no futuro
    throw UnimplementedError('update não implementado para EraRepository');
  }
}


