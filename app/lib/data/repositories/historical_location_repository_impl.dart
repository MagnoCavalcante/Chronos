import '../../core/base/base_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/historical_location.dart';
import '../../domain/repositories/historical_location_repository.dart';
import '../datasources/historical_location_remote_datasource.dart';

/// Implementação concreta do repositório de Localizações Históricas (Historical Locations) na camada de Dados (Data Layer).
///
/// Responsável por coordenar a busca através do [HistoricalLocationRemoteDataSource],
/// gerenciar o mapeamento de exceções específicas de infraestrutura para [Failure]s puras,
/// e realizar a transformação estrutural dos modelos de dados para entidades limpas e imutáveis de domínio.
class HistoricalLocationRepositoryImpl extends BaseRepository implements HistoricalLocationRepository {
  final HistoricalLocationRemoteDataSource _remoteDataSource;
  static const String _tag = 'HistoricalLocationRepositoryImpl';

  /// Construtor preparado para Injeção de Dependências (DI) externa.
  const HistoricalLocationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<HistoricalLocation>>> getAll() async {
    ChronosLogger.info('Iniciando a operação de carregamento de todas as Localizações...', tag: _tag);
    return safeCall<List<HistoricalLocation>>(
      () async {
        final models = await _remoteDataSource.getAll();
        final List<HistoricalLocation> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<HistoricalLocation>> getById(String id) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Localização por ID: $id...', tag: _tag);
    return safeCall<HistoricalLocation>(
      () async {
        final model = await _remoteDataSource.getById(id);
        return model.toEntity();
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<HistoricalLocation>> getBySlug(String slug) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Localização por Slug: $slug...', tag: _tag);
    return safeCall<HistoricalLocation>(
      () async {
        final model = await _remoteDataSource.getBySlug(slug);
        return model.toEntity();
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<HistoricalLocation>>> getByParent(String parentLocationId) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Localizações por pai ID: $parentLocationId...', tag: _tag);
    return safeCall<List<HistoricalLocation>>(
      () async {
        final models = await _remoteDataSource.getByParent(parentLocationId);
        final List<HistoricalLocation> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<HistoricalLocation>>> getByType(LocationType type) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Localizações por tipo: ${type.value}...', tag: _tag);
    return safeCall<List<HistoricalLocation>>(
      () async {
        final models = await _remoteDataSource.getByType(type);
        final List<HistoricalLocation> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<HistoricalLocation>>> getWithinBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    ChronosLogger.info('Iniciando a operação de carregamento de Localizações por limites geográficos...', tag: _tag);
    return safeCall<List<HistoricalLocation>>(
      () async {
        final models = await _remoteDataSource.getWithinBounds(minLat, maxLat, minLng, maxLng);
        final List<HistoricalLocation> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  @override
  Future<Result<List<HistoricalLocation>>> getPublished() async {
    ChronosLogger.info('Iniciando a operação de carregamento de todas as Localizações publicadas...', tag: _tag);
    return safeCall<List<HistoricalLocation>>(
      () async {
        final models = await _remoteDataSource.getAllPublished();
        final List<HistoricalLocation> entities = models.map((model) => model.toEntity()).toList();
        return List.unmodifiable(entities);
      },
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  Failure _mapExceptionToFailure(Object e, StackTrace stackTrace) {
    if (e is ServerException) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de localizações históricas. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
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
          return EmptyResultFailure(e.message, originalError: e);
        case ServerExceptionType.unknown:
          return UnexpectedFailure(e.message, originalError: e.originalError);
      }
    }

    ChronosLogger.error(
      'Erro inesperado na ponte de dados do repositório de localizações históricas: $e',
      tag: _tag,
      error: e,
    );

    return UnexpectedFailure(
      'Erro inesperado na ponte de dados do repositório: $e',
      originalError: e,
    );
  }
}
