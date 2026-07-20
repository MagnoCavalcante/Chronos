import 'package:chronos/core/base/base_repository.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/historical_character.dart';

/// Contrato (Interface) de Repositório de HistoricalCharacter para o ecossistema CHRONOS.
/// Extende [BaseRepository] para padronizar operações comuns.
abstract class HistoricalCharacterRepository extends BaseRepository<HistoricalCharacter> {
  /// Recupera todos os personagens históricos publicados e ativos ordenados por nome.
  Future<Result<List<HistoricalCharacter>>> getAllCharacters();

  /// Recupera um personagem histórico publicado e ativo por seu ID.
  Future<Result<HistoricalCharacter>> getCharacterById(String id);

  /// Recupera um personagem histórico publicado e ativo por seu slug.
  Future<Result<HistoricalCharacter>> getCharacterBySlug(String slug);
}
