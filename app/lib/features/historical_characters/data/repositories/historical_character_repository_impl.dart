import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import '../../domain/entities/historical_character.dart';
import '../../domain/repositories/historical_character_repository.dart';
import '../datasources/historical_character_remote_datasource.dart';

/// Implementação concreta do repositório de HistoricalCharacter na camada de Dados (Data Layer).
class HistoricalCharacterRepositoryImpl implements HistoricalCharacterRepository {
  final HistoricalCharacterRemoteDataSource _remoteDataSource;
  static const String _tag = 'HistoricalCharacterRepositoryImpl';

  HistoricalCharacterRepositoryImpl({HistoricalCharacterRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? locate<HistoricalCharacterRemoteDataSource>();

  @override
  Future<Result<List<HistoricalCharacter>>> getAllCharacters() async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info(
      'Iniciando a operação de carregamento de todos os personagens históricos...',
      tag: _tag,
    );

    try {
      final models = await _remoteDataSource.getAllCharacters();
      stopwatch.stop();

      ChronosLogger.info(
        'Operação concluída com sucesso! Total de registros carregados: ${models.length} | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );

      return Result.success(List.unmodifiable(models));
    } on HistoricalCharacterDataSourceException catch (e) {
      stopwatch.stop();
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      stopwatch.stop();
      return Result.failure(_mapUnexpectedErrorToFailure(e));
    }
  }

  @override
  Future<Result<HistoricalCharacter>> getCharacterById(String id) async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info(
      'Iniciando a operação de busca do personagem histórico por ID: $id...',
      tag: _tag,
    );

    try {
      final model = await _remoteDataSource.getCharacterById(id);
      stopwatch.stop();

      ChronosLogger.info(
        'Personagem histórico por ID carregado com sucesso! | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );

      return Result.success(model);
    } on HistoricalCharacterDataSourceException catch (e) {
      stopwatch.stop();
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      stopwatch.stop();
      return Result.failure(_mapUnexpectedErrorToFailure(e));
    }
  }

  @override
  Future<Result<HistoricalCharacter>> getCharacterBySlug(String slug) async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info(
      'Iniciando a operação de busca do personagem histórico por slug: $slug...',
      tag: _tag,
    );

    try {
      final model = await _remoteDataSource.getCharacterBySlug(slug);
      stopwatch.stop();

      ChronosLogger.info(
        'Personagem histórico por slug carregado com sucesso! | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );

      return Result.success(model);
    } on HistoricalCharacterDataSourceException catch (e) {
      stopwatch.stop();
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      stopwatch.stop();
      return Result.failure(_mapUnexpectedErrorToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(HistoricalCharacterDataSourceException e) {
    ChronosLogger.error(
      'Falha ocorrida na fonte de dados de personagens históricos. Tipo de Exceção: ${e.type}. Mensagem: ${e.message}',
      tag: _tag,
      error: e.originalError,
    );

    switch (e.type) {
      case HistoricalCharacterDataSourceErrorType.network:
        return NetworkFailure(e.message, originalError: e.originalError);
      case HistoricalCharacterDataSourceErrorType.authentication:
        return AuthenticationFailure(e.message, originalError: e.originalError);
      case HistoricalCharacterDataSourceErrorType.database:
        return DatabaseFailure(e.message, originalError: e.originalError);
      case HistoricalCharacterDataSourceErrorType.emptyResponse:
        return ValidationFailure(e.message, originalError: e);
      case HistoricalCharacterDataSourceErrorType.unknown:
        return UnknownFailure(e.message, originalError: e.originalError);
    }
  }

  Failure _mapUnexpectedErrorToFailure(Object e) {
    ChronosLogger.error(
      'Erro inesperado na ponte de dados do repositório de personagens históricos: $e',
      tag: _tag,
      error: e,
    );

    return UnknownFailure(
      'Erro inesperado na ponte de dados do repositório: $e',
      originalError: e,
    );
  }
}
