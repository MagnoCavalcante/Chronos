import 'package:chronos/core/relationships/relationship_engine.dart';
import 'package:chronos/core/timeline/timeline_repository.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/features/ai/data/services/prompt_builder.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:chronos/features/ai/domain/repositories/ai_repository.dart';
import 'package:chronos/features/ai/domain/repositories/conversation_repository.dart';
import 'package:chronos/features/ai/presentation/controllers/conversation_controller.dart';
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
      text: 'Resposta fake',
      usedExternalAi: false,
      provider: AiProviderType.offline,
      suggestedQuestions: ['Pergunta sugerida?'],
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
  Future<List<ConversationMessage>> getHistory() async => _messages;

  @override
  Future<void> saveMessage(ConversationMessage message) async {
    _messages.removeWhere((m) => m.id == message.id);
    _messages.add(message);
  }

  @override
  Future<void> deleteMessage(String id) async => _messages.removeWhere((m) => m.id == id);

  @override
  Future<ConversationMessage> toggleFavorite(String id) async {
    final index = _messages.indexWhere((m) => m.id == id);
    final updated = _messages[index].copyWith(isFavorite: !_messages[index].isFavorite);
    _messages[index] = updated;
    return updated;
  }

  @override
  Future<ConversationMessage> togglePin(String id) async {
    final index = _messages.indexWhere((m) => m.id == id);
    final updated = _messages[index].copyWith(isPinned: !_messages[index].isPinned);
    _messages[index] = updated;
    return updated;
  }

  @override
  Future<List<ConversationMessage>> getFavorites() async => [];

  @override
  Future<List<ConversationMessage>> getPinned() async => [];

  @override
  Future<List<ConversationMessage>> getRecent({int limit = 10}) async => _messages.take(limit).toList();

  @override
  Future<void> clearHistory() async => _messages.clear();
}

class _FakeAiService extends AiService {
  final List<ConversationMessage> _history = [];

  _FakeAiService() : super(
          promptBuilder: _FakePromptBuilder(),
          repository: _FakeAIRepository(),
          conversation: _FakeConversationRepository(),
        );

  @override
  Future<AiResponse> ask(String question, {AiMode? mode}) async {
    final response = const AiResponse(
      text: 'Resposta fake',
      usedExternalAi: false,
      provider: AiProviderType.offline,
      suggestedQuestions: ['Pergunta sugerida?'],
    );
    _history.add(ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      response: response,
      timestamp: DateTime.now(),
    ));
    return response;
  }

  @override
  Future<List<ConversationMessage>> getHistory() async => _history.reversed.toList();

  @override
  Future<List<ConversationMessage>> getRecent({int limit = 10}) async => _history.reversed.take(limit).toList();

  @override
  Future<void> deleteMessage(String id) async => _history.removeWhere((m) => m.id == id);

  @override
  Future<ConversationMessage> toggleFavorite(String id) async => _history.first;

  @override
  Future<ConversationMessage> togglePin(String id) async => _history.first;

  @override
  Future<void> clearHistory() async => _history.clear();
}

void main() {
  group('ConversationController', () {
    late ConversationController controller;

    setUp(() {
      controller = ConversationController(aiService: _FakeAiService());
    });

    test('inicializa com estado vazio', () {
      expect(controller.state.messages, isEmpty);
      expect(controller.state.isLoading, isFalse);
    });

    test('altera modo de resposta', () {
      controller.setMode(AiMode.teacher);
      expect(controller.currentMode, AiMode.teacher);
    });

    test('envia pergunta e atualiza mensagens', () async {
      await controller.ask('Quem foi Alexandre?');
      await pumpEventQueue();
      expect(controller.state.messages, isNotEmpty);
      expect(controller.state.messages.first.question, 'Quem foi Alexandre?');
      expect(controller.state.suggestions, contains('Pergunta sugerida?'));
    });

    test('limpa histórico', () async {
      await controller.ask('Quem foi Alexandre?');
      await pumpEventQueue();
      await controller.clearHistory();
      expect(controller.state.messages, isEmpty);
    });
  });
}
