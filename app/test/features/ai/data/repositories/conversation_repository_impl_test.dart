import 'package:chronos/features/ai/data/cache/ai_cache_service.dart';
import 'package:chronos/features/ai/data/repositories/conversation_repository_impl.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:chronos/features/ai/domain/repositories/conversation_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversationRepositoryImpl', () {
    late ConversationRepository repository;

    setUp(() {
      repository = ConversationRepositoryImpl(cache: AiCacheService());
    });

    test('salva e retorna mensagens do histórico', () async {
      final message = _sampleMessage();
      await repository.saveMessage(message);

      final history = await repository.getHistory();
      expect(history, hasLength(1));
      expect(history.first.question, 'Quem foi Alexandre?');
    });

    test('exclui mensagem do histórico', () async {
      final message = _sampleMessage();
      await repository.saveMessage(message);
      await repository.deleteMessage(message.id);

      final history = await repository.getHistory();
      expect(history, isEmpty);
    });

    test('alterna favorito', () async {
      final message = _sampleMessage();
      await repository.saveMessage(message);

      final updated = await repository.toggleFavorite(message.id);
      expect(updated.isFavorite, isTrue);

      final favorites = await repository.getFavorites();
      expect(favorites, hasLength(1));
    });

    test('alterna fixado', () async {
      final message = _sampleMessage();
      await repository.saveMessage(message);

      final updated = await repository.togglePin(message.id);
      expect(updated.isPinned, isTrue);

      final pinned = await repository.getPinned();
      expect(pinned, hasLength(1));
    });

    test('retorna recentes respeitando o limite', () async {
      await repository.saveMessage(_sampleMessage(id: '1'));
      await repository.saveMessage(_sampleMessage(id: '2'));
      await repository.saveMessage(_sampleMessage(id: '3'));

      final recent = await repository.getRecent(limit: 2);
      expect(recent, hasLength(2));
    });

    test('limpa histórico', () async {
      await repository.saveMessage(_sampleMessage());
      await repository.clearHistory();

      final history = await repository.getHistory();
      expect(history, isEmpty);
    });
  });
}

ConversationMessage _sampleMessage({String id = 'msg-1'}) {
  return ConversationMessage(
    id: id,
    question: 'Quem foi Alexandre?',
    response: const AiResponse(text: 'Resposta'),
    timestamp: DateTime.now(),
  );
}
