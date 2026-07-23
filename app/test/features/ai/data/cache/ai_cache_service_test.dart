import 'package:chronos/features/ai/data/cache/ai_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiCacheService', () {
    late AiCacheService cache;

    setUp(() {
      cache = AiCacheService();
    });

    test('armazena e recupera histórico sem erros', () async {
      final entries = [
        {'id': '1', 'question': 'Quem foi Alexandre?', 'response': {'text': 'texto'}},
      ];
      await cache.cacheHistory('history', entries);
      final result = await cache.getHistory('history');
      expect(result, equals(entries));
    });

    test('armazena e recupera resposta em cache', () async {
      final response = {'text': 'Resposta Chronos', 'usedExternalAi': false, 'provider': 'offline'};
      await cache.cacheResponse('key-123', response);
      final result = await cache.getResponse('key-123');
      expect(result, equals(response));
    });

    test('retorna null para chave inexistente', () async {
      final result = await cache.getResponse('inexistente');
      expect(result, isNull);
    });

    test('limpa cache sem erros', () async {
      await cache.cacheResponse('key', {'text': 'x'});
      await cache.clearCache();
      expect(await cache.getResponse('key'), isNull);
    });
  });
}
