import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chronos/core/config/supabase_config.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../models/historical_character_model.dart';

/// Tipos de erro de infraestrutura técnica ocorridos em chamadas de servidores remotos,
/// APIs ou bancos de dados específicos da fonte de dados de historicalCharacters.
enum HistoricalCharacterDataSourceErrorType {
  network,
  authentication,
  database,
  emptyResponse,
  unknown,
}

/// Exceção técnica específica para a infraestrutura de DataSources de HistoricalCharacter no ecossistema CHRONOS.
class HistoricalCharacterDataSourceException implements Exception {
  final String message;
  final HistoricalCharacterDataSourceErrorType type;
  final Object? originalError;

  const HistoricalCharacterDataSourceException({
    required this.message,
    required this.type,
    this.originalError,
  });

  const HistoricalCharacterDataSourceException.network(this.message, {this.originalError})
      : type = HistoricalCharacterDataSourceErrorType.network;

  const HistoricalCharacterDataSourceException.authentication(this.message, {this.originalError})
      : type = HistoricalCharacterDataSourceErrorType.authentication;

  const HistoricalCharacterDataSourceException.database(this.message, {this.originalError})
      : type = HistoricalCharacterDataSourceErrorType.database;

  const HistoricalCharacterDataSourceException.emptyResponse(this.message)
      : type = HistoricalCharacterDataSourceErrorType.emptyResponse,
        originalError = null;

  const HistoricalCharacterDataSourceException.unknown(this.message, {this.originalError})
      : type = HistoricalCharacterDataSourceErrorType.unknown;

  @override
  String toString() => 'HistoricalCharacterDataSourceException[$type]: $message';
}

/// Contrato de fonte de dados remota de HistoricalCharacter (HistoricalCharacters).
abstract class HistoricalCharacterRemoteDataSource {
  /// Recupera todos os personagens históricos ativos e publicados ordenados por nome.
  ///
  /// Retorna uma lista imutável de [HistoricalCharacterModel].
  /// Lança uma [HistoricalCharacterDataSourceException] em caso de falha física ou de rede.
  Future<List<HistoricalCharacterModel>> getAllCharacters();

  /// Recupera um personagem histórico ativo e publicado por seu ID único.
  ///
  /// Retorna um [HistoricalCharacterModel].
  /// Lança uma [HistoricalCharacterDataSourceException] em caso de falha física ou de rede.
  Future<HistoricalCharacterModel> getCharacterById(String id);

  /// Recupera um personagem histórico ativo e publicado por seu slug único.
  ///
  /// Retorna um [HistoricalCharacterModel].
  /// Lança uma [HistoricalCharacterDataSourceException] em caso de falha física ou de rede.
  Future<HistoricalCharacterModel> getCharacterBySlug(String slug);
}

/// Implementação concreta da fonte de dados remota de HistoricalCharacters utilizando o cliente oficial do Supabase.
class HistoricalCharacterRemoteDataSourceImpl implements HistoricalCharacterRemoteDataSource {
  final SupabaseClient _client;
  static const String _tag = 'HistoricalCharacterRemoteDataSource';

  HistoricalCharacterRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<HistoricalCharacterModel>> getAllCharacters() async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info('Iniciando consulta remota de todos os personagens históricos...', tag: _tag);

    try {
      final List<dynamic> response = await _client
          .from('historical_characters')
          .select()
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value)
          .order('nome', ascending: true);

      stopwatch.stop();

      if (response.isEmpty) {
        const errorMsg = 'Nenhum personagem histórico ativo e publicado foi localizado.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const HistoricalCharacterDataSourceException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalCharacterModel.fromJson(item as Map<String, dynamic>))
          .toList();

      ChronosLogger.info(
        'Consulta de personagens históricos concluída com sucesso! Total de registros: ${models.length} | Tempo de execução: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      stopwatch.stop();
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de personagens históricos: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalCharacterDataSourceException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar personagens históricos: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalCharacterDataSourceException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is HistoricalCharacterDataSourceException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        const errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalCharacterDataSourceException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de personagens históricos: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalCharacterDataSourceException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }

  @override
  Future<HistoricalCharacterModel> getCharacterById(String id) async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info('Iniciando consulta remota de personagem histórico por ID: $id...', tag: _tag);

    try {
      final List<dynamic> response = await _client
          .from('historical_characters')
          .select()
          .eq('id', id)
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value);

      stopwatch.stop();

      if (response.isEmpty) {
        final errorMsg = 'Personagem histórico ativo e publicado com ID $id não foi localizado.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw HistoricalCharacterDataSourceException.emptyResponse(errorMsg);
      }

      final model = HistoricalCharacterModel.fromJson(response.first as Map<String, dynamic>);

      ChronosLogger.info(
        'Consulta de personagem histórico por ID concluída com sucesso! Tempo de execução: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );

      return model;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados do personagem histórico por ID: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalCharacterDataSourceException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar personagem histórico por ID: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalCharacterDataSourceException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is HistoricalCharacterDataSourceException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        const errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalCharacterDataSourceException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de personagens históricos por ID: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalCharacterDataSourceException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }

  @override
  Future<HistoricalCharacterModel> getCharacterBySlug(String slug) async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info('Iniciando consulta remota de personagem histórico por slug: $slug...', tag: _tag);

    try {
      final List<dynamic> response = await _client
          .from('historical_characters')
          .select()
          .eq('slug', slug)
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value);

      stopwatch.stop();

      if (response.isEmpty) {
        final errorMsg = 'Personagem histórico ativo e publicado com slug $slug não foi localizado.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw HistoricalCharacterDataSourceException.emptyResponse(errorMsg);
      }

      final model = HistoricalCharacterModel.fromJson(response.first as Map<String, dynamic>);

      ChronosLogger.info(
        'Consulta de personagem histórico por slug concluída com sucesso! Tempo de execução: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );

      return model;
    } on PostgrestException catch (e) {
      stopwatch.stop();
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados do personagem histórico por slug: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalCharacterDataSourceException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar personagem histórico por slug: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalCharacterDataSourceException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is HistoricalCharacterDataSourceException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        const errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw HistoricalCharacterDataSourceException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de personagens históricos por slug: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw HistoricalCharacterDataSourceException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }
}
