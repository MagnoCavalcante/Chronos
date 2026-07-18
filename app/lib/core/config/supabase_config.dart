import 'package:supabase_flutter/supabase_flutter.dart';

/// Gerenciador de Configuração e Inicialização do Supabase para o CHRONOS.
///
/// Concentra os parâmetros de conexão com o banco de dados em nuvem
/// e garante a inicialização segura do cliente Supabase antes do boot do app.
class SupabaseConfig {
  /// URL do Projeto Supabase.
  /// Constante direta para esta sprint. A migração para variáveis de ambiente (.env) ou dart-define será feita em sprint futura.
  static const String supabaseUrl = 'https://nmoyrkhozsomnbqepfvs.supabase.co';

  /// Chave Pública Anônima (Anon Key) do Supabase.
  /// Constante direta para esta sprint. A migração para variáveis de ambiente (.env) ou dart-define será feita em sprint futura.
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5tb3lya2hvenNvbW5icWVwZnZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyODU5NDUsImV4cCI6MjA5OTg2MTk0NX0.WycYAClfwx1ouhzS6gNA3hh4AOmuZvnY5dKpC4VFPFM';

  /// Status de inicialização do Supabase
  static bool isInitialized = false;

  /// Armazena o erro caso a inicialização falhe
  static String? initializationError;

  /// Inicializa o Supabase com as configurações do projeto.
  ///
  /// Executa o procedimento oficial assíncrono do pacote `supabase_flutter`.
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      isInitialized = true;
      initializationError = null;
    } catch (e) {
      isInitialized = false;
      initializationError = e.toString();
      print('Aviso de Inicialização do Supabase: $e');
    }
  }

  /// Retorna a instância do cliente Supabase ativo.
  static SupabaseClient get client => Supabase.instance.client;
}
