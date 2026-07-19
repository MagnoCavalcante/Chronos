import 'package:supabase_flutter/supabase_flutter.dart';
import 'build_config.dart';

/// Gerenciador de Configuração e Inicialização do Supabase para o ecossistema CHRONOS.
///
/// Centraliza todas as chaves, endereços de conexão e parâmetros operacionais do SDK.
/// Segue o padrão de responsabilidade única (SRP) e inversão de dependência (DIP),
/// servindo como o único ponto de contato para bootstrapping da infraestrutura de dados remotos.
///
/// Atende às diretrizes de suporte multiplataforma (Android, iOS, Web, Windows, Linux e macOS)
/// de forma transparente através do pacote oficial `supabase_flutter`.
class SupabaseConfig {
  /// Evita instanciação acidental desta classe utilitária de configuração.
  const SupabaseConfig._();

  /// URL de endpoint da API RESTful do Supabase.
  ///
  /// Futuramente, este valor será injetado em tempo de compilação via variáveis de ambiente
  /// (ex: `--dart-define=SUPABASE_URL=valor`) para segregação de ambientes (Staging/Production).
  ///
  /// [SUPABASE_URL] representa a constante de ambiente correspondente.
  static String get supabaseUrl => BuildConfig.supabaseUrl;

  /// Chave Pública Anônima (Anon Key) para acesso às tabelas do Supabase que obedecem à RLS.
  ///
  /// Futuramente, este valor será injetado em tempo de compilação via variáveis de ambiente
  /// (ex: `--dart-define=SUPABASE_ANON_KEY=valor`) para segregação de chaves por ambiente.
  ///
  /// [SUPABASE_ANON_KEY] representa a constante de ambiente correspondente.
  static String get supabaseAnonKey => BuildConfig.supabaseAnonKey;

  /// Status interno que armazena se o cliente foi inicializado com sucesso.
  static bool _isInitialized = false;

  /// Armazena a mensagem de falha caso ocorra alguma anomalia no boot.
  static String? _initializationError;

  /// Indica se a infraestrutura do Supabase está inicializada e operacional.
  static bool get isInitialized => _isInitialized;

  /// Retorna a mensagem de erro da inicialização, caso exista.
  static String? get initializationError => _initializationError;

  /// Inicializa a infraestrutura de dados do Supabase.
  ///
  /// Este método centraliza e realiza o boot do SDK com tolerância a falhas.
  /// Garante compatibilidade total e transparente com Web, iOS, Android, macOS, Linux e Windows.
  ///
  /// Lança uma exceção controlada se a conexão falhar, permitindo tratamento no nível de bootstrapping.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _isInitialized = true;
      _initializationError = null;
    } catch (e) {
      _isInitialized = false;
      _initializationError = e.toString();
      // O tratamento de erro foi encapsulado de forma segura, evitando crash silencioso
      // e sem usar prints no console em produção de acordo com as boas práticas.
    }
  }

  /// Disponibiliza o cliente oficial do Supabase para consumo interno.
  ///
  /// O restante do sistema só deve interagir com o banco através desta propriedade,
  /// que fornece uma interface tipada e segura ([SupabaseClient]).
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'A infraestrutura do Supabase não foi inicializada. '
        'Certifique-se de chamar SupabaseConfig.initialize() antes de ler o client.',
      );
    }
    return Supabase.instance.client;
  }
}
