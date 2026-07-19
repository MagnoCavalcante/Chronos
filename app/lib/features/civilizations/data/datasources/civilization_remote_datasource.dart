import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chronos/core/config/supabase_config.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../models/civilization_model.dart';

/// Tipos de erro de infraestrutura técnica ocorridos em chamadas de servidores remotos,
/// APIs ou bancos de dados específicos da fonte de dados de civilizations.
enum CivilizationDataSourceErrorType {
  network,
  authentication,
  database,
  emptyResponse,
  unknown,
}

/// Exceção técnica específica para a infraestrutura de DataSources de Civilization no ecossistema CHRONOS.
class CivilizationDataSourceException implements Exception {
  final String message;
  final CivilizationDataSourceErrorType type;
  final Object? originalError;

  const CivilizationDataSourceException({
    required this.message,
    required this.type,
    this.originalError,
  });

  const CivilizationDataSourceException.network(this.message, {this.originalError})
      : type = CivilizationDataSourceErrorType.network;

  const CivilizationDataSourceException.authentication(this.message, {this.originalError})
      : type = CivilizationDataSourceErrorType.authentication;

  const CivilizationDataSourceException.database(this.message, {this.originalError})
      : type = CivilizationDataSourceErrorType.database;

  const CivilizationDataSourceException.emptyResponse(this.message)
      : type = CivilizationDataSourceErrorType.emptyResponse,
        originalError = null;

  const CivilizationDataSourceException.unknown(this.message, {this.originalError})
      : type = CivilizationDataSourceErrorType.unknown;

  @override
  String toString() => 'CivilizationDataSourceException[$type]: $message';
}

/// Contrato de fonte de dados remota de Civilization (Civilizations).
abstract class CivilizationRemoteDataSource {
  /// Recupera todos(as) os(as) Civilizations ativos(as) e publicados(as).
  ///
  /// Retorna uma lista imutável de [CivilizationModel].
  /// Lança uma [CivilizationDataSourceException] em caso de falha física ou de rede.
  Future<List<CivilizationModel>> getAllCivilizations();
}

/// Implementação concreta da fonte de dados remota de Civilizations utilizando o cliente oficial do Supabase.
class CivilizationRemoteDataSourceImpl implements CivilizationRemoteDataSource {
  final SupabaseClient _client;
  static const String _tag = 'CivilizationRemoteDataSource';

  CivilizationRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<CivilizationModel>> getAllCivilizations() async {
    ChronosLogger.info('Iniciando consulta remota de civilizations...', tag: _tag);

    try {
      final List<dynamic> response = await _client
          .from('civilizations')
          .select()
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value)
          .order('nome', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhum(a) Civilization ativo(a) e publicado(a) foi localizado(a).';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const CivilizationDataSourceException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => CivilizationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      ChronosLogger.info(
        'Consulta de civilizations concluída com sucesso! Total de registros: ${models.length}',
        tag: _tag,
      );

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de civilizations: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw CivilizationDataSourceException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar civilizations: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw CivilizationDataSourceException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      if (e is CivilizationDataSourceException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        final errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw CivilizationDataSourceException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de civilizations: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw CivilizationDataSourceException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }
}
