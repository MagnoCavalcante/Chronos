import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/historical_character.dart';
import '../repositories/historical_character_repository.dart';

/// Caso de Uso (Use Case) responsável por orquestrar a recuperação de todos os Personagens Históricos publicados e ativos.
///
/// ### Papel na Clean Architecture:
/// Representa as regras de negócio de aplicação (Application Business Rules).
/// Fica localizado exclusivamente na camada de **Domain**, atuando como núcleo lógico.
///
/// De acordo com os princípios da Clean Architecture:
/// - **Isolamento de Infraestrutura**: Não possui acoplamento com o Supabase, serialização JSON, ou detalhes do banco de dados.
/// - **Inversão de Dependências (DIP)**: Depende apenas da interface abstrata [HistoricalCharacterRepository].
/// - **Responsabilidade Única (SRP)**: Possui a única e exclusiva responsabilidade de coordenar a busca e registrar o fluxo de execução de negócio.
class GetAllHistoricalCharacters {
  final HistoricalCharacterRepository _repository;
  static const String _tag = 'GetAllHistoricalCharacters';

  /// Inicializa o caso de uso injetando de forma opcional a interface abstrata do repositório.
  ///
  /// Caso nenhuma dependência seja fornecida, utiliza o [ServiceLocator] para resolução automática.
  GetAllHistoricalCharacters({
    HistoricalCharacterRepository? repository,
  }) : _repository = repository ?? locate<HistoricalCharacterRepository>();

  /// Executa o caso de uso de negócio para recuperar a lista de todos os Personagens Históricos do CHRONOS.
  ///
  /// Retorna um [Result] contendo a coleção de [HistoricalCharacter]s imutáveis em caso de sucesso,
  /// ou uma falha pura de negócio [Failure] em caso de erro.
  Future<Result<List<HistoricalCharacter>>> call() async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info(
      'Iniciando a execução do caso de uso de Personagens Históricos...',
      tag: _tag,
    );

    final result = await _repository.getAllCharacters();
    stopwatch.stop();

    if (result.isSuccess) {
      final characters = result.valueOrNull ?? [];
      ChronosLogger.info(
        'Caso de uso de Personagens Históricos concluído com sucesso! Total: ${characters.length} | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );
    } else {
      final failure = result.failureOrNull;
      ChronosLogger.error(
        'Falha ocorrida durante a execução do caso de uso: ${failure?.message} | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
        error: failure?.originalError,
      );
    }

    return result;
  }
}
