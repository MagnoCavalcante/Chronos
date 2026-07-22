import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/features/search/data/datasources/search_remote_datasource.dart';
import 'package:chronos/features/search/data/repositories/supabase_search_repository.dart';
import 'package:chronos/features/search/domain/entities/search_result.dart';

class FakeSearchRemoteDataSource implements SearchRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> search(SearchQuery query) async {
    return [
      {
        'entity_id': 'source-1',
        'entity_type': 'historical_source',
        'title': 'Histórias',
        'subtitle': 'Heródoto',
        'summary': 'Fonte primária.',
        'image_url': null,
        'chronology_value': -450,
        'created_at': '2026-07-22T00:00:00.000Z',
        'tags': ['Grécia', 'Historiografia'],
        'relevance': 100,
      },
    ];
  }
}

void main() {
  test('maps Supabase rows into typed search results', () async {
    final repository = SupabaseSearchRepository(dataSource: FakeSearchRemoteDataSource());

    final response = await repository.search(const SearchQuery(text: 'Histórias'));

    expect(response.isSuccess, isTrue);
    final page = response.valueOrNull!;
    expect(page.results.single.entityType, 'historical_source');
    expect(page.results.single.tags, ['Grécia', 'Historiografia']);
    expect(page.results.single.chronologyValue, -450);
  });
}
