import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// DataSource base para todos os DataSources remotos no ecossistema CHRONOS.
///
/// Centraliza:
/// - Tratamento de erros
/// - Mapeamento de Failure
/// - Logs
/// - Tratamento de autenticação
/// - Tratamento de rede
/// - Tratamento de PostgrestException
///
/// Toda Feature deverá herdar esse comportamento para garantir consistência
/// no tratamento de erros e logging.
abstract class BaseRemoteDatasource<T> {
  final SupabaseClient _client;
  final String _tag;

  /// Construtor que recebe o cliente do Supabase e uma tag para logging.
  ///
  /// O cliente do Supabase pode opcionalmente ser injetado para testes.
  BaseRemoteDatasource({
    SupabaseClient? client,
    required String tag,
  })  : _client = client ?? _getDefaultClient(),
        _tag = tag;

  /// Retorna o cliente padrão do Supabase.
  ///
  /// Este método deve ser sobrescrito ou o SupabaseConfig deve estar configurado.
  SupabaseClient _getDefaultClient() {
    // Por padrão, assume que o Supabase está inicializado globalmente
    return Supabase.instance.client;
  }

  /// Getter para o cliente do Supabase.
  SupabaseClient get client => _client;

  /// Getter para a tag de logging.
  String get tag => _tag;

  /// Método template que deve ser implementado pelas subclasses para executar
  /// a lógica específica de busca de dados.
  ///
  /// Este método é chamado dentro de [executeWithErrorHandling] que fornece
  /// tratamento de erros centralizado.
  Future<List<T>> fetchData();

  /// Executa a operação de busca de dados com tratamento de erros centralizado.
  ///
  /// Este método encapsula toda a lógica de tratamento de erros comuns:
  /// - PostgrestException (erros do Supabase)
  /// - Erros de rede
  /// - Erros de autenticação
  /// - Erros de banco de dados
  /// - Logging automático
  Future<List<T>> executeWithErrorHandling() async {
    ChronosLogger.info('Iniciando consulta remota de dados...', tag: _tag);

    try {
      final result = await fetchData();

      ChronosLogger.info(
        'Consulta concluída com sucesso! Total de registros: ${result.length}',
        tag: _tag,
      );

      // Enforça imutabilidade estrutural na coleção retornada
      return List.unmodifiable(result);
    } on PostgrestException catch (e) {
      final exception = _handlePostgrestException(e);
      ChronosLogger.error(
        exception.message,
        tag: _tag,
        error: e,
      );
      throw exception;
    } on ServerException catch (e) {
      // Re-lança ServerException já tratado
      ChronosLogger.error(
        e.message,
        tag: _tag,
        error: e.originalError,
      );
      rethrow;
    } catch (e) {
      final exception = _handleGenericException(e);
      ChronosLogger.error(
        exception.message,
        tag: _tag,
        error: e,
      );
      throw exception;
    }
  }

  /// Trata exceções específicas do PostgrestException.
  ServerException _handlePostgrestException(PostgrestException e) {
    // Erros de autenticação/autorização
    if (e.code == '42501' || e.code == 'PGRST301') {
      return ServerException.authentication(
        'Acesso não autorizado: ${e.message}',
        originalError: e,
      );
    }

    // Erros de banco de dados
    return ServerException.database(
      'Erro de banco de dados: ${e.message} (Código: ${e.code})',
      originalError: e,
    );
  }

  /// Trata exceções genéricas não mapeadas.
  ServerException _handleGenericException(dynamic e) {
    final errorStr = e.toString().toLowerCase();

    // Erros de rede
    if (errorStr.contains('socketexception') ||
        errorStr.contains('connection failed') ||
        errorStr.contains('network') ||
        errorStr.contains('xmlhttprequest')) {
      return ServerException.network(
        'Falha de conectividade de rede ao comunicar com o servidor.',
        originalError: e,
      );
    }

    // Erros desconhecidos
    return ServerException.unknown(
      'Erro inesperado na fonte de dados: $e',
      originalError: e,
    );
  }

  /// Verifica se a resposta está vazia e lança exceção apropriado.
  ///
  /// Deve ser chamado pelas subclasses quando necessário.
  void throwIfEmpty(List<dynamic> response, String entityName) {
    if (response.isEmpty) {
      throw ServerException.emptyResponse(
        'Nenhum $entityName ativo foi localizado.',
      );
    }
  }
}
