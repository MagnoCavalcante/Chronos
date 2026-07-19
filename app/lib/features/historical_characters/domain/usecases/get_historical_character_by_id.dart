import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/historical_character.dart';
import '../repositories/historical_character_repository.dart';

/// Caso de Uso (Use Case) responsável por orquestrar a recuperação de um Personagem Histórico publicado e ativo por ID.
///
/// ### Papel na Clean Architecture:
/// Representa as regras de negócio de aplicação (Application Business Rules).
/// Fica localizado exclusivamente na camada de **Domain**, atuando como núcleo lógico.
class GetHistoricalCharacterById {
  final HistoricalCharacterRepository _repository;
  static const String _tag = 'GetHistoricalCharacterById';

  /// Inicializa o caso de uso injetando de forma opcional a interface abstrata do repositório.
  GetHistoricalCharacterById({
    HistoricalCharacterRepository? repository,
  }) : _repository = repository ?? locate<HistoricalCharacterRepository>();

  /// Executa o caso de uso de negócio para recuperar o Personagem Histórico do CHRONOS pelo ID.
  ///
  /// Retorna um [Result] contendo o [HistoricalCharacter] em caso de sucesso,
  /// ou uma falha pura de negócio [Failure] em caso de erro.
  Future<Result<HistoricalCharacter>> call(String id) async {
    final stopwatch = Stopwatch()..start();
    ChronosLogger.info(
      'Iniciando a execução do caso de uso obter Personagem Histórico por ID: $id...',
      tag: _tag,
    );

    final result = await _repository.getCharacterById(id);
    stopwatch.stop();

    if (result.isSuccess) {
      ChronosLogger.info(
        'Caso de uso de obter Personagem Histórico por ID concluído com sucesso! | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );
    } else {
      final failure = result.failureOrNull;
      ChronosLogger.error(
        'Falha ocorrida durante a execução do caso de uso obter Personagem por ID: ${failure?.message} | Tempo: ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
        error: failure?.originalError,
      );
    }

    return result;
  }
}
