import '../../domain/entities/ai_entities.dart';
import 'provider_adapter.dart';

/// Adapter stub para a API da OpenAI.
///
/// Quando [isAvailable] for true, retorna uma resposta simulada. Em uma
/// implementação futura, este adapter realizará a chamada HTTP para a API
/// `/chat/completions` usando a chave configurada.
class OpenAiAdapter extends ProviderAdapter {
  OpenAiAdapter({super.apiKey, super.apiBaseUrl});

  @override
  String get name => 'OpenAI';

  @override
  AiProviderType get type => AiProviderType.openAi;

  @override
  Future<AiResponse> buildResponse(AiRequest request) async {
    return AiResponse(
      text: 'Resposta simulada da OpenAI para: "${request.question}"\n\n'
          'Modo: ${request.mode.label}.\n'
          'Contexto carregado com ${request.searchResults.length} entidade(s) do acervo Chronos.',
      usedExternalAi: true,
      provider: type,
      latency: const Duration(milliseconds: 1200),
    );
  }
}
