import '../errors/failure.dart';
import '../utils/result.dart';

/// Classe base abstrata para todos os Repositórios no CHRONOS.
/// Fornece métodos utilitários comuns de tratamento e mapeamento seguro de exceções.
abstract class BaseRepository {
  const BaseRepository();

  /// Executa uma operação assíncrona de dados encapsulando o resultado em [Result],
  /// convertendo exceções físicas do provedor em [Failure] tipadas de domínio.
  Future<Result<T>> safeCall<T>(
    Future<T> Function() call, {
    required Failure Function(Object error, StackTrace stackTrace) onError,
  }) async {
    try {
      final value = await call();
      return Result.success(value);
    } catch (e, stackTrace) {
      return Result.failure(onError(e, stackTrace));
    }
  }
}
