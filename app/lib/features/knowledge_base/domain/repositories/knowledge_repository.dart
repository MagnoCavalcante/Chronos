import '../entities/knowledge_entities.dart';

/// Contrato do repositório da Base de Conhecimento.
///
/// Genérico para qualquer tipo de entidade (Character, Event, Civilization, etc).
abstract class KnowledgeRepository {
  /// Obtém a entry completa de conhecimento de uma entidade.
  Future<KnowledgeEntry?> getEntry(String entityId, EntityType entityType);

  /// Obtém as relações de uma entidade (saída: source→target).
  Future<List<KnowledgeRelation>> getRelations(String entityId);

  /// Obtém as relações inversas de uma entidade (entrada: target→source).
  Future<List<KnowledgeRelation>> getReverseRelations(String entityId);

  /// Obtém as fontes de uma entidade.
  Future<List<HistoricalSource>> getSources(String entityId);

  /// Obtém os debates de uma entidade.
  Future<List<HistoricalDebate>> getDebates(String entityId);

  /// Obtém as curiosidades de uma entidade.
  Future<List<HistoricalCuriosity>> getCuriosities(String entityId);

  /// Busca entries por texto.
  Future<List<KnowledgeEntry>> search(String query, {EntityType? type});
}
