import '../../core/base/base_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/civilization.dart';
import '../../features/civilizations/domain/repositories/civilization_repository.dart';
import '../datasources/civilization_remote_datasource.dart';

/// Implementação concreta do repositório de Civilizações (Civilizations) na camada de Dados (Data Layer).
///
/// Responsável por coordenar a busca através do [CivilizationRemoteDataSource],
/// gerenciar o mapeamento de exceções específicas de infraestrutura para [Failure]s puras,
/// e realizar a transformação estrutural dos modelos persistentes de dados em entidades imutáveis de domínio.
class CivilizationRepositoryImpl extends BaseRepository implements CivilizationRepository {
  final CivilizationRemoteDataSource _remoteDataSource;
  static const String _tag = 'CivilizationRepositoryImpl';

  /// Construtor preparado para Injeção de Dependências (DI) externa (ex: ServiceLocator ou GetIt).
  const CivilizationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<Civilization>>> getAllPublished() async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de todas as Civilizações...',
      tag: _tag,
    );

    return safeCall<List<Civilization>>(
      () async {
        final models = await _remoteDataSource.getAllPublished();
        final List<Civilization> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<Civilization>> getById(String id) async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de Civilization por ID: $id...',
      tag: _tag,
    );

    return safeCall<Civilization>(
      () async {
        final model = await _remoteDataSource.getById(id);
        return model.toEntity();
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<Civilization>> getBySlug(String slug) async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de Civilization por Slug: $slug...',
      tag: _tag,
    );

    return safeCall<Civilization>(
      () async {
        final model = await _remoteDataSource.getBySlug(slug);
        return model.toEntity();
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  Failure _mapExceptionToFailure(Object e, StackTrace stackTrace) {
    if (e is ServerException) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de civilizations. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
        tag: _tag,
        error: e.originalError,
      );

      switch (e.type) {
        case ServerExceptionType.network:
          return NetworkFailure(e.message, originalError: e.originalError);
        case ServerExceptionType.authentication:
          return AuthenticationFailure(e.message, originalError: e.originalError);
        case ServerExceptionType.database:
          return DatabaseFailure(e.message, originalError: e.originalError);
        case ServerExceptionType.emptyResponse:
          return ValidationFailure(e.message, originalError: e);
        case ServerExceptionType.unknown:
          return UnknownFailure(e.message, originalError: e.originalError);
      }
    }

    ChronosLogger.error(
      'Erro inesperado na ponte de dados do repositório de civilizations: $e',
      tag: _tag,
      error: e,
    );

    return UnknownFailure(
      'Erro inesperado na ponte de dados do repositório: $e',
      originalError: e,
    );
  }
}
