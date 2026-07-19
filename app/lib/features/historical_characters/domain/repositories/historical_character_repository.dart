import 'package:chronos/core/utils/result.dart';
import '../entities/historical_character.dart';

/// Contrato (Interface) de Repositório de HistoricalCharacter para o ecossistema CHRONOS.
abstract class HistoricalCharacterRepository {
  /// Recupera todos os personagens históricos publicados e ativos ordenados por nome.
  Future<Result<List<HistoricalCharacter>>> getAllCharacters();

  /// Recupera um personagem histórico publicado e ativo por seu ID.
  Future<Result<HistoricalCharacter>> getCharacterById(String id);

  /// Recupera um personagem histórico publicado e ativo por seu slug.
  Future<Result<HistoricalCharacter>> getCharacterBySlug(String slug);
}
