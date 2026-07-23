import 'package:chronos/core/relationships/relationship_engine.dart';
import 'package:chronos/core/relationships/relationship_item.dart';
import 'package:chronos/core/timeline/timeline_item.dart';
import 'package:chronos/core/timeline/timeline_repository.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/features/ai/data/services/prompt_builder.dart';
import 'package:chronos/features/ai/domain/entities/ai_entities.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';
import 'package:chronos/features/search/domain/repositories/search_repository.dart';
import 'package:chronos/features/search/domain/usecases/search_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSearchRepo implements SearchRepository {
  final List<SearchResult> results;
  _FakeSearchRepo(this.results);

  @override
  Future<Result<SearchPage>> search(SearchQuery query) async {
    return Result.success(SearchPage(results: results, hasMore: false));
  }
}

class _FakeSearchUseCase extends SearchUseCase {
  final List<SearchResult> results;
  _FakeSearchUseCase(this.results) : super(_FakeSearchRepo(results));
}

class _FakeRelationshipEngine extends RelationshipEngine {
  @override
  Future<List<RelatedGroup>> discover({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    return [
      RelatedGroup(
        relationType: 'Personagem Relacionado',
        items: [
          RelatedItem(
            id: '2',
            slug: 'filipo',
            entityType: 'historical_character',
            title: 'Filipe II da Macedônia',
            description: 'Pai de Alexandre',
            relationType: 'Personagem Relacionado',
            strength: 90,
          ),
        ],
      ),
    ];
  }
}

class _FakeTimelineRepository extends TimelineRepository {
  @override
  Future<List<TimelineDisplayItem>> getTimeline({
    String? filter,
    int? startYear,
    int? endYear,
    String? search,
    int page = 0,
    int pageSize = 50,
  }) async {
    return [
      TimelineDisplayItem(
        id: '3',
        slug: 'batalha-issos',
        entityType: 'historical_event',
        title: 'Batalha de Issos',
        description: 'Vitória de Alexandre sobre os persas',
        year: -333,
      ),
    ];
  }
}

void main() {
  group('PromptBuilder', () {
    late PromptBuilder builder;

    final results = [
      SearchResult(
        id: '1',
        entityType: 'historical_character',
        title: 'Alexandre, o Grande',
        subtitle: 'Rei da Macedônia',
        summary: 'Conquistador que construiu o maior império antigo.',
        imageUrl: null,
        chronologyValue: -356,
        createdAt: DateTime.now(),
        tags: const [],
        relevance: 95,
      ),
    ];

    setUp(() {
      builder = PromptBuilder(
        search: _FakeSearchUseCase(results),
        relationshipEngine: _FakeRelationshipEngine(),
        timelineRepository: _FakeTimelineRepository(),
      );
    });

    test('monta AiRequest com contexto de busca', () async {
      final request = await builder.buildRequest('Quem foi Alexandre?');
      expect(request.question, 'Quem foi Alexandre?');
      expect(request.searchResults, isNotEmpty);
      expect(request.searchResults.first.title, 'Alexandre, o Grande');
      expect(request.prompt, contains('Chronos AI'));
    });

    test('detecta modo professor', () async {
      final request = await builder.buildRequest('Explique como professor Alexandre, o Grande');
      expect(request.mode, AiMode.teacher);
      expect(request.prompt, contains('professor'));
    });

    test('detecta modo comparação', () async {
      final request = await builder.buildRequest('Comparar Alexandre e César');
      expect(request.mode, AiMode.comparison);
      expect(request.prompt, contains('Compare'));
    });

    test('detecta modo timeline com anos', () async {
      final request = await builder.buildRequest('Eventos entre 500 a.C. e 200 d.C.');
      expect(request.mode, AiMode.timeline);
      expect(request.timelineItems, isNotEmpty);
    });

    test('gera sugestões de perguntas', () async {
      final request = await builder.buildRequest('Alexandre');
      expect(request.searchResults, isNotEmpty);
    });
  });
}
