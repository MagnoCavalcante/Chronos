import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/publication_status.dart';
import '../models/historical_event_model.dart';

/// Tipos de erro de infraestrutura técnica ocorridos em chamadas de servidores remotos,
/// APIs ou bancos de dados específicos da fonte de dados de eventos históricos.
enum HistoricalEventDataSourceErrorType {
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

/// Exceção técnica específica para a infraestrutura de DataSources de Eventos Históricos no ecossistema CHRONOS.
class HistoricalEventDataSourceException implements Exception {
  final String message;
  final HistoricalEventDataSourceErrorType type;
  final Object? originalError;

  const HistoricalEventDataSourceException({
    required this.message,
    required this.type,
    this.originalError,
  });

  const HistoricalEventDataSourceException.network(this.message, {this.originalError})
      : type = HistoricalEventDataSourceErrorType.network;

  const HistoricalEventDataSourceException.authentication(this.message, {this.originalError})
      : type = HistoricalEventDataSourceErrorType.authentication;

  const HistoricalEventDataSourceException.database(this.message, {this.originalError})
      : type = HistoricalEventDataSourceErrorType.database;

  const HistoricalEventDataSourceException.emptyResponse(this.message)
      : type = HistoricalEventDataSourceErrorType.emptyResponse,
        originalError = null;

  const HistoricalEventDataSourceException.unknown(this.message, {this.originalError})
      : type = HistoricalEventDataSourceErrorType.unknown;

  @override
  String toString() => 'HistoricalEventDataSourceException[$type]: $message';
}

/// Contrato de fonte de dados remota de Eventos Históricos (Historical Events).
abstract class HistoricalEventRemoteDataSource {
  /// Recupera todos os Eventos Históricos ativos e publicados ordenados cronologicamente.
  /// Retorna uma lista imutável de [HistoricalEventModel].
  ///
  /// Lança uma [HistoricalEventDataSourceException] em caso de falha física ou de rede.
  Future<List<HistoricalEventModel>> getAllHistoricalEvents();
}

/// Implementação concreta da fonte de dados remota de Eventos Históricos utilizando o cliente oficial do Supabase.
class HistoricalEventRemoteDataSourceImpl implements HistoricalEventRemoteDataSource {
  final SupabaseClient _client;
  static const String _tag = 'HistoricalEventRemoteDataSource';

  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para testes ou DI).
  HistoricalEventRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<HistoricalEventModel>> getAllHistoricalEvents() async {
    ChronosLogger.info('Iniciando consulta remota de eventos históricos...', tag: _tag);

    try {
      // De acordo com o esquema físico do banco de dados (Sprint 4.2.1), a ordenação
      // cronológica natural para eventos históricos é representada pelo campo 'start_year'.
      final List<dynamic> response = await _client
          .from('historical_events')
          .select()
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value)
          .order('start_year', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhum evento histórico ativo e publicado foi localizado.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const HistoricalEventDataSourceException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalEventModel.fromJson(item as Map<String, dynamic>))
          .toList();

      ChronosLogger.info(
        'Consulta de eventos históricos concluída com sucesso! Total de registros: ${models.length}',
        tag: _tag,
      );

      // Enforca imutabilidade estrutural na coleção retornada (Requisito 8)
      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de eventos históricos: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalEventDataSourceException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar eventos históricos: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalEventDataSourceException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      if (e is HistoricalEventDataSourceException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        const errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalEventDataSourceException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de eventos históricos: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalEventDataSourceException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }
}
