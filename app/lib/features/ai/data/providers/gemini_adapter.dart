import '../../domain/entities/ai_entities.dart';
import 'provider_adapter.dart';

/// Adapter stub para a API do Google Gemini.
class GeminiAdapter extends ProviderAdapter {
  GeminiAdapter({super.apiKey, super.apiBaseUrl});

  @override
  String get name => 'Google Gemini';

  @override
  AiProviderType get type => AiProviderType.gemini;

  @override
  Future<AiResponse> buildResponse(AiRequest request) async {
    return AiResponse(
      text: 'Resposta simulada do Google Gemini para: "${request.question}"\n\n'
          'Modo: ${request.mode.label}.\n'
          'Foram consideradas ${request.searchResults.length} entidade(s) do acervo Chronos.',
      usedExternalAi: true,
      provider: type,
      latency: const Duration(milliseconds: 900),
    );
  }
}
