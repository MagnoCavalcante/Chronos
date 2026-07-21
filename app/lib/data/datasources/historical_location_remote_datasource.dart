import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/base/base_remote_datasource.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/historical_location.dart';
import '../../domain/entities/publication_status.dart';
import '../models/historical_location_model.dart';

/// Contrato de fonte de dados remota de Localizações Históricas (Historical Locations).
abstract class HistoricalLocationRemoteDataSource extends BaseRemoteDataSource {
  const HistoricalLocationRemoteDataSource(super.client);

  /// Recupera todas as Localizações Históricas cadastradas.
  /// Retorna uma lista imutável de [HistoricalLocationModel].
  Future<List<HistoricalLocationModel>> getAll();

  /// Recupera todas as Localizações Históricas ativas e publicadas.
  /// Retorna uma lista imutável de [HistoricalLocationModel].
  Future<List<HistoricalLocationModel>> getAllPublished();

  /// Recupera uma Localização Histórica específica por seu identificador único.
  /// Retorna [HistoricalLocationModel].
  Future<HistoricalLocationModel> getById(String id);

  /// Recupera uma Localização Histórica específica por seu slug único.
  /// Retorna [HistoricalLocationModel].
  Future<HistoricalLocationModel> getBySlug(String slug);

  /// Recupera as Localizações Históricas que possuem uma determinada Localização pai.
  /// Retorna uma lista imutável de [HistoricalLocationModel].
  Future<List<HistoricalLocationModel>> getByParent(String parentLocationId);

  /// Recupera as Localizações Históricas filtradas por seu tipo geográfico/arqueológico.
  /// Retorna uma lista imutável de [HistoricalLocationModel].
  Future<List<HistoricalLocationModel>> getByType(LocationType type);

  /// Recupera as Localizações Históricas contidas dentro de limites de coordenadas geográficas (Bounding Box).
  /// Retorna uma lista imutável de [HistoricalLocationModel].
  Future<List<HistoricalLocationModel>> getWithinBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  );
}

/// Implementação concreta da fonte de dados remota utilizando o cliente oficial do Supabase.
class HistoricalLocationRemoteDataSourceImpl extends HistoricalLocationRemoteDataSource {
  static const String _tag = 'HistoricalLocationRemoteDataSourceImpl';

  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para DI ou testes).
  HistoricalLocationRemoteDataSourceImpl({SupabaseClient? client})
      : super(client ?? SupabaseConfig.client);

  @override
  Future<List<HistoricalLocationModel>> getAll() async {
    ChronosLogger.info('Iniciando consulta remota de todas as localizações...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .order('name', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhuma Localização Histórica cadastrada foi localizada.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalLocationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar todas as localizações');
    } catch (e) {
      _handleGenericException(e, 'buscar todas as localizações');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar todas as localizações.');
  }

  @override
  Future<List<HistoricalLocationModel>> getAllPublished() async {
    ChronosLogger.info('Iniciando consulta remota de localizações publicadas...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .eq('publication_status', PublicationStatus.published.value)
          .order('name', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhuma Localização Histórica ativa e publicada foi localizada.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalLocationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar localizações publicadas');
    } catch (e) {
      _handleGenericException(e, 'buscar localizações publicadas');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar localizações publicadas.');
  }

  @override
  Future<HistoricalLocationModel> getById(String id) async {
    ChronosLogger.info('Iniciando consulta remota de localização por id: $id...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Localização Histórica foi localizada com ID: $id.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      return HistoricalLocationModel.fromJson(response.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar localização por ID');
    } catch (e) {
      _handleGenericException(e, 'buscar localização por ID');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar localização por ID.');
  }

  @override
  Future<HistoricalLocationModel> getBySlug(String slug) async {
    ChronosLogger.info('Iniciando consulta remota de localização por slug: $slug...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .eq('slug', slug)
          .limit(1);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Localização Histórica foi localizada com Slug: $slug.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      return HistoricalLocationModel.fromJson(response.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar localização por Slug');
    } catch (e) {
      _handleGenericException(e, 'buscar localização por Slug');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar localização por Slug.');
  }

  @override
  Future<List<HistoricalLocationModel>> getByParent(String parentLocationId) async {
    ChronosLogger.info('Iniciando consulta remota de localizações por pai ID: $parentLocationId...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .eq('parent_location_id', parentLocationId)
          .order('name', ascending: true);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Localização Histórica foi localizada para o pai ID: $parentLocationId.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalLocationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar localizações por pai ID');
    } catch (e) {
      _handleGenericException(e, 'buscar localizações por pai ID');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar localizações por pai ID.');
  }

  @override
  Future<List<HistoricalLocationModel>> getByType(LocationType type) async {
    ChronosLogger.info('Iniciando consulta remota de localizações por tipo: ${type.value}...', tag: _tag);

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .eq('location_type', type.value)
          .order('name', ascending: true);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Localização Histórica foi localizada para o tipo: ${type.value}.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalLocationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar localizações por tipo');
    } catch (e) {
      _handleGenericException(e, 'buscar localizações por tipo');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar localizações por tipo.');
  }

  @override
  Future<List<HistoricalLocationModel>> getWithinBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    ChronosLogger.info(
      'Iniciando consulta remota de localizações dentro das coordenadas Lat: [$minLat, $maxLat], Lng: [$minLng, $maxLng]...',
      tag: _tag,
    );

    try {
      final List<dynamic> response = await client
          .from('historical_locations')
          .select()
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
          .gte('longitude', minLng)
          .lte('longitude', maxLng)
          .order('name', ascending: true);

      if (response.isEmpty) {
        final errorMsg = 'Nenhuma Localização Histórica foi localizada dentro dos limites informados.';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw ServerException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => HistoricalLocationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      _handlePostgrestException(e, 'buscar localizações por limites geográficos');
    } catch (e) {
      _handleGenericException(e, 'buscar localizações por limites geográficos');
    }
    throw const ServerException.unknown('Erro não mapeado ao buscar localizações por limites geográficos.');
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
