import 'package:flutter/foundation.dart';
import '../../core/home/home_item.dart';
import '../../core/home/home_repository.dart';
import '../../core/utils/logger.dart';

/// Estado da tela inicial inteligente do CHRONOS.
class HomeState {
  final bool isLoading;
  final String? error;
  final List<HomeItem> continueExploring;
  final List<HomeItem> highlights;
  final List<HomeItem> favorites;
  final HomeItem? surprise;
  final Map<String, List<HomeItem>> categories;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.continueExploring = const [],
    this.highlights = const [],
    this.favorites = const [],
    this.surprise,
    this.categories = const {},
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<HomeItem>? continueExploring,
    List<HomeItem>? highlights,
    List<HomeItem>? favorites,
    HomeItem? surprise,
    Map<String, List<HomeItem>>? categories,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      continueExploring: continueExploring ?? this.continueExploring,
      highlights: highlights ?? this.highlights,
      favorites: favorites ?? this.favorites,
      surprise: surprise ?? this.surprise,
      categories: categories ?? this.categories,
    );
  }
}

/// Controller reativo da Home inteligente.
class HomeController extends ChangeNotifier {
  final HomeRepository _repository;
  HomeState _state = const HomeState();

  HomeController({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  HomeState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getContinueExploring(limit: 10),
        _repository.getHighlights(limit: 10),
        _repository.getFavorites(),
        _repository.getSurpriseMe(),
        _repository.getRecentByCategory('civilizations', limit: 10),
        _repository.getRecentByCategory('historical_characters', limit: 10),
        _repository.getRecentByCategory('historical_events', limit: 10),
        _repository.getRecentByCategory('artifacts', limit: 10),
        _repository.getRecentByCategory('historical_locations', limit: 10),
      ]);

      _state = _state.copyWith(
        isLoading: false,
        continueExploring: results[0] as List<HomeItem>,
        highlights: results[1] as List<HomeItem>,
        favorites: results[2] as List<HomeItem>,
        surprise: results[3] as HomeItem?,
        categories: {
          'Civilizações': results[4] as List<HomeItem>,
          'Personagens': results[5] as List<HomeItem>,
          'Eventos': results[6] as List<HomeItem>,
          'Artefatos': results[7] as List<HomeItem>,
          'Localizações': results[8] as List<HomeItem>,
        },
      );
    } catch (e) {
      ChronosLogger.error('Erro ao carregar Home: $e', tag: 'HomeController', error: e);
      _state = _state.copyWith(isLoading: false, error: 'Não foi possível carregar a Home.');
    }

    notifyListeners();
  }

  Future<void> refresh() => load();

  Future<bool> toggleFavorite(HomeItem item) async {
    final result = await _repository.toggleFavorite(item);
    final updated = result
        ? [..._state.favorites, item.copyWith(favoritedAt: DateTime.now())]
        : _state.favorites.where((f) => f.entityId != item.entityId).toList();
    _state = _state.copyWith(favorites: updated);
    notifyListeners();
    return result;
  }

  Future<void> onItemOpened(HomeItem item) async {
    await _repository.logAccess(item);
  }

  Future<void> surpriseMe() async {
    final item = await _repository.getSurpriseMe();
    _state = _state.copyWith(surprise: item);
    notifyListeners();
  }
}
