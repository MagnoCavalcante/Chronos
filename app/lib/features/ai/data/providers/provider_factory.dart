import '../../../../core/utils/logger.dart';
import '../../domain/entities/ai_entities.dart';
import 'ai_provider.dart';
import 'claude_adapter.dart';
import 'gemini_adapter.dart';
import 'local_model_adapter.dart';
import 'offline_adapter.dart';
import 'openai_adapter.dart';

/// Factory responsável por instanciar o provedor de IA ativo.
///
/// Se nenhuma chave externa estiver configurada, utiliza [OfflineAdapter] como
/// padrão. Permite trocar entre provedores sem alterar o resto do aplicativo.
class ProviderFactory {
  static const _tag = 'ProviderFactory';

  /// Retorna o provedor mais adequado com base na configuração atual.
  static AIProvider create({
    AiProviderType? preferred,
    String? openAiApiKey,
    String? geminiApiKey,
    String? claudeApiKey,
    String? openAiBaseUrl,
    String? geminiBaseUrl,
    String? claudeBaseUrl,
  }) {
    final type = preferred ?? _resolvePreferred(openAiApiKey, geminiApiKey, claudeApiKey);

    switch (type) {
      case AiProviderType.openAi:
        return OpenAiAdapter(apiKey: openAiApiKey, apiBaseUrl: openAiBaseUrl);
      case AiProviderType.gemini:
        return GeminiAdapter(apiKey: geminiApiKey, apiBaseUrl: geminiBaseUrl);
      case AiProviderType.claude:
        return ClaudeAdapter(apiKey: claudeApiKey, apiBaseUrl: claudeBaseUrl);
      case AiProviderType.local:
        return LocalModelAdapter();
      case AiProviderType.offline:
        return OfflineAdapter();
    }
  }

  static AiProviderType _resolvePreferred(
    String? openAiApiKey,
    String? geminiApiKey,
    String? claudeApiKey,
  ) {
    if (openAiApiKey != null && openAiApiKey.isNotEmpty) return AiProviderType.openAi;
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) return AiProviderType.gemini;
    if (claudeApiKey != null && claudeApiKey.isNotEmpty) return AiProviderType.claude;
    ChronosLogger.info('Nenhuma chave de IA externa configurada. Usando OfflineAdapter.', tag: _tag);
    return AiProviderType.offline;
  }
}
