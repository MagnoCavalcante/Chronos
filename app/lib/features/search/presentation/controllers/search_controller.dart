import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chronos/presentation/engine/entity_registry.dart';
import 'package:chronos/presentation/widgets/browser/entity_card.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/services/search_services.dart';
import '../../domain/usecases/search_use_case.dart';

class SearchResultItem {
  final SearchResult result;

  const SearchResultItem(this.result);

  ChronosEntityDisplay get display {
    final descriptor = EntityRegistry().getDescriptor(result.entityType);
    return ChronosEntityDisplay(
      id: result.id,
      title: result.title,
      subtitle: result.subtitle,
      description: result.summary,
      imageUrl: result.imageUrl,
      icon: descriptor?.icon,
      color: descriptor?.color,
      chronology: result.chronologyValue == null
          ? null
          : '${result.chronologyValue!.abs()}${result.chronologyValue! < 0 ? ' a.C.' : ' d.C.'}',
      chronologyValue: result.chronologyValue,
      dateValue: result.createdAt,
      category: descriptor?.category,
      type: descriptor?.displayName,
    );
  }

  Map<String, dynamic> get originalEntity => {
        'id': result.id,
        'nome': result.title,
        'name': result.title,
        'titulo': result.subtitle,
        'shortName': result.subtitle,
        'descricao': result.summary,
        'description': result.summary,
        'summary': result.summary,
        'coverImageUrl': result.imageUrl,
        'startYear': result.chronologyValue,
        'estimatedYear': result.chronologyValue,
        'anoOcorrencia': result.chronologyValue,
      };

  String get entityType => result.entityType;
}

class SearchState {
  final SearchQuery query;
  final List<SearchResult> results;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;

  const SearchState({
    required this.query,
    this.results = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.errorMessage,
  });

  SearchState copyWith({
    SearchQuery? query,
    List<SearchResult>? results,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ChronosSearchController extends ChangeNotifier {
  final SearchUseCase _search;
  final SearchAnalyticsService _analytics;
  final SearchHistoryService _history;
  Timer? _debounce;
  bool _initialized = false;
  SearchState _state = const SearchState(query: SearchQuery());

  ChronosSearchController({
    required SearchUseCase search,
    required SearchAnalyticsService analytics,
    required SearchHistoryService history,
  })  : _search = search,
        _analytics = analytics,
        _history = history;

  SearchState get state => _state;
  String get query => _state.query.text;
  String get selectedCategory => _state.query.category.label;
  String get selectedSort => _state.query.sort.label;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  bool get isInitialized => _initialized;
  List<SearchResultItem> get filteredResults => _state.results.map(SearchResultItem.new).toList(growable: false);
  bool get hasMore => _state.hasMore;
  SearchAnalyticsService get analytics => _analytics;
  List<String> get searchHistory => _history.history;
  List<String> get popularSearches => const ['Alexandre', 'Roma', 'Napoleão', 'Segunda Guerra', 'Egito'];

  Future<void> initialize() async {
    _initialized = true;
    await _execute(_state.query.copyWith(page: 0));
  }

  void updateQuery(String value) {
    final nextQuery = _state.query.copyWith(text: value.trim(), page: 0);
    _state = _state.copyWith(query: nextQuery, clearError: true);
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _execute(nextQuery));
  }

  void selectSuggestion(String value) {
    final nextQuery = _state.query.copyWith(text: value.trim(), page: 0);
    _state = _state.copyWith(query: nextQuery, clearError: true);
    notifyListeners();
    _debounce?.cancel();
    _execute(nextQuery);
  }

  void updateCategory(String value) {
    final category = SearchCategory.values.firstWhere((item) => item.label == value);
    _debounce?.cancel();
    _execute(_state.query.copyWith(category: category, page: 0));
  }

  void updateSort(String value) {
    final sort = SearchSort.values.firstWhere((item) => item.label == value);
    _debounce?.cancel();
    _execute(_state.query.copyWith(sort: sort, page: 0));
  }

  Future<void> refresh() => _execute(_state.query.copyWith(page: 0));

  Future<void> loadMore() async {
    if (_state.isLoading || !_state.hasMore) return;
    await _execute(_state.query.copyWith(page: _state.query.page + 1), append: true);
  }

  Future<void> _execute(SearchQuery searchQuery, {bool append = false}) async {
    if (searchQuery.text.trim().isEmpty) {
      _state = _state.copyWith(
        query: searchQuery,
        results: const [],
        isLoading: false,
        hasMore: false,
        clearError: true,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(query: searchQuery, isLoading: true, clearError: true);
    notifyListeners();
    final stopwatch = Stopwatch()..start();
    final result = await _search(searchQuery);
    stopwatch.stop();
    result.fold(
      onSuccess: (page) {
        _state = _state.copyWith(
          results: append ? [..._state.results, ...page.results] : page.results,
          isLoading: false,
          hasMore: page.hasMore,
        );
        _history.add(searchQuery.text.trim());
        _analytics.record(
          query: searchQuery.text.trim(),
          resultCount: page.results.length,
          duration: stopwatch.elapsed,
          category: searchQuery.category.label,
        );
      },
      onFailure: (failure) {
        _state = _state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
