import '../utils/result.dart';

/// Repositório base para todos os repositórios no ecossistema CHRONOS.
///
/// Define um contrato genérico contendo operações comuns que podem ser
/// utilizadas pelas diferentes Features.
///
/// Caso alguma operação não seja utilizada por determinada Feature,
/// ela poderá ser sobrescrita ou não implementada lançando [UnimplementedError].
abstract class BaseRepository<T> {
  /// Retorna todos os registros da entidade.
  ///
  /// Encapsula o resultado em [Result] para tratamento seguro de erros.
  Future<Result<List<T>>> getAll();

  /// Retorna um registro específico pelo seu identificador único.
  ///
  /// Encapsula o resultado em [Result] para tratamento seguro de erros.
  Future<Result<T>> getById(String id);

  /// Deleta um registro específico pelo seu identificador único.
  ///
  /// Encapsula o resultado em [Result] para tratamento seguro de erros.
  Future<Result<void>> delete(String id);

  /// Salva um novo registro ou atualiza um existente.
  ///
  /// Encapsula o resultado em [Result] para tratamento seguro de erros.
  Future<Result<T>> save(T entity);

  /// Atualiza um registro existente.
  ///
  /// Encapsula o resultado em [Result] para tratamento seguro de erros.
  Future<Result<T>> update(T entity);
}
