import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import '../../domain/entities/civilization.dart';
import '../../domain/repositories/civilization_repository.dart';
import '../datasources/civilization_remote_datasource.dart';

/// Implementação concreta do repositório de Civilization na camada de Dados (Data Layer).
class CivilizationRepositoryImpl implements CivilizationRepository {
  final CivilizationRemoteDataSource _remoteDataSource;
  static const String _tag = 'CivilizationRepositoryImpl';

  CivilizationRepositoryImpl({CivilizationRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? locate<CivilizationRemoteDataSource>();

  @override
  Future<Result<List<Civilization>>> getAllCivilizations() async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de todos(as) os(as) Civilizations...',
      tag: _tag,
    );

    try {
      final models = await _remoteDataSource.getAllCivilizations();

      ChronosLogger.info(
        'Operação concluída com sucesso! Total de registros carregados: ${models.length}',
        tag: _tag,
      );

      return Result.success(List.unmodifiable(models));
    } on CivilizationDataSourceException catch (e) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de civilizations. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
        tag: _tag,
        error: e.originalError,
      );

      Failure failure;
      switch (e.type) {
        case CivilizationDataSourceErrorType.network:
          failure = NetworkFailure(e.message, originalError: e.originalError);
          break;
        case CivilizationDataSourceErrorType.authentication:
          failure = AuthenticationFailure(e.message, originalError: e.originalError);
          break;
        case CivilizationDataSourceErrorType.database:
          failure = DatabaseFailure(e.message, originalError: e.originalError);
          break;
        case CivilizationDataSourceErrorType.emptyResponse:
          failure = ValidationFailure(e.message, originalError: e);
          break;
        case CivilizationDataSourceErrorType.unknown:
          failure = UnknownFailure(e.message, originalError: e.originalError);
          break;
      }
      return Result.failure(failure);
    } catch (e) {
      ChronosLogger.error(
        'Erro inesperado na ponte de dados do repositório de civilizations: $e',
        tag: _tag,
        error: e,
      );

      return Result.failure(UnknownFailure(
        'Erro inesperado na ponte de dados do repositório: $e',
        originalError: e,
      ));
    }
  }
}
