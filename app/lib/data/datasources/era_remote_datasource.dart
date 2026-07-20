import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/base/base_remote_datasource.dart';
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
/// Extende [BaseRemoteDatasource] para centralizar tratamento de erros e logging.
class EraRemoteDataSourceImpl extends BaseRemoteDatasource<EraModel>
    implements EraRemoteDataSource {
  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para testes ou DI).
  EraRemoteDataSourceImpl({SupabaseClient? client})
      : super(
          client: client ?? SupabaseConfig.client,
          tag: 'EraRemoteDataSource',
        );

  @override
  Future<List<EraModel>> fetchData() async {
    final List<dynamic> response = await client
        .from('eras')
        .select()
        .eq('ativo', true)
        .eq('publication_status', PublicationStatus.published.value)
        .order('ordem_cronologica', ascending: true);

    throwIfEmpty(response, 'Era');

    return response
        .map((item) => EraModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EraModel>> getAllEras() async {
    return executeWithErrorHandling();
  }
}

