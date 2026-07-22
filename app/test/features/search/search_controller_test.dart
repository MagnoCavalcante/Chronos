import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';
import 'package:chronos/features/search/domain/repositories/search_repository.dart';
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
    final controller = ChronosSearchController(search: SearchUseCase(repository));

    controller.updateCategory('Civilizações');
    controller.updateSort('Nome Z-A');
    await Future<void>.delayed(Duration.zero);

    expect(repository.receivedQuery?.category, SearchCategory.civilizations);
    expect(repository.receivedQuery?.sort, SearchSort.nameDescending);
    expect(controller.filteredResults.single.display.title, 'Egito Antigo');
  });

  test('loads subsequent pages only when more results are available', () async {
    final repository = FakeSearchRepository(Result.success(SearchPage(results: [result], hasMore: true)));
    final controller = ChronosSearchController(search: SearchUseCase(repository));

    await controller.refresh();
    await controller.loadMore();

    expect(repository.receivedQuery?.page, 1);
    expect(controller.filteredResults, hasLength(2));
  });
}
