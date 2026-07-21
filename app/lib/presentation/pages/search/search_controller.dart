import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/logger.dart';
import '../../engine/entity_registry.dart';
import '../../engine/entity_renderer.dart';
import '../browser/entity_card.dart';
import '../eras_controller.dart';
import '../historical_events_controller.dart';
import '../artifacts_controller.dart';
import '../historical_locations_controller.dart';
import '../../../features/historical_characters/presentation/controllers/historical_characters_controller.dart';
import '../../../features/civilizations/presentation/controllers/civilizations_controller.dart';

/// Item unificado contendo o display mapeado e a entidade original de domínio.
class SearchResultItem {
  final ChronosEntityDisplay display;
  final dynamic originalEntity;

  const SearchResultItem({
    required this.display,
    required this.originalEntity,
  });
}

/// Controller central da Busca Global do CHRONOS.
///
/// Gerencia os estados de busca, filtros de categoria, ordenação, debounce incremental
/// e unificação de dados reais provenientes de todos os sub-controladores de domínio.
class ChronosSearchController extends ChangeNotifier {
  String _query = '';
  String _selectedCategory = 'Todos';
  String _selectedSort = 'Relevância';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<SearchResultItem> _allItems = [];
  List<SearchResultItem> _filteredResults = [];
  Timer? _debounce;

  String get query => _query;
  String get selectedCategory => _selectedCategory;
  String get selectedSort => _selectedSort;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  List<SearchResultItem> get filteredResults => _filteredResults;

  /// Inicializa e sincroniza os dados reais do Knowledge Engine em paralelo.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ChronosLogger.info('Sincronizando dados reais dos controladores para a Busca Global...', tag: 'ChronosSearchController');
      
      final erasCtrl = locate<ErasController>();
      final eventsCtrl = locate<HistoricalEventsController>();
      final artifactsCtrl = locate<ArtifactsController>();
      final locationsCtrl = locate<HistoricalLocationsController>();
      final charactersCtrl = locate<HistoricalCharactersController>();
      final civilizationsCtrl = locate<CivilizationsController>();

      // Carrega os dados reais do banco de forma simultânea
      await Future.wait([
        erasCtrl.carregarEras(),
        eventsCtrl.loadEvents(),
        artifactsCtrl.loadArtifacts(),
        locationsCtrl.loadLocations(),
        charactersCtrl.loadHistoricalCharacters(),
        civilizationsCtrl.loadCivilizations(),
      ]);

      _buildAllItemsIndex();
      _isInitialized = true;
      _performSearch();
    } catch (e, stack) {
      ChronosLogger.error('Erro na indexação de busca temporal', error: e, stackTrace: stack);
      _errorMessage = 'Falha ao sincronizar dados do acervo temporal.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Constrói o índice local com as entidades reais mapeadas para ChronosEntityDisplay
  void _buildAllItemsIndex() {
    final registry = EntityRegistry();
    final List<dynamic> entities = [];

    // Consolida todas as listas dos controladores
    entities.addAll(locate<ErasController>().eras);
    entities.addAll(locate<HistoricalEventsController>().events);
    entities.addAll(locate<ArtifactsController>().items);
    entities.addAll(locate<HistoricalLocationsController>().items);
    entities.addAll(locate<HistoricalCharactersController>().items);
    entities.addAll(locate<CivilizationsController>().items);

    _allItems = entities.map((entity) {
      final String type = registry.resolveEntityType(entity);
      final descriptor = registry.getDescriptor(type);
      final metadata = registry.getMetadata(type);

      if (descriptor != null && metadata != null) {
        final display = EntityRenderer.mapToDisplay(entity, descriptor, metadata);
        return SearchResultItem(display: display, originalEntity: entity);
      }
      return null;
    }).whereType<SearchResultItem>().toList();

    ChronosLogger.info('Índice de Busca construído com sucesso. Total de registros: ${_allItems.length}', tag: 'ChronosSearchController');
  }

  /// Altera o termo de busca com debounce integrado
  void updateQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  /// Altera o filtro de categoria
  void updateCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _performSearch();
  }

  /// Altera a ordenação
  void updateSort(String sort) {
    if (_selectedSort == sort) return;
    _selectedSort = sort;
    _performSearch();
  }

  /// Executa o algoritmo de filtragem e classificação baseado em conteúdo real
  void _performSearch() {
    final registry = EntityRegistry();
    final queryLower = _query.toLowerCase().trim();

    // 1. Filtragem por Categoria
    List<SearchResultItem> workingList = _allItems;
    final mappedType = _getEntityTypeFromCategory(_selectedCategory);
    if (mappedType != null) {
      workingList = workingList.where((item) {
        return registry.resolveEntityType(item.originalEntity) == mappedType;
      }).toList();
    }

    // 2. Filtragem de Conteúdo por Texto
    if (queryLower.isNotEmpty) {
      workingList = workingList.where((item) {
        final display = item.display;
        final titleMatch = display.title.toLowerCase().contains(queryLower);
        final subtitleMatch = display.subtitle.toLowerCase().contains(queryLower);
        final descMatch = (display.description ?? '').toLowerCase().contains(queryLower);
        final chronologyMatch = (display.chronology ?? '').toLowerCase().contains(queryLower);
        final categoryMatch = (display.category ?? '').toLowerCase().contains(queryLower);
        final typeMatch = (display.type ?? '').toLowerCase().contains(queryLower);

        return titleMatch || subtitleMatch || descMatch || chronologyMatch || categoryMatch || typeMatch;
      }).toList();
    }

    // 3. Ordenação Estruturada
    if (_selectedSort == 'Alfabética') {
      workingList.sort((a, b) => a.display.title.toLowerCase().compareTo(b.display.title.toLowerCase()));
    } else if (_selectedSort == 'Cronológica') {
      workingList.sort((a, b) {
        final valA = a.display.chronologyValue;
        final valB = b.display.chronologyValue;
        if (valA == null && valB == null) return 0;
        if (valA == null) return 1;
        if (valB == null) return -1;
        return valA.compareTo(valB);
      });
    } else {
      // Relevância (Default)
      if (queryLower.isNotEmpty) {
        final Map<SearchResultItem, int> scores = {};
        for (final item in workingList) {
          int score = 0;
          final title = item.display.title.toLowerCase();
          final subtitle = item.display.subtitle.toLowerCase();
          final desc = (item.display.description ?? '').toLowerCase();

          if (title.startsWith(queryLower)) {
            score += 100;
          } else if (title.contains(queryLower)) {
            score += 50;
          }
          if (subtitle.contains(queryLower)) {
            score += 25;
          }
          if (desc.contains(queryLower)) {
            score += 10;
          }
          scores[item] = score;
        }

        workingList.sort((a, b) {
          final scoreA = scores[a] ?? 0;
          final scoreB = scores[b] ?? 0;
          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA); // Maior relevância primeiro
          }
          return a.display.title.toLowerCase().compareTo(b.display.title.toLowerCase());
        });
      } else {
        // Sem query, ordena por prioridade do descritor de entidade e depois alfabética
        workingList.sort((a, b) {
          final typeA = registry.resolveEntityType(a.originalEntity);
          final typeB = registry.resolveEntityType(b.originalEntity);
          final priorityA = registry.getDescriptor(typeA)?.priority ?? 0;
          final priorityB = registry.getDescriptor(typeB)?.priority ?? 0;

          if (priorityA != priorityB) {
            return priorityB.compareTo(priorityA);
          }
          return a.display.title.toLowerCase().compareTo(b.display.title.toLowerCase());
        });
      }
    }

    _filteredResults = workingList;
    notifyListeners();
  }

  /// Mapeador auxiliar de filtros visuais em tipos internos do sistema.
  String? _getEntityTypeFromCategory(String category) {
    switch (category) {
      case 'Eras':
        return 'era';
      case 'Eventos':
        return 'historical_event';
      case 'Personagens':
        return 'historical_character';
      case 'Civilizações':
        return 'civilization';
      case 'Artefatos':
        return 'artifact';
      case 'Localizações':
        return 'historical_location';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
