/// Tipos de erro de infraestrutura técnica ocorridos em chamadas de servidores remotos,
/// APIs ou bancos de dados (ex: Supabase, HTTP, etc.).
enum ServerExceptionType {
  /// Erro de conectividade, indisponibilidade ou timeout de rede.
  network,

  /// Erro de autenticação, chaves de API inválidas, token expirado ou regras de RLS do Supabase.
  authentication,

  /// Erro interno de banco de dados ou violações de constraints relacionais.
  database,

  /// Indica que a consulta foi realizada com sucesso, mas retornou um corpo vazio quando dados eram esperados.
  emptyResponse,

  /// Erros inesperados que não correspondem a nenhuma taxonomia conhecida.
  unknown,
}

/// Exceção técnica genérica para a infraestrutura de DataSources remotos no ecossistema CHRONOS.
///
/// Serve como padrão unificado para o tratamento de erros em fontes de dados, facilitando
/// o mapeamento consistente de exceções de infraestrutura para [Failure]s na camada de repositório.
class ServerException implements Exception {
  final String message;
  final ServerExceptionType type;
  final Object? originalError;

  const ServerException({
    required this.message,
    required this.type,
    this.originalError,
  });

  const ServerException.network(this.message, {this.originalError})
      : type = ServerExceptionType.network;

  const ServerException.authentication(this.message, {this.originalError})
      : type = ServerExceptionType.authentication;

  const ServerException.database(this.message, {this.originalError})
      : type = ServerExceptionType.database;

  const ServerException.emptyResponse(this.message)
      : type = ServerExceptionType.emptyResponse,
        originalError = null;

  const ServerException.unknown(this.message, {this.originalError})
      : type = ServerExceptionType.unknown;

  @override
  String toString() => 'ServerException[$type]: $message';
}
