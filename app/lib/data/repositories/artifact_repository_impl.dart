import '../../core/base/base_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/artifact.dart';
import '../../domain/repositories/artifact_repository.dart';
import '../datasources/artifact_remote_datasource.dart';

/// Implementação concreta do repositório de Artefatos (Artifacts) na camada de Dados (Data Layer).
///
/// Responsável por coordenar a busca através do [ArtifactRemoteDataSource],
/// gerenciar o mapeamento de exceções específicas de infraestrutura para [Failure]s puras,
/// e realizar a transformação estrutural dos modelos persistentes de dados em entidades imutáveis de domínio.
class ArtifactRepositoryImpl extends BaseRepository implements ArtifactRepository {
  final ArtifactRemoteDataSource _remoteDataSource;
  static const String _tag = 'ArtifactRepositoryImpl';

  /// Construtor preparado para Injeção de Dependências (DI) externa.
  const ArtifactRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<Artifact>>> getAll() async {
    ChronosLogger.info('Iniciando a operação de carregamento de todos os Artefatos...', tag: _tag);
    return safeCall<List<Artifact>>(
      () async {
        final models = await _remoteDataSource.getAll();
        final List<Artifact> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<Artifact>> getById(String id) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Artifact por ID: $id...', tag: _tag);
    return safeCall<Artifact>(
      () async {
        final model = await _remoteDataSource.getById(id);
        return model.toEntity();
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<Artifact>> getBySlug(String slug) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Artifact por Slug: $slug...', tag: _tag);
    return safeCall<Artifact>(
      () async {
        final model = await _remoteDataSource.getBySlug(slug);
        return model.toEntity();
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<Artifact>>> getByCivilization(String civilizationId) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Artifacts por Civilização ID: $civilizationId...', tag: _tag);
    return safeCall<List<Artifact>>(
      () async {
        final models = await _remoteDataSource.getByCivilization(civilizationId);
        final List<Artifact> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<Artifact>>> getByLocation(String locationId) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Artifacts por Localização ID: $locationId...', tag: _tag);
    return safeCall<List<Artifact>>(
      () async {
        final models = await _remoteDataSource.getByLocation(locationId);
        final List<Artifact> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<Artifact>>> getPublished() async {
    ChronosLogger.info('Iniciando a operação de carregamento de todos os Artefatos publicados...', tag: _tag);
    return safeCall<List<Artifact>>(
      () async {
        final models = await _remoteDataSource.getAllPublished();
        final List<Artifact> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  Failure _mapExceptionToFailure(Object e, StackTrace stackTrace) {
    if (e is ServerException) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de artifacts. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
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
      'Erro inesperado na ponte de dados do repositório de artifacts: $e',
      tag: _tag,
      error: e,
    );

    return UnknownFailure(
      'Erro inesperado na ponte de dados do repositório: $e',
      originalError: e,
    );
  }
}
