/// Constantes de negócio, limites de paginação, timeouts e strings estáticas do CHRONOS.
class AppConstants {
  AppConstants._();

  // Paginação e Limites
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minQueryLength = 3;

  // Timeouts Padrão
  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration cacheExpiration = Duration(hours: 4);

  // Strings de Identidade / Mensagens de Negócio
  static const String appName = 'CHRONOS';
  static const String appTagline = 'História Humana Conectada';
  static const String systemPrefix = 'CHRONOS';
  
  // Mensagens estruturadas de erro genérico
  static const String unexpectedError = 'Ocorreu um erro inesperado no ecossistema CHRONOS. Por favor, tente novamente.';
  static const String networkError = 'Falha de conectividade. Verifique sua conexão com a rede.';
  static const String authenticationError = 'Sua sessão expirou ou você não possui permissão para acessar este recurso.';
}
