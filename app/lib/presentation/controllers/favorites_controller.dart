import 'package:flutter/foundation.dart';
import '../../core/home/home_item.dart';
import '../../core/home/home_repository.dart';
import '../../core/utils/logger.dart';

class FavoritesState {
  final bool isLoading;
  final String? error;
  final List<HomeItem> favorites;
  final String? filterCategory;
  final String query;
  final String sortBy;

  const FavoritesState({
    this.isLoading = false,
    this.error,
    this.favorites = const [],
    this.filterCategory,
    this.query = '',
    this.sortBy = 'recentes',
  });

  FavoritesState copyWith({
    bool? isLoading,
    String? error,
    List<HomeItem>? favorites,
    String? filterCategory,
    String? query,
    String? sortBy,
    bool clearError = false,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      favorites: favorites ?? this.favorites,
      filterCategory: filterCategory ?? this.filterCategory,
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  List<HomeItem> get filteredFavorites {
    var result = favorites;
    if (filterCategory != null && filterCategory!.isNotEmpty) {
      result = result.where((f) => f.category == filterCategory).toList();
    }
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result.where((f) => f.title.toLowerCase().contains(lower)).toList();
    }
    switch (sortBy) {
      case 'nome':
        result = [...result]..sort((a, b) => a.title.compareTo(b.title));
      case 'antigos':
        result = [...result]..sort((a, b) {
          final aDate = a.favoritedAt;
          final bDate = b.favoritedAt;
          if (aDate == null || bDate == null) return 0;
          return aDate.compareTo(bDate);
        });
      case 'recentes':
      default:
        result = [...result]..sort((a, b) {
          final aDate = a.favoritedAt;
          final bDate = b.favoritedAt;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });
    }
    return result;
  }

  List<String> get categories => favorites.map((f) => f.category ?? 'Outro').toSet().toList()..sort();
}

/// Controller da tela de Favoritos.
class FavoritesController extends ChangeNotifier {
  final HomeRepository _repository;
  FavoritesState _state = const FavoritesState();

  FavoritesController({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  FavoritesState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final favorites = await _repository.getFavorites();
      _state = _state.copyWith(isLoading: false, favorites: favorites);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar favoritos: $e', tag: 'FavoritesController', error: e);
      _state = _state.copyWith(isLoading: false, error: 'Não foi possível carregar favoritos.');
    }

    notifyListeners();
  }

  Future<void> refresh() => load();

  void setFilter(String? category) {
    _state = _state.copyWith(filterCategory: category);
    notifyListeners();
  }

  void setQuery(String value) {
    _state = _state.copyWith(query: value);
    notifyListeners();
  }

  void setSort(String value) {
    _state = _state.copyWith(sortBy: value);
    notifyListeners();
  }

  Future<void> toggleFavorite(HomeItem item) async {
    await _repository.toggleFavorite(item);
    final updated = _state.favorites.where((f) => f.entityId != item.entityId).toList();
    _state = _state.copyWith(favorites: updated);
    notifyListeners();
  }
}
