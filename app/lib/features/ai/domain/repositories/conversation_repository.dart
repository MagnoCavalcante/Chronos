import '../entities/ai_entities.dart';

/// Repositório de persistência do histórico de conversas do Chronos AI.
abstract class ConversationRepository {
  /// Retorna todo o histórico de conversas, ordenado do mais recente para o mais antigo.
  Future<List<ConversationMessage>> getHistory();

  /// Salva uma nova mensagem no histórico.
  Future<void> saveMessage(ConversationMessage message);

  /// Exclui uma mensagem do histórico pelo id.
  Future<void> deleteMessage(String id);

  /// Alterna o estado de favorito de uma mensagem.
  Future<ConversationMessage> toggleFavorite(String id);

  /// Alterna o estado de fixado de uma mensagem.
  Future<ConversationMessage> togglePin(String id);

  /// Retorna apenas mensagens favoritas.
  Future<List<ConversationMessage>> getFavorites();

  /// Retorna apenas mensagens fixadas.
  Future<List<ConversationMessage>> getPinned();

  /// Retorna as perguntas mais recentes (limite opcional).
  Future<List<ConversationMessage>> getRecent({int limit});

  /// Limpa todo o histórico.
  Future<void> clearHistory();
}
