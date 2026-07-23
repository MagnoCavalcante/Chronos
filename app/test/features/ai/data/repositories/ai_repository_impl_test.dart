import 'package:chronos/features/ai/data/cache/ai_cache_service.dart';
import 'package:chronos/features/ai/data/providers/ai_provider.dart';
import 'package:chronos/features/ai/data/providers/offline_adapter.dart';
import 'package:chronos/features/ai/data/providers/openai_adapter.dart';
import 'package:chronos/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:chronos/features/ai/domain/repositories/ai_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingProvider implements AIProvider {
  @override
  String get name => 'FailingProvider';

  @override
  AiProviderType get type => AiProviderType.openAi;

  @override
  bool get isAvailable => true;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    throw StateError('Provedor falhou');
  }
}

void main() {
  group('AIRepositoryImpl', () {
    late AIRepository repository;
    late AiCacheService cache;

    setUp(() {
      cache = AiCacheService();
      repository = AIRepositoryImpl(cache: cache);
    });

    test('responde offline por padrão quando nenhum provedor é configurado', () async {
      final request = AiRequest(
        question: 'Quem foi Alexandre?',
        mode: AiMode.normal,
        prompt: 'prompt',
      );
      final response = await repository.generate(request);
      expect(response.provider, AiProviderType.offline);
      expect(response.usedExternalAi, isFalse);
    });

    test('cai para offline quando o provedor principal falha', () async {
      repository = AIRepositoryImpl(
        primaryProvider: _FailingProvider(),
        cache: cache,
      );
      final request = AiRequest(
        question: 'Quem foi Alexandre?',
        mode: AiMode.normal,
        prompt: 'prompt',
      );
      final response = await repository.generate(request);
      expect(response.provider, AiProviderType.offline);
      expect(response.text, contains('offline'));
    });

    test('retorna resposta do cache quando já existe', () async {
      final request = AiRequest(
        question: 'Quem foi Alexandre?',
        mode: AiMode.normal,
        prompt: 'prompt',
      );
      await repository.generate(request);
      final second = await repository.generate(request);
      expect(second.provider, AiProviderType.offline);
      expect(second.latency, isNotNull);
    });

    test('getCached retorna null para chave inexistente', () async {
      final response = await repository.getCached('inexistente');
      expect(response, isNull);
    });
  });
}
