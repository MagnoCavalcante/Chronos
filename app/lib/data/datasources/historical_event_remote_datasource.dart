import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/base/base_remote_datasource.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/publication_status.dart';
import '../models/historical_event_model.dart';

/// Contrato de fonte de dados remota de Eventos Históricos (Historical Events).
abstract class HistoricalEventRemoteDataSource {
  /// Recupera todos os Eventos Históricos ativos e publicados ordenados cronologicamente.
  /// Retorna uma lista imutável de [HistoricalEventModel].
  Future<List<HistoricalEventModel>> getAllHistoricalEvents();
}

/// Implementação concreta da fonte de dados remota de Eventos Históricos utilizando o cliente oficial do Supabase.
/// Extende [BaseRemoteDatasource] para centralizar tratamento de erros e logging.
/// As exceções customizadas (HistoricalEventDataSourceException) foram removidas
/// em favor do tratamento centralizado em [BaseRemoteDatasource].
class HistoricalEventRemoteDataSourceImpl extends BaseRemoteDatasource<HistoricalEventModel>
    implements HistoricalEventRemoteDataSource {
  /// Construtor que recebe de forma opcional ou externa o cliente do Supabase (para testes ou DI).
  HistoricalEventRemoteDataSourceImpl({SupabaseClient? client})
      : super(
          client: client ?? SupabaseConfig.client,
          tag: 'HistoricalEventRemoteDataSource',
        );

  @override
  Future<List<HistoricalEventModel>> fetchData() async {
    // De acordo com o esquema físico do banco de dados (Sprint 4.2.1), a ordenação
    // cronológica natural para eventos históricos é representada pelo campo 'start_year'.
    final List<dynamic> response = await client
        .from('historical_events')
        .select()
        .eq('ativo', true)
        .eq('publication_status', PublicationStatus.published.value)
        .order('start_year', ascending: true);

    throwIfEmpty(response, 'Evento Histórico');

    return response
        .map((item) => HistoricalEventModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HistoricalEventModel>> getAllHistoricalEvents() async {
    return executeWithErrorHandling();
  }
}
