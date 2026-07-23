import '../../domain/entities/ai_entities.dart';
import 'provider_adapter.dart';

/// Adapter para modelos locais (on-device).
///
/// Sempre disponível. Gera uma resposta resumida a partir do contexto local,
/// sem depender de rede externa. Pode ser substituído futuramente por um
/// executor de modelos como ONNX / TensorFlow Lite / ML Kit.
class LocalModelAdapter extends ProviderAdapter {
  LocalModelAdapter({super.apiKey, super.apiBaseUrl});

  @override
  String get name => 'Modelo Local';

  @override
  AiProviderType get type => AiProviderType.local;

  @override
  bool get isAvailable => true;

  @override
  Future<AiResponse> buildResponse(AiRequest request) async {
    final buffer = StringBuffer();
    buffer.writeln('Resposta gerada localmente a partir do acervo Chronos:');
    buffer.writeln();

    if (request.searchResults.isEmpty) {
      buffer.writeln(
        'Nenhuma informação relevante foi encontrada no acervo para "${request.question}". '
        'Tente reformular a pergunta.',
      );
    } else {
      buffer.writeln('Com base no acervo histórico do Chronos:');
      buffer.writeln();
      for (final result in request.searchResults) {
        buffer.writeln('• ${result.title}: ${result.summary}');
      }
    }

    return AiResponse(
      text: buffer.toString().trim(),
      usedExternalAi: false,
      provider: type,
      latency: const Duration(milliseconds: 350),
    );
  }
}
