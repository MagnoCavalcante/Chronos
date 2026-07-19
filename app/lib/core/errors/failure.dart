/// Estrutura base de tratamento de erros na camada de Domínio no CHRONOS.
///
/// Todas as falhas de negócios, de infraestrutura ou operacionais herdam de [Failure]
/// para garantir tratamento seguro, desacoplado e tipado.
abstract class Failure implements Exception {
  final String message;
  final Object? originalError;

  const Failure(this.message, {this.originalError});

  @override
  String toString() => '$runtimeType: $message';
}

/// Representa falhas de infraestrutura de rede, timeout ou indisponibilidade de internet.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.originalError});
}

/// Representa falhas de autorização, autenticação, tokens expirados ou violações de RLS.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.originalError});
}

/// Representa erros operacionais e de integridade no banco de dados persistente.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.originalError});
}

/// Representa violações de regras de negócios ou invalidações estruturais de dados de domínio.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.originalError});
}

/// Representa anomalias inesperadas que não se enquadram em nenhuma outra taxonomia.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.originalError});
}
