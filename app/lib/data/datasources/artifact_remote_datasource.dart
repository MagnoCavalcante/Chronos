import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/base/base_remote_datasource.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/publication_status.dart';
import '../models/artifact_model.dart';

/// Contrato de fonte de dados remota de Artefatos (Artifacts).
abstract class ArtifactRemoteDataSource extends BaseRemoteDataSource {
  const ArtifactRemoteDataSource(super.client);

  /// Recupera todos os Artefatos ativos e publicados.
  /// Retorna uma lista imutável de [ArtifactModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<List<ArtifactModel>> getAllPublished();

  /// Recupera um Artefato específico por seu identificador único.
  /// Retorna [ArtifactModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<ArtifactModel> getById(String id);

  /// Recupera um Artefato específico por seu slug único.
  /// Retorna [ArtifactModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<ArtifactModel> getBySlug(String slug);

  /// Recupera todos os Artefatos vinculados a uma Civilização de origem específica.
  /// Retorna uma lista imutável de [ArtifactModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<List<ArtifactModel>> getByCivilization(String civilizationId);

  /// Recupera todos os Artefatos vinculados a uma Localização de origem específica.
  /// Retorna uma lista imutável de [ArtifactModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<List<ArtifactModel>> getByLocation(String locationId);

  /// Recupera a lista completa de todos os Artefatos cadastrados.
  /// Retorna uma lista imutável de [ArtifactModel].
  ///
  /// Lança uma [ServerException] em caso de falha física, rede ou banco de dados.
  Future<List<ArtifactModel>> getAll();
}

/// Implementação concreta da fonte de dados remota utilizando o cliente oficial do Supabase.
class ArtifactRemoteDataSourceImpl extends ArtifactRemoteDataSource {
  static const String _tag = 'ArtifactRemoteDataSourceImpl';

  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para DI ou testes).
  ArtifactRemoteDataSourceImpl({SupabaseClient? client})
      : super(client ?? SupabaseConfig.client);

  @override
  Future<List<ArtifactModel>> getAllPublished() async {
    ChronosLogger.info('Iniciando consulta remota de artifacts publicados...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('artifacts')
          .select()
          .eq('publication_status', PublicationStatus.published.value)
          .order('name', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhum Artifact ativo e publicado foi localizado.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => ArtifactModel.fromJson(item as Map<String, dynamic>))
          .toList();

      ChronosLogger.info(
        'Consulta de artifacts publicados concluída! Total de registros: ${models.length}',
        tag: _tag,
      );

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar artifacts publicados');
    } catch (e) {
      _handleGenericException(e, 'buscar artifacts publicados');
    }
    // O compilador precisa ver que nunca chega aqui por causa do rethrow nos handlers, mas adicionamos retorno caso necessário.
    throw const ServerException.unknown('Erro não mapeado ao buscar artifacts.');
  }

  @override
  Future<ArtifactModel> getById(String id) async {
    ChronosLogger.info('Iniciando consulta remota de artifact por id: $id...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('artifacts')
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) {
        final errorMsg = 'Nenhum Artifact foi localizado com ID: $id.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      return ArtifactModel.fromJson(response.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar artifact por ID');
    } catch (e) {
      _handleGenericException(e, 'buscar artifact por ID');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar artifact por ID.');
  }

  @override
  Future<ArtifactModel> getBySlug(String slug) async {
    ChronosLogger.info('Iniciando consulta remota de artifact por slug: $slug...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('artifacts')
          .select()
          .eq('slug', slug)
          .limit(1);

      if (response.isEmpty) {
        final errorMsg = 'Nenhum Artifact foi localizado com Slug: $slug.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      return ArtifactModel.fromJson(response.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar artifact por Slug');
    } catch (e) {
      _handleGenericException(e, 'buscar artifact por Slug');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar artifact por Slug.');
  }

  @override
  Future<List<ArtifactModel>> getByCivilization(String civilizationId) async {
    ChronosLogger.info('Iniciando consulta remota de artifacts por civilização ID: $civilizationId...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('artifacts')
          .select()
          .eq('origin_civilization_id', civilizationId)
          .order('name', ascending: true);

      if (response.isEmpty) {
        final errorMsg = 'Nenhum Artifact foi localizado para a Civilização ID: $civilizationId.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => ArtifactModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar artifacts por Civilização ID');
    } catch (e) {
      _handleGenericException(e, 'buscar artifacts por Civilização ID');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar artifacts por Civilização ID.');
  }

  @override
  Future<List<ArtifactModel>> getByLocation(String locationId) async {
    ChronosLogger.info('Iniciando consulta remota de artifacts por localização ID: $locationId...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('artifacts')
          .select()
          .eq('origin_location_id', locationId)
          .order('name', ascending: true);

      if (response.isEmpty) {
        final errorMsg = 'Nenhum Artifact foi localizado para a Localização ID: $locationId.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => ArtifactModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar artifacts por Localização ID');
    } catch (e) {
      _handleGenericException(e, 'buscar artifacts por Localização ID');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar artifacts por Localização ID.');
  }

  @override
  Future<List<ArtifactModel>> getAll() async {
    ChronosLogger.info('Iniciando consulta remota de todos os artifacts...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('artifacts')
          .select()
          .order('name', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhum Artifact cadastrado foi localizado.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => ArtifactModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar todos os artifacts');
    } catch (e) {
      _handleGenericException(e, 'buscar todos os artifacts');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar todos os artifacts.');
  }

  /// Centraliza o mapeamento e lançamento de exceções PostgrestException.
  Never _handlePostgrestException(PostgrestException e, String context) {
    if (e.code == '42501' || e.code == 'PGRST301') {
      final errorMsg = 'Acesso não autorizado ao $context: ${e.message}';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.authentication(
        errorMsg,
        originalError: e,
      );
    }

    final errorMsg = 'Erro de banco de dados ao $context: ${e.message} (Código: ${e.code})';
    ChronosLogger.error(errorMsg, tag: _tag, error: e);
    throw ServerException.database(
      errorMsg,
      originalError: e,
    );
  }

  /// Centraliza o mapeamento de exceções inesperadas e de rede.
  Never _handleGenericException(Object e, String context) {
    if (e is ServerException) rethrow;

    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('socketexception') ||
        errorStr.contains('connection failed') ||
        errorStr.contains('network') ||
        errorStr.contains('xmlhttprequest')) {
      final errorMsg = 'Falha de conectividade de rede ao $context.';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ServerException.network(
        errorMsg,
        originalError: e,
      );
    }

    final errorMsg = 'Erro inesperado na fonte de dados ao $context: $e';
    ChronosLogger.error(errorMsg, tag: _tag, error: e);
    throw ServerException.unknown(
      errorMsg,
      originalError: e,
    );
  }
}
