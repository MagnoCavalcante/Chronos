import '../../core/di/service_locator.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../entities/event.dart';
import '../repositories/historical_event_repository.dart';

/// Caso de Uso (Use Case) responsável por orquestrar a recuperação de todos os Eventos Históricos publicados e ativos.
///
/// ### Papel na Clean Architecture:
/// Representa as regras de negócio de aplicação (Application Business Rules).
/// Fica localizado exclusivamente na camada de **Domain**, atuando como núcleo lógico.
///
/// De acordo com os princípios da Clean Architecture:
/// - **Isolamento de Infraestrutura**: Não possui acoplamento com o Supabase, serialização JSON,
///   ou detalhes do banco de dados.
/// - **Inversão de Dependências (DIP)**: Depende apenas da interface abstrata [HistoricalEventRepository].
/// - **Responsabilidade Única (SRP)**: Possui a única e exclusiva responsabilidade de coordenar a busca
///   e registrar o fluxo de execução de negócio.
class GetHistoricalEventsUseCase {
  final HistoricalEventRepository _repository;
  static const String _tag = 'GetHistoricalEventsUseCase';

  /// Inicializa o caso de uso injetando de forma opcional a interface abstrata do repositório.
  ///
  /// Caso nenhuma dependência seja fornecida, utiliza o [ServiceLocator] para resolução automática.
  GetHistoricalEventsUseCase({
    HistoricalEventRepository? repository,
  }) : _repository = repository ?? locate<HistoricalEventRepository>();

  /// Executa o caso de uso de negócio para recuperar a lista de Eventos Históricos do CHRONOS.
  ///
  /// Retorna um [Result] contendo a coleção de [HistoricalEvent]s imutáveis em caso de sucesso,
  /// ou uma falha pura de negócio [Failure] em caso de erro.
  Future<Result<List<HistoricalEvent>>> call() async {
    ChronosLogger.info(
      'Iniciando a execução do caso de uso de Eventos Históricos...',
      tag: _tag,
    );

    final result = await _repository.getAllHistoricalEvents();

    if (result.isSuccess) {
      final events = result.valueOrNull ?? [];
      ChronosLogger.info(
        'Caso de uso concluído com sucesso! Total de eventos retornados: ${events.length}',
        tag: _tag,
      );
    } else {
      final failure = result.failureOrNull;
      ChronosLogger.error(
        'Falha ocorrida durante a execução do caso de uso: ${failure?.message}',
        tag: _tag,
        error: failure?.originalError,
      );
    }

    return result;
  }
}
