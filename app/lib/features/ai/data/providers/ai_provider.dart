import '../../domain/entities/ai_entities.dart';

/// Interface comum para todos os provedores de IA do Chronos.
///
/// Garante que o restante do aplicativo interaja com um único contrato,
/// independente de ser OpenAI, Gemini, Claude ou modelo local.
abstract class AIProvider {
  /// Nome legível do provedor.
  String get name;

  /// Tipo do provedor.
  AiProviderType get type;

  /// Indica se o provedor pode ser utilizado no momento atual.
  bool get isAvailable;

  /// Gera uma resposta baseada no [AiRequest] enriquecido com contexto.
  Future<AiResponse> generate(AiRequest request);
}
