import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/timeline/timeline_repository.dart';
import '../../../core/utils/logger.dart';
import 'timeline_item.dart';

/// Controller reativo da Timeline interativa do CHRONOS.
///
/// Carrega dados unificados do Supabase, gerencia filtros por categoria,
/// período, zoom, busca e paginação lazy.
class TimelineController extends ChangeNotifier {
  final TimelineRepository _repository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _page = 0;
  static const int _pageSize = 50;

  String _searchQuery = '';
  TimelineItemType _selectedCategory = TimelineItemType.all;
  int _startYear = -5000;
  int _endYear = 2100;
  bool _isAscending = true;
  String _zoom = 'Séculos';

  List<TimelineDisplayItem> _items = [];

  TimelineController({TimelineRepository? repository})
      : _repository = repository ?? TimelineRepository();

  // Getters de estado
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasMore => _hasMore;

  // Getters de filtros
  String get searchQuery => _searchQuery;
  TimelineItemType get selectedCategory => _selectedCategory;
  int get startYear => _startYear;
  int get endYear => _endYear;
  bool get isAscending => _isAscending;
  String get zoom => _zoom;

  // Limites para sliders
  int get minPossibleYear => -5000;
  int get maxPossibleYear => 2100;

  // Coleções
  List<TimelineDisplayItem> get filteredItems => _isAscending
      ? List.unmodifiable(_items)
      : List.unmodifiable(_items.reversed);
  List<TimelineDisplayItem> get allItems => List.unmodifiable(_items);

  /// Categorias disponíveis para filtro.
  List<TimelineItemType> get categories => TimelineItemType.values
      .where((t) => t != TimelineItemType.all)
      .toList();

  /// Inicia a carga da Timeline respeitando os filtros atuais.
  Future<void> carregarDados() async {
    _page = 0;
    _items = [];
    _hasMore = true;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final result = await _fetch();
    _items = result;
    _hasMore = result.length == _pageSize;
    _isLoading = false;
    notifyListeners();
  }

  /// Carrega a próxima página de itens (Lazy Loading).
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    _page++;
    final result = await _fetch();
    _items.addAll(result);
    _hasMore = result.length == _pageSize;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<List<TimelineDisplayItem>> _fetch() async {
    try {
      return await _repository.getTimeline(
        filter: _selectedCategory == TimelineItemType.all
            ? null
            : _selectedCategory.apiValue,
        startYear: _startYear,
        endYear: _endYear,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _page,
        pageSize: _pageSize,
      );
    } catch (e) {
      _errorMessage = 'Erro ao carregar a linha do tempo: $e';
      ChronosLogger.error(_errorMessage!, tag: 'TimelineController', error: e);
      return [];
    }
  }

  Future<void> refresh() => carregarDados();

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    carregarDados();
  }

  void selectCategory(TimelineItemType category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      carregarDados();
    }
  }

  void setPeriod(int start, int end) {
    if (_startYear != start || _endYear != end) {
      _startYear = start;
      _endYear = end;
      carregarDados();
    }
  }

  void toggleOrder() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  void setZoom(String zoom) {
    if (_zoom != zoom) {
      _zoom = zoom;
      notifyListeners();
    }
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = TimelineItemType.all;
    _startYear = minPossibleYear;
    _endYear = maxPossibleYear;
    _isAscending = true;
    _zoom = 'Séculos';
    carregarDados();
  }
}
