import '../../../core/utils/logger.dart';
import '../data/services/prompt_builder.dart';
import '../domain/entities/ai_entities.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/conversation_repository.dart';

/// Orquestrador central do Chronos AI.
///
/// Responsável por coordenar a construção do contexto RAG, a geração de
/// resposta via provedor configurado, o fallback offline e o armazenamento
/// do histórico de conversas.
class AiService {
  final PromptBuilder _promptBuilder;
  final AIRepository _repository;
  final ConversationRepository _conversation;

  static const _tag = 'AiService';

  AiService({
    required PromptBuilder promptBuilder,
    required AIRepository repository,
    required ConversationRepository conversation,
  })  : _promptBuilder = promptBuilder,
        _repository = repository,
        _conversation = conversation;

  /// Pergunta ao assistente e retorna uma resposta enriquecida.
  Future<AiResponse> ask(String question, {AiMode? mode}) async {
    final stopwatch = Stopwatch()..start();
    final request = await _promptBuilder.buildRequest(question, mode: mode);
    final response = await _repository.generate(request);
    stopwatch.stop();

    final totalLatency = response.latency == null
        ? stopwatch.elapsed
        : response.latency! + stopwatch.elapsed;
    final enriched = response.copyWith(latency: totalLatency);

    await _saveConversation(question, enriched);
    ChronosLogger.info('Resposta gerada em ${totalLatency.inMilliseconds}ms para: $question', tag: _tag);
    return enriched;
  }

  /// Retorna o histórico completo de conversas.
  Future<List<ConversationMessage>> getHistory() => _conversation.getHistory();

  /// Retorna as perguntas mais recentes.
  Future<List<ConversationMessage>> getRecent({int limit = 10}) => _conversation.getRecent(limit: limit);

  /// Retorna as mensagens favoritas.
  Future<List<ConversationMessage>> getFavorites() => _conversation.getFavorites();

  /// Retorna as mensagens fixadas.
  Future<List<ConversationMessage>> getPinned() => _conversation.getPinned();

  /// Exclui uma mensagem do histórico.
  Future<void> deleteMessage(String id) => _conversation.deleteMessage(id);

  /// Alterna o estado de favorito de uma mensagem.
  Future<ConversationMessage> toggleFavorite(String id) => _conversation.toggleFavorite(id);

  /// Alterna o estado de fixado de uma mensagem.
  Future<ConversationMessage> togglePin(String id) => _conversation.togglePin(id);

  /// Limpa todo o histórico.
  Future<void> clearHistory() => _conversation.clearHistory();

  Future<void> _saveConversation(String question, AiResponse response) async {
    final message = ConversationMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${question.hashCode}',
      question: question,
      response: response,
      timestamp: DateTime.now(),
    );
    try {
      await _conversation.saveMessage(message);
    } catch (e) {
      ChronosLogger.warn('Falha ao salvar conversa no histórico: $e', tag: _tag, error: e);
    }
  }
}
