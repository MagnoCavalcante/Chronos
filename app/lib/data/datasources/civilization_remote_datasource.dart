import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/base/base_remote_datasource.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/publication_status.dart';
import '../models/civilization_model.dart';

/// Contrato de fonte de dados remota de Civilizações (Civilizations).
abstract class CivilizationRemoteDataSource extends BaseRemoteDataSource {
  const CivilizationRemoteDataSource(super.client);

  /// Recupera todas as Civilizações ativas e publicadas.
  /// Retorna uma lista imutável de [CivilizationModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<List<CivilizationModel>> getAllPublished();

  /// Recupera uma Civilização específica por seu identificador único.
  /// Retorna [CivilizationModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<CivilizationModel> getById(String id);

  /// Recupera uma Civilização específica por seu slug único.
  /// Retorna [CivilizationModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<CivilizationModel> getBySlug(String slug);
}

/// Implementação concreta da fonte de dados remota utilizando o cliente oficial do Supabase.
class CivilizationRemoteDataSourceImpl extends CivilizationRemoteDataSource {
  static const String _tag = 'CivilizationRemoteDataSourceImpl';

  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para DI ou testes).
  CivilizationRemoteDataSourceImpl({SupabaseClient? client})
      : super(client ?? SupabaseConfig.client);

  @override
  Future<List<CivilizationModel>> getAllPublished() async {
    ChronosLogger.info('Iniciando consulta remota de civilizations...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('civilizations')
          .select()
          .eq('publication_status', PublicationStatus.published.value)
          .order('name', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhuma Civilization ativa e publicada foi localizada.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => CivilizationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      ChronosLogger.info(
        'Consulta de civilizations concluída com sucesso! Total de registros: ${models.length}',
        tag: _tag,
      );

      // Enforca imutabilidade estrutural na coleção retornada (Requisito 8)
      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de civilizations: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ServerException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar civilizations: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      if (e is ServerException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        final errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ServerException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de civilizations: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }

  @override
  Future<CivilizationModel> getById(String id) async {
    ChronosLogger.info('Iniciando consulta remota de civilization por id: $id...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('civilizations')
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Civilization foi localizada com ID: $id.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      return CivilizationModel.fromJson(response.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de civilizations: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ServerException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar civilization por ID: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      if (e is ServerException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        final errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ServerException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de civilizations: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }

  @override
  Future<CivilizationModel> getBySlug(String slug) async {
    ChronosLogger.info('Iniciando consulta remota de civilization por slug: $slug...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('civilizations')
          .select()
          .eq('slug', slug)
          .limit(1);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Civilization foi localizada com Slug: $slug.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      return CivilizationModel.fromJson(response.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de civilizations: ${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ServerException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar civilization por Slug: ${e.message} (Código: ${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      if (e is ServerException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        final errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ServerException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de civilizations: $e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }
}
