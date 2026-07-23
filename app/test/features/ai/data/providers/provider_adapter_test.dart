import 'package:chronos/features/ai/data/providers/ai_provider.dart';
import 'package:chronos/features/ai/data/providers/claude_adapter.dart';
import 'package:chronos/features/ai/data/providers/gemini_adapter.dart';
import 'package:chronos/features/ai/data/providers/local_model_adapter.dart';
import 'package:chronos/features/ai/data/providers/offline_adapter.dart';
import 'package:chronos/features/ai/data/providers/openai_adapter.dart';
import 'package:chronos/features/ai/data/providers/provider_factory.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRequest extends AiRequest {
  _FakeRequest()
      : super(
          question: 'Quem foi Alexandre?',
          mode: AiMode.normal,
          prompt: 'prompt',
        );
}

void main() {
  group('ProviderFactory', () {
    test('retorna OfflineAdapter quando nenhuma chave externa é configurada', () {
      final provider = ProviderFactory.create();
      expect(provider, isA<OfflineAdapter>());
      expect(provider.isAvailable, isTrue);
    });

    test('retorna OpenAiAdapter quando openAiApiKey é fornecida', () {
      final provider = ProviderFactory.create(openAiApiKey: 'sk-test');
      expect(provider, isA<OpenAiAdapter>());
      expect(provider.isAvailable, isTrue);
    });

    test('retorna GeminiAdapter quando geminiApiKey é fornecida', () {
      final provider = ProviderFactory.create(geminiApiKey: 'g-test');
      expect(provider, isA<GeminiAdapter>());
      expect(provider.isAvailable, isTrue);
    });

    test('retorna ClaudeAdapter quando claudeApiKey é fornecida', () {
      final provider = ProviderFactory.create(claudeApiKey: 'c-test');
      expect(provider, isA<ClaudeAdapter>());
      expect(provider.isAvailable, isTrue);
    });
  });

  group('OpenAiAdapter', () {
    test('não está disponível sem chave', () {
      final adapter = OpenAiAdapter();
      expect(adapter.isAvailable, isFalse);
    });

    test('lança exceção quando indisponível', () async {
      final adapter = OpenAiAdapter();
      final request = _FakeRequest();
      expect(adapter.generate(request), throwsA(isA<StateError>()));
    });

    test('gera resposta simulada quando configurado', () async {
      final adapter = OpenAiAdapter(apiKey: 'sk-test');
      final request = _FakeRequest();
      final response = await adapter.generate(request);
      expect(response.text, contains('OpenAI'));
      expect(response.usedExternalAi, isTrue);
      expect(response.provider, AiProviderType.openAi);
    });
  });

  group('GeminiAdapter', () {
    test('gera resposta simulada quando configurado', () async {
      final adapter = GeminiAdapter(apiKey: 'g-test');
      final request = _FakeRequest();
      final response = await adapter.generate(request);
      expect(response.text, contains('Gemini'));
      expect(response.usedExternalAi, isTrue);
      expect(response.provider, AiProviderType.gemini);
    });
  });

  group('ClaudeAdapter', () {
    test('gera resposta simulada quando configurado', () async {
      final adapter = ClaudeAdapter(apiKey: 'c-test');
      final request = _FakeRequest();
      final response = await adapter.generate(request);
      expect(response.text, contains('Claude'));
      expect(response.usedExternalAi, isTrue);
      expect(response.provider, AiProviderType.claude);
    });
  });

  group('LocalModelAdapter', () {
    test('sempre está disponível e responde a partir do contexto', () async {
      final adapter = LocalModelAdapter();
      final request = _FakeRequest();
      final response = await adapter.generate(request);
      expect(response.text, contains('acervo Chronos'));
      expect(response.usedExternalAi, isFalse);
      expect(response.provider, AiProviderType.local);
    });
  });

  group('OfflineAdapter', () {
    test('sempre está disponível e responde offline', () async {
      final adapter = OfflineAdapter();
      final request = _FakeRequest();
      final response = await adapter.generate(request);
      expect(response.text, contains('offline'));
      expect(response.usedExternalAi, isFalse);
      expect(response.provider, AiProviderType.offline);
    });
  });
}
