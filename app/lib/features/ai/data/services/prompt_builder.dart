import '../../../../core/relationships/relationship_engine.dart';
import '../../../../core/timeline/timeline_item.dart';
import '../../../../core/timeline/timeline_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../../search/domain/entities/search_result.dart';
import '../../../search/domain/usecases/search_use_case.dart';
import '../../domain/entities/ai_entities.dart';

/// Construtor de prompt RAG do Chronos AI.
///
/// Antes de consultar qualquer provedor externo, busca entidades no acervo
/// Chronos, expande relacionamentos e, quando necessário, consulta a
/// Timeline para montar um contexto rico e reduzir alucinações.
class PromptBuilder {
  final SearchUseCase _search;
  final RelationshipEngine _relationshipEngine;
  final TimelineRepository _timelineRepository;

  static const _tag = 'PromptBuilder';

  PromptBuilder({
    required SearchUseCase search,
    required RelationshipEngine relationshipEngine,
    required TimelineRepository timelineRepository,
  })  : _search = search,
        _relationshipEngine = relationshipEngine,
        _timelineRepository = timelineRepository;

  /// Analisa a pergunta, busca no acervo e monta o [AiRequest] enriquecido.
  Future<AiRequest> buildRequest(String question, {AiMode? mode}) async {
    final normalized = question.trim();
    final detectedMode = mode ?? _detectMode(normalized);

    final searchQuery = SearchQuery(
      text: normalized,
      pageSize: 8,
      sort: SearchSort.relevance,
    );

    final searchPage = await _search(searchQuery);
    final searchResults = searchPage.fold(
      onSuccess: (page) => page.results,
      onFailure: (_) => <SearchResult>[],
    );

    final topResults = searchResults.take(5).toList();
    final aiSearchResults = topResults.map(_mapSearchResult).toList();

    final relationships = await _enrichRelationships(topResults);
    final timelineItems = await _loadTimelineItems(detectedMode, normalized, topResults);
    final citations = _extractCitations(topResults);
    final suggestedQuestions = _generateSuggestions(topResults, relationships);

    final prompt = _buildPrompt(
      question: normalized,
      mode: detectedMode,
      searchResults: aiSearchResults,
      relationships: relationships,
      timelineItems: timelineItems,
    );

    return AiRequest(
      question: normalized,
      mode: detectedMode,
      prompt: prompt,
      searchResults: aiSearchResults,
      relationships: relationships,
      timelineItems: timelineItems,
    );
  }

  AiMode _detectMode(String question) {
    final lower = question.toLowerCase();
    if (lower.contains('compare') ||
        lower.contains('comparar') ||
        lower.contains(' versus ') ||
        lower.contains(' vs ')) {
      return AiMode.comparison;
    }
    if (lower.contains('professor') ||
        lower.contains('didaticamente') ||
        lower.contains('ensine')) {
      return AiMode.teacher;
    }
    if (lower.contains('resumidamente') ||
        lower.contains('resumo') ||
        lower.contains('resumido')) {
      return AiMode.summary;
    }
    if (lower.contains('detalhadamente') ||
        lower.contains('detalhado') ||
        lower.contains('aprofundado')) {
      return AiMode.detailed;
    }
    if (lower.contains('linha do tempo') ||
        lower.contains('timeline') ||
        _extractYears(question).length >= 2) {
      return AiMode.timeline;
    }
    return AiMode.normal;
  }

  Future<List<AiRelationshipGroup>> _enrichRelationships(List<SearchResult> results) async {
    final groups = <AiRelationshipGroup>[];
    for (final result in results) {
      try {
        final related = await _relationshipEngine.discover(
          entityType: result.entityType,
          entityId: result.id,
          limit: 20,
        );
        for (final group in related) {
          final mapped = group.items.map((item) => AiRelatedEntity(
                id: item.id,
                slug: item.slug,
                entityType: item.entityType,
                title: item.title,
                description: item.description,
                year: item.year,
                imageUrl: item.imageUrl,
                color: item.color,
              )).toList();
          groups.add(AiRelationshipGroup(
            relationType: group.relationType,
            items: mapped,
          ));
        }
      } catch (e) {
        ChronosLogger.warn(
          'Falha ao carregar relacionamentos para ${result.entityType}/${result.id}',
          tag: _tag,
          error: e,
        );
      }
    }
    return groups;
  }

  Future<List<AiTimelineItem>> _loadTimelineItems(
    AiMode mode,
    String question,
    List<SearchResult> searchResults,
  ) async {
    if (mode == AiMode.timeline) {
      final years = _extractYears(question);
      if (years.length >= 2) {
        try {
          final items = await _timelineRepository.getTimeline(
            startYear: years.first,
            endYear: years.last,
            pageSize: 20,
          );
          return items.map(_mapTimelineItem).toList();
        } catch (e) {
          ChronosLogger.warn('Falha ao carregar timeline', tag: _tag, error: e);
        }
      }
    }

    // Fallback: ordena os resultados da busca por cronologia.
    final sorted = searchResults.where((r) => r.chronologyValue != null).toList()
      ..sort((a, b) => a.chronologyValue!.compareTo(b.chronologyValue!));
    return sorted.map((r) => AiTimelineItem(
          id: r.id,
          slug: r.id,
          entityType: r.entityType,
          title: r.title,
          description: r.summary,
          year: r.chronologyValue ?? 0,
          imageUrl: r.imageUrl,
        )).toList();
  }

  List<AiCitation> _extractCitations(List<SearchResult> results) {
    return results
        .where((r) => r.entityType == 'historical_source')
        .map((r) => AiCitation(
              id: r.id,
              title: r.title,
              author: r.subtitle.isNotEmpty ? r.subtitle : null,
            ))
        .toList();
  }

  List<String> _generateSuggestions(
    List<SearchResult> results,
    List<AiRelationshipGroup> relationships,
  ) {
    final suggestions = <String>{};
    for (final result in results.take(3)) {
      suggestions.add('Quem foi ${result.title}?');
      suggestions.add('O que causou ${result.title}?');
      suggestions.add('Explique ${result.title}');
    }

    for (final group in relationships) {
      for (final item in group.items.take(2)) {
        suggestions.add('Quem foi ${item.title}?');
        suggestions.add('${item.title} e ${results.isNotEmpty ? results.first.title : ''}');
      }
    }

    suggestions.add('Quais civilizações existiam nesse período?');
    suggestions.add('Quem foi contemporâneo de ${results.isNotEmpty ? results.first.title : '...'}?');
    return suggestions.take(5).toList();
  }

  AiSearchResult _mapSearchResult(SearchResult result) {
    return AiSearchResult(
      id: result.id,
      entityType: result.entityType,
      title: result.title,
      subtitle: result.subtitle,
      summary: result.summary,
      imageUrl: result.imageUrl,
      chronologyValue: result.chronologyValue,
    );
  }

  AiTimelineItem _mapTimelineItem(TimelineDisplayItem item) {
    return AiTimelineItem(
      id: item.id,
      slug: item.slug,
      entityType: item.entityType,
      title: item.title,
      description: item.description,
      year: item.year,
      imageUrl: item.imageUrl,
      color: item.color,
    );
  }

  String _buildPrompt({
    required String question,
    required AiMode mode,
    required List<AiSearchResult> searchResults,
    required List<AiRelationshipGroup> relationships,
    required List<AiTimelineItem> timelineItems,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Você é o Chronos AI, um assistente especializado em História.');
    buffer.writeln(_modeInstruction(mode));
    buffer.writeln();
    buffer.writeln('Use preferencialmente as informações do acervo Chronos abaixo. '
        'Se não houver dados suficientes, deixe claro que a resposta usa conhecimento geral.');
    buffer.writeln();

    if (searchResults.isNotEmpty) {
      buffer.writeln('--- Acervo Chronos ---');
      for (final result in searchResults) {
        buffer.writeln('ENTIDADE: ${result.title}');
        buffer.writeln('TIPO: ${result.entityType}');
        if (result.chronologyValue != null) {
          final year = result.chronologyValue!;
          buffer.writeln('ANO: ${year < 0 ? '${year.abs()} a.C.' : '$year d.C.'}');
        }
        buffer.writeln('RESUMO: ${result.summary}');
        buffer.writeln();
      }
    }

    if (relationships.isNotEmpty) {
      buffer.writeln('--- Relacionamentos ---');
      for (final group in relationships) {
        final titles = group.items.map((i) => i.title).join(', ');
        if (titles.isNotEmpty) {
          buffer.writeln('${group.relationType}: $titles');
        }
      }
      buffer.writeln();
    }

    if (timelineItems.isNotEmpty && mode == AiMode.timeline) {
      buffer.writeln('--- Linha do Tempo ---');
      final sorted = [...timelineItems]..sort((a, b) => a.year.compareTo(b.year));
      for (final item in sorted) {
        final period = item.year < 0 ? '${item.year.abs()} a.C.' : '${item.year} d.C.';
        buffer.writeln('$period - ${item.title}: ${item.description}');
      }
      buffer.writeln();
    }

    buffer.writeln('PERGUNTA: $question');

    return buffer.toString().trim();
  }

  String _modeInstruction(AiMode mode) {
    switch (mode) {
      case AiMode.teacher:
        return 'Explique o tema de forma didática, como um professor explicaria para um estudante.';
      case AiMode.summary:
        return 'Resuma o tema de forma objetiva, destacando os pontos mais importantes.';
      case AiMode.detailed:
        return 'Responda de forma detalhada e aprofundada, com contexto e nuances.';
      case AiMode.comparison:
        return 'Compare as entidades mencionadas, destacando semelhanças e diferenças.';
      case AiMode.timeline:
        return 'Organize a resposta em ordem cronológica, como uma linha do tempo.';
      case AiMode.normal:
        return 'Responda de forma clara e fundamentada no acervo Chronos.';
    }
  }

  List<int> _extractYears(String text) {
    final years = <int>[];
    final regex = RegExp(r'\b(\d{1,4})\s*(a\.?c\.?|d\.?c\.?|a\.?d\.?|c\.?e\.?|b\.?c\.?|antes de cristo|depois de cristo)?\b', caseSensitive: false);
    final matches = regex.allMatches(text);
    for (final match in matches) {
      final number = int.tryParse(match.group(1)!);
      if (number == null) continue;
      final suffix = match.group(2)?.toLowerCase() ?? '';
      final isBc = suffix.contains('a') || suffix.contains('b') || suffix.contains('antes');
      years.add(isBc ? -number : number);
    }
    return years;
  }
}
