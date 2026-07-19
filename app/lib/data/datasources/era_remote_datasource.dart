import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/publication_status.dart';
import '../models/era_model.dart';

/// Contrato de fonte de dados remota de Eras.
abstract class EraRemoteDataSource {
  /// Recupera todas as Eras ativas e publicadas ordendas cronologicamente.
  /// Retorna uma lista imutável de [EraModel].
  Future<List<EraModel>> getAllEras();
}

/// Implementação concreta da fonte de dados remota utilizando o cliente oficial do Supabase.
class EraRemoteDataSourceImpl implements EraRemoteDataSource {
  final SupabaseClient _client;

  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para testes ou DI).
  EraRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<EraModel>> getAllEras() async {
    try {
      final List<dynamic> response = await _client
          .from('eras')
          .select()
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value)
          .order('ordem_cronologica', ascending: true);

      if (response.isEmpty) {
        throw const ServerException.emptyResponse('Nenhuma Era ativa e publicada foi localizada.');
      }

      final models = response
          .map((item) => EraModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Enforca imutabilidade estrutural na coleção retornada (Requisito 8)
      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        throw ServerException.authentication(
          'Acesso não autorizado aos dados de eras: ${e.message}',
          originalError: e,
        );
      }
      throw ServerException.database(
        'Erro de banco de dados ao buscar eras: ${e.message} (Código: ${e.code})',
        originalError: e,
      );
    } catch (e) {
      if (e is ServerException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        throw ServerException.network(
          'Falha de conectividade de rede ao comunicar com o servidor.',
          originalError: e,
        );
      }

      throw ServerException.unknown(
        'Erro inesperado na fonte de dados: $e',
        originalError: e,
      );
    }
  }
}

