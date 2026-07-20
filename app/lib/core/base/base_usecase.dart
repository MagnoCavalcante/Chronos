import '../errors/failure.dart';
import '../utils/result.dart';
import '../utils/logger.dart';

/// UseCase base para todos os Casos de Uso no ecossistema CHRONOS.
///
/// Generaliza:
/// - Método call() para execução do caso de uso
/// - Retorno tipado com Result<T>
/// - Tratamento de Failure
/// - Logging automático
///
/// As subclasses devem implementar o método [execute] que contém a lógica
/// específica do caso de uso.
abstract class BaseUseCase<Output, Input> {
  final String _tag;

  /// Construtor que recebe uma tag para logging.
  ///
  /// A tag deve ser o nome da classe do use case para facilitar debugging.
  const BaseUseCase({String? tag}) : _tag = tag ?? runtimeType.toString();

  /// Getter para a tag de logging.
  String get tag => _tag;

  /// Executa o caso de uso com logging automático.
  ///
  /// Este método encapsula a lógica de logging antes e após a execução,
  /// bem como o tratamento de erros inesperados.
  Future<Result<Output>> call([Input? input]) async {
    ChronosLogger.info(
      'Iniciando execução do caso de uso...',
      tag: _tag,
    );

    try {
      final result = await execute(input);

      if (result.isSuccess) {
        ChronosLogger.info(
          'Caso de uso concluído com sucesso!',
          tag: _tag,
        );
      } else {
        final failure = result.failureOrNull;
        ChronosLogger.error(
          'Falha ocorrida durante a execução do caso de uso: ${failure?.message}',
          tag: _tag,
          error: failure?.originalError,
        );
      }

      return result;
    } catch (e, stackTrace) {
      ChronosLogger.error(
        'Exceção inesperada capturada durante a execução do caso de uso: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );

      return Result.failure(
        UnknownFailure(
          'Exceção inesperada no caso de uso: $e',
          originalError: e,
        ),
      );
    }
  }

  /// Método que deve ser implementado pelas subclasses com a lógica específica.
  ///
  /// Recebe opcionalmente um parâmetro de entrada [Input] e retorna um [Result<Output>].
  Future<Result<Output>> execute([Input? input]);
}
