import 'environment.dart';

/// Configuração oficial de build e ambiente do ecossistema CHRONOS.
class BuildConfig {
  const BuildConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nmoyrkhozsomnbqepfvs.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5tb3lya2hvenNvbW5icWVwZnZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyODU5NDUsImV4cCI6MjA5OTg2MTk0NX0.WycYAClfwx1ouhzS6gNA3hh4AOmuZvnY5dKpC4VFPFM',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.chronos.local',
  );

  static const String analyticsEndpoint = String.fromEnvironment(
    'ANALYTICS_ENDPOINT',
    defaultValue: 'https://analytics.chronos.local',
  );

  static const int requestTimeoutInSeconds = 15;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;

  static ChronosEnvironment get environment {
    const value = String.fromEnvironment('CHRONOS_ENV', defaultValue: 'development');
    return value.toChronosEnvironment();
  }

  static bool get isDevelopment => environment == ChronosEnvironment.development;
  static bool get isStaging => environment == ChronosEnvironment.staging;
  static bool get isProduction => environment == ChronosEnvironment.production;
}
