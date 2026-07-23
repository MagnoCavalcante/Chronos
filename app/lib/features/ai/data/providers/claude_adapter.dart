import '../../domain/entities/ai_entities.dart';
import 'provider_adapter.dart';

/// Adapter stub para a API da Anthropic Claude.
class ClaudeAdapter extends ProviderAdapter {
  ClaudeAdapter({super.apiKey, super.apiBaseUrl});

  @override
  String get name => 'Anthropic Claude';

  @override
  AiProviderType get type => AiProviderType.claude;

  @override
  Future<AiResponse> buildResponse(AiRequest request) async {
    return AiResponse(
      text: 'Resposta simulada do Anthropic Claude para: "${request.question}"\n\n'
          'Modo: ${request.mode.label}.\n'
          'Baseado em ${request.searchResults.length} entidade(s) do acervo Chronos.',
      usedExternalAi: true,
      provider: type,
      latency: const Duration(milliseconds: 1100),
    );
  }
}
