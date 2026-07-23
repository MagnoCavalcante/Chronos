import 'package:chronos/core/relationships/relationship_engine.dart';
import 'package:chronos/core/timeline/timeline_repository.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/features/ai/data/services/prompt_builder.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:chronos/features/ai/domain/repositories/ai_repository.dart';
import 'package:chronos/features/ai/domain/repositories/conversation_repository.dart';
import 'package:chronos/features/ai/services/ai_service.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';
import 'package:chronos/features/search/domain/repositories/search_repository.dart';
import 'package:chronos/features/search/domain/usecases/search_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSearchRepo implements SearchRepository {
  @override
  Future<Result<SearchPage>> search(SearchQuery query) async {
    return Result.success(const SearchPage(results: [], hasMore: false));
  }
}

class _FakeSearchUseCase extends SearchUseCase {
  _FakeSearchUseCase() : super(_FakeSearchRepo());
}

class _FakePromptBuilder extends PromptBuilder {
  _FakePromptBuilder()
      : super(
          search: _FakeSearchUseCase(),
          relationshipEngine: RelationshipEngine(),
          timelineRepository: TimelineRepository(),
        );

  @override
  Future<AiRequest> buildRequest(String question, {AiMode? mode}) async {
    return AiRequest(
      question: question,
      mode: mode ?? AiMode.normal,
      prompt: 'prompt',
    );
  }
}

class _FakeAIRepository implements AIRepository {
  @override
  Future<AiResponse> generate(AiRequest request) async {
    return const AiResponse(
      text: 'Resposta do acervo',
      usedExternalAi: false,
      provider: AiProviderType.offline,
      suggestedQuestions: ['Sugestão 1'],
    );
  }

  @override
  Future<AiResponse?> getCached(String cacheKey) async => null;

  @override
  Future<void> cache(String cacheKey, AiResponse response) async {}
}

class _FakeConversationRepository implements ConversationRepository {
  final List<ConversationMessage> _messages = [];

  @override
  Future<List<ConversationMessage>> getHistory() async => _messages.reversed.toList();

  @override
  Future<void> saveMessage(ConversationMessage message) async {
    _messages.removeWhere((m) => m.id == message.id);
    _messages.add(message);
  }

  @override
  Future<void> deleteMessage(String id) async => _messages.removeWhere((m) => m.id == id);

  @override
  Future<ConversationMessage> toggleFavorite(String id) async => _messages.first;

  @override
  Future<ConversationMessage> togglePin(String id) async => _messages.first;

  @override
  Future<List<ConversationMessage>> getFavorites() async => [];

  @override
  Future<List<ConversationMessage>> getPinned() async => [];

  @override
  Future<List<ConversationMessage>> getRecent({int limit = 10}) async => _messages.reversed.take(limit).toList();

  @override
  Future<void> clearHistory() async => _messages.clear();
}

void main() {
  group('AiService', () {
    late AiService service;
    late _FakeConversationRepository conversation;

    setUp(() {
      conversation = _FakeConversationRepository();
      service = AiService(
        promptBuilder: _FakePromptBuilder(),
        repository: _FakeAIRepository(),
        conversation: conversation,
      );
    });

    test('retorna resposta e salva no histórico', () async {
      final response = await service.ask('Quem foi Alexandre?');
      expect(response.text, 'Resposta do acervo');
      expect(response.suggestedQuestions, contains('Sugestão 1'));

      final history = await service.getHistory();
      expect(history, hasLength(1));
      expect(history.first.question, 'Quem foi Alexandre?');
    });

    test('modo é passado ao PromptBuilder', () async {
      final response = await service.ask('Explique como professor', mode: AiMode.teacher);
      expect(response.text, isNotEmpty);
    });

    test('limpa histórico', () async {
      await service.ask('Quem foi Alexandre?');
      await service.clearHistory();
      final history = await service.getHistory();
      expect(history, isEmpty);
    });
  });
}
