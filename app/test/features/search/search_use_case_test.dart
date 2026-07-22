import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';
import 'package:chronos/features/search/domain/repositories/search_repository.dart';
import 'package:chronos/features/search/domain/usecases/search_use_case.dart';

class RecordingSearchRepository implements SearchRepository {
  SearchQuery? receivedQuery;

  @override
  Future<Result<SearchPage>> search(SearchQuery query) async {
    receivedQuery = query;
    return const Result.success(SearchPage(results: [], hasMore: false));
  }
}

void main() {
  test('delegates the complete search query to its repository', () async {
    final repository = RecordingSearchRepository();
    final useCase = SearchUseCase(repository);
    const query = SearchQuery(
      text: 'Cleópatra',
      category: SearchCategory.characters,
      sort: SearchSort.relevance,
      page: 2,
      pageSize: 10,
    );

    await useCase(query);

    expect(repository.receivedQuery?.text, 'Cleópatra');
    expect(repository.receivedQuery?.category, SearchCategory.characters);
    expect(repository.receivedQuery?.offset, 20);
  });
}
