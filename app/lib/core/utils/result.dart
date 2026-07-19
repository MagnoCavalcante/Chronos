import '../errors/failure.dart';

/// Uma representação segura e expressiva para retornos de operações que podem falhar,
/// promovendo o tratamento explícito de erros sem a necessidade de propagar exceções não controladas.
///
/// Segue o padrão de tipos discriminados (Either) comum no design de arquiteturas funcionais robustas.
sealed class Result<T> {
  const Result();

  /// Cria uma instância de sucesso contendo um valor.
  const factory Result.success(T value) = Success<T>;

  /// Cria uma instância de falha contendo uma [Failure].
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// Executa funções específicas com base no estado da operação.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  });

  /// Retorna true se a operação foi bem-sucedida.
  bool get isSuccess;

  /// Retorna true se a operação falhou.
  bool get isFailure;

  /// Retorna o valor de sucesso ou null se falhou.
  T? get valueOrNull;

  /// Retorna a falha de domínio ou null se teve sucesso.
  Failure? get failureOrNull;
}

/// Representa o estado de Sucesso de uma operação de negócio.
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => onSuccess(value);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T? get valueOrNull => value;

  @override
  Failure? get failureOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Representa o estado de Falha de uma operação de negócio.
class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => onFailure(failure);

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T? get valueOrNull => null;

  @override
  Failure? get failureOrNull => failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FailureResult<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'FailureResult($failure)';
}
