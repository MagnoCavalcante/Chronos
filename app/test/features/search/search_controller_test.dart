import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';
import 'package:chronos/features/search/domain/repositories/search_repository.dart';
import 'package:chronos/features/search/domain/services/search_services.dart';
import 'package:chronos/features/search/domain/usecases/search_use_case.dart';
import 'package:chronos/features/search/presentation/controllers/search_controller.dart';

class FakeSearchRepository implements SearchRepository {
  SearchQuery? receivedQuery;
  final Result<SearchPage> response;

  FakeSearchRepository(this.response);

  @override
  Future<Result<SearchPage>> search(SearchQuery query) async {
    receivedQuery = query;
    return response;
  }
}

ChronosSearchController buildController(FakeSearchRepository repository) {
  return ChronosSearchController(
    search: SearchUseCase(repository),
    analytics: SearchAnalyticsService(),
    history: SearchHistoryService(),
  );
}

void main() {
  final result = SearchResult(
    id: 'result-1',
    entityType: 'civilization',
    title: 'Egito Antigo',
    subtitle: 'Egito',
    summary: 'Civilização do Nilo.',
    chronologyValue: -3100,
    createdAt: DateTime(2026),
    tags: const ['Nilo'],
    relevance: 100,
  );

  test('uses category and sort filters in the query', () async {
    final repository = FakeSearchRepository(Result.success(SearchPage(results: [result], hasMore: false)));
    final controller = buildController(repository);
    addTearDown(controller.dispose);

    controller.updateQuery('Egito');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    controller.updateCategory('Civilizações');
    await Future<void>.delayed(Duration.zero);
    controller.updateSort('Nome Z-A');
    await Future<void>.delayed(Duration.zero);

    expect(repository.receivedQuery?.category, SearchCategory.civilizations);
    expect(repository.receivedQuery?.sort, SearchSort.nameDescending);
    expect(controller.filteredResults.single.display.title, 'Egito Antigo');
  });

  test('loads subsequent pages only when more results are available', () async {
    final repository = FakeSearchRepository(Result.success(SearchPage(results: [result], hasMore: true)));
    final controller = buildController(repository);
    addTearDown(controller.dispose);

    controller.updateQuery('Egito');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await controller.refresh();
    await controller.loadMore();

    expect(repository.receivedQuery?.page, 1);
    expect(controller.filteredResults, hasLength(2));
  });

  test('keeps up to 10 recent searches in memory', () async {
    final repository = FakeSearchRepository(Result.success(SearchPage(results: [result], hasMore: false)));
    final controller = buildController(repository);
    addTearDown(controller.dispose);

    controller.updateQuery('Roma');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    controller.updateQuery('Egito');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(controller.searchHistory, ['Egito', 'Roma']);
  });

  test('records analytics for each non-empty search', () async {
    final repository = FakeSearchRepository(Result.success(SearchPage(results: [result], hasMore: false)));
    final controller = buildController(repository);
    addTearDown(controller.dispose);

    controller.updateQuery('Roma');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(controller.analytics.events, isNotEmpty);
    expect(controller.analytics.events.first.query, 'Roma');
  });
}
