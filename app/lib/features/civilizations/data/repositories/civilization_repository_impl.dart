import 'package:chronos/core/base/base_repository.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/domain/entities/civilization.dart';
import '../../domain/repositories/civilization_repository.dart';
import '../datasources/civilization_remote_datasource.dart';

/// Implementação concreta do repositório de Civilization na camada de Dados (Data Layer).
class CivilizationRepositoryImpl extends BaseRepository implements CivilizationRepository {
  final CivilizationRemoteDataSource _remoteDataSource;
  static const String _tag = 'CivilizationRepositoryImpl';

  CivilizationRepositoryImpl({CivilizationRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? locate<CivilizationRemoteDataSource>();

  @override
  Future<Result<List<Civilization>>> getAllPublished() async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de todos(as) os(as) Civilizations...',
      tag: _tag,
    );

    return safeCall<List<Civilization>>(
      () => _remoteDataSource.getAllCivilizations(),
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
      () => _remoteDataSource.getById(id),
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
      () => _remoteDataSource.getBySlug(slug),
      onError: (e, stackTrace) => _mapExceptionToFailure(e, stackTrace),
    );
  }

  Failure _mapExceptionToFailure(Object e, StackTrace stackTrace) {
    if (e is CivilizationDataSourceException) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de civilizations. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
        tag: _tag,
        error: e.originalError,
      );

      switch (e.type) {
        case CivilizationDataSourceErrorType.network:
          return NetworkFailure(e.message, originalError: e.originalError);
        case CivilizationDataSourceErrorType.authentication:
          return AuthenticationFailure(e.message, originalError: e.originalError);
        case CivilizationDataSourceErrorType.database:
          return DatabaseFailure(e.message, originalError: e.originalError);
        case CivilizationDataSourceErrorType.emptyResponse:
          return ValidationFailure(e.message, originalError: e);
        case CivilizationDataSourceErrorType.unknown:
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
