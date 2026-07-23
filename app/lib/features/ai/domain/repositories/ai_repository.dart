import '../entities/ai_entities.dart';

/// Repositório responsável por gerar e recuperar respostas do Chronos AI.
///
/// Pode utilizar provedores externos, cache local e fallback 100% offline.
abstract class AIRepository {
  /// Gera uma resposta para a pergunta representada por [request].
  Future<AiResponse> generate(AiRequest request);

  /// Recupera uma resposta em cache, se existir.
  Future<AiResponse?> getCached(String cacheKey);

  /// Armazena uma resposta no cache.
  Future<void> cache(String cacheKey, AiResponse response);
}
