import 'environment.dart';

/// Centralização das configurações físicas e de infraestrutura do CHRONOS.
/// Nenhuma feature ou tela pode possuir chaves ou URLs hardcoded.
class BuildConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogs;
  final bool enableAnalytics;

  const BuildConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableLogs,
    required this.enableAnalytics,
  });

  /// Instância atual ativa de configuração.
  static late final BuildConfig instance;

  /// Inicializa as configurações globais com base no ambiente.
  static void initialize({
    required Environment env,
    required String supabaseUrl,
    required String supabaseAnonKey,
    String? apiBaseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableLogs,
    bool? enableAnalytics,
  }) {
    instance = BuildConfig(
      environment: env,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      apiBaseUrl: apiBaseUrl ?? 'https://api.chronos-app.internal',
      connectTimeout: connectTimeout ?? const Duration(seconds: 10),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 15),
      enableLogs: enableLogs ?? (env != Environment.production),
      enableAnalytics: enableAnalytics ?? (env == Environment.production),
    );
  }
}
