enum SearchCategory {
  all('Todos', null),
  characters('Personagens', 'historical_character'),
  civilizations('Civilizações', 'civilization'),
  events('Eventos', 'historical_event'),
  artifacts('Artefatos', 'artifact'),
  locations('Localizações', 'historical_location'),
  sources('Fontes', 'historical_source');

  final String label;
  final String? entityType;

  const SearchCategory(this.label, this.entityType);
}

enum SearchSort {
  relevance('Mais relevantes', 'relevance'),
  nameAscending('Nome A-Z', 'name_asc'),
  nameDescending('Nome Z-A', 'name_desc'),
  newest('Mais recentes', 'newest'),
  oldest('Mais antigos', 'oldest');

  final String label;
  final String value;

  const SearchSort(this.label, this.value);
}

class SearchQuery {
  final String text;
  final SearchCategory category;
  final SearchSort sort;
  final int page;
  final int pageSize;

  const SearchQuery({
    this.text = '',
    this.category = SearchCategory.all,
    this.sort = SearchSort.relevance,
    this.page = 0,
    this.pageSize = 30,
  });

  int get offset => page * pageSize;

  SearchQuery copyWith({
    String? text,
    SearchCategory? category,
    SearchSort? sort,
    int? page,
    int? pageSize,
  }) {
    return SearchQuery(
      text: text ?? this.text,
      category: category ?? this.category,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class SearchResult {
  final String id;
  final String entityType;
  final String title;
  final String subtitle;
  final String summary;
  final String? imageUrl;
  final int? chronologyValue;
  final DateTime createdAt;
  final List<String> tags;
  final int relevance;

  const SearchResult({
    required this.id,
    required this.entityType,
    required this.title,
    required this.subtitle,
    required this.summary,
    this.imageUrl,
    this.chronologyValue,
    required this.createdAt,
    required this.tags,
    required this.relevance,
  });
}

class SearchPage {
  final List<SearchResult> results;
  final bool hasMore;

  const SearchPage({required this.results, required this.hasMore});
}
