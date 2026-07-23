import '../../domain/entities/ai_entities.dart';
import 'ai_provider.dart';

/// Base para adapters específicos de provedores de IA.
///
/// Padroniza a checagem de disponibilidade (API key) e a construção
/// da resposta, permitindo que cada provedor implemente apenas o que
/// é particular do seu protocolo.
abstract class ProviderAdapter implements AIProvider {
  final String? apiKey;
  final String? apiBaseUrl;

  ProviderAdapter({this.apiKey, this.apiBaseUrl});

  @override
  bool get isAvailable => apiKey != null && apiKey!.isNotEmpty;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    if (!isAvailable) {
      throw StateError('$name não está configurado ou indisponível.');
    }
    return buildResponse(request);
  }

  /// Constrói a resposta específica do provedor.
  Future<AiResponse> buildResponse(AiRequest request);
}
