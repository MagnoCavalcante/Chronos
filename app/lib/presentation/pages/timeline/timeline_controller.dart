import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/era.dart';
import '../../../domain/entities/event.dart';
import '../../controllers/eras_controller.dart';
import '../../controllers/historical_events_controller.dart';
import 'timeline_item.dart';

/// Controller reativo responsável por gerenciar o estado da Timeline MVP do CHRONOS.
///
/// Consome dados exclusivamente dos controladores de domínio:
/// - [ErasController]
/// - [HistoricalEventsController]
///
/// Gerencia a busca local, ordenação cronológica, filtros de Era e período,
/// bem como o agrupamento de eventos sob suas respectivas Eras.
class TimelineController extends ChangeNotifier {
  final ErasController _erasController;
  final HistoricalEventsController _eventsController;

  bool _isLoading = false;
  String? _errorMessage;

  // Filtros ativos
  String _searchQuery = '';
  String? _selectedEraId; // null representa "Todas as Eras"
  int? _startYear;
  int? _endYear;
  bool _isAscending = true;
  bool _groupByEra = false;

  // Cache de itens de exibição gerados
  List<TimelineDisplayItem> _allDisplayItems = [];
  List<TimelineDisplayItem> _filteredDisplayItems = [];
  Map<Era, List<TimelineDisplayItem>> _groupedDisplayItems = {};

  TimelineController({
    ErasController? erasController,
    HistoricalEventsController? eventsController,
  })  : _erasController = erasController ?? locate<ErasController>(),
        _eventsController = eventsController ?? locate<HistoricalEventsController>();

  // Getters de estado básicos
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Getters de filtros
  String get searchQuery => _searchQuery;
  String? get selectedEraId => _selectedEraId;
  int? get startYear => _startYear;
  int? get endYear => _endYear;
  bool get isAscending => _isAscending;
  bool get groupByEra => _groupByEra;

  // Getters de coleções originais
  List<Era> get eras => _erasController.eras;
  List<HistoricalEvent> get events => _eventsController.events;

  // Getters de coleções filtradas e preparadas para a UI
  List<TimelineDisplayItem> get filteredItems => _filteredDisplayItems;
  Map<Era, List<TimelineDisplayItem>> get groupedFilteredItems => _groupedDisplayItems;

  /// Limites cronológicos dinâmicos baseados no acervo carregado
  int get minPossibleYear {
    if (eras.isEmpty && events.isEmpty) return -5000;
    int minYr = 10000;
    for (final era in eras) {
      if (era.inicioAno < minYr) minYr = era.inicioAno;
    }
    for (final event in events) {
      if (event.anoOcorrencia < minYr) minYr = event.anoOcorrencia;
    }
    return minYr;
  }

  int get maxPossibleYear {
    if (eras.isEmpty && events.isEmpty) return 2100;
    int maxYr = -10000;
    for (final era in eras) {
      if (era.fimAno > maxYr) maxYr = era.fimAno;
    }
    for (final event in events) {
      if (event.anoOcorrencia > maxYr) maxYr = event.anoOcorrencia;
    }
    return maxYr;
  }

  /// Inicializa e recarrega os dados históricos chamando os controladores originais.
  Future<void> carregarDados() async {
    ChronosLogger.info('Iniciando carga de dados unificada para a Timeline...', tag: 'TimelineController');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Carrega Eras e Eventos concorrentemente
      await Future.wait([
        _erasController.carregarEras(),
        _eventsController.loadEvents(),
      ]);

      if (_erasController.hasError) {
        _errorMessage = _erasController.errorMessage;
        ChronosLogger.error('Erro na carga de Eras: $_errorMessage', tag: 'TimelineController');
      } else if (_eventsController.hasError) {
        _errorMessage = _eventsController.failure?.message ?? 'Falha ao recuperar eventos';
        ChronosLogger.error('Erro na carga de Eventos: $_errorMessage', tag: 'TimelineController');
      } else {
        // Se ambos carregaram com sucesso, preenche as datas padrão do filtro se nulas
        _startYear ??= minPossibleYear;
        _endYear ??= maxPossibleYear;

        // Processa as entidades do domínio para o formato da Timeline
        _processEntities();
        _applyFiltersAndSorting();
      }
    } catch (e, stack) {
      _errorMessage = 'Falha na orquestração da linha do tempo: $e';
      ChronosLogger.error(_errorMessage!, tag: 'TimelineController', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Converte as entidades de domínio brutas em itens de apresentação da Timeline.
  void _processEntities() {
    final List<TimelineDisplayItem> tempItems = [];

    // Mapeamento auxiliar de cores
    final Map<String, Color> eraColors = {};

    for (final era in eras) {
      final Color color = _parseHexColor(era.corHex);
      eraColors[era.id] = color;
      tempItems.add(TimelineDisplayItem.fromEra(era, color));
    }

    for (final event in events) {
      final Color color = eraColors[event.eraId] ?? Colors.amber;
      final Era? era = eras.firstWhere((e) => e.id == event.eraId, orElse: () => _erasController.eras.firstWhere((e) => e.id == event.eraId));
      tempItems.add(TimelineDisplayItem.fromEvent(event, era, color));
    }

    _allDisplayItems = tempItems;
  }

  /// Aplica filtragens locais e ordenação sobre os itens da Timeline.
  void _applyFiltersAndSorting() {
    // 1. Filtragem geral
    var queryItems = _allDisplayItems.where((item) {
      // Filtro de busca textual simples (nome, subtítulo ou descrição)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesSubtitle = item.subtitle.toLowerCase().contains(query);
        final matchesDesc = item.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesSubtitle && !matchesDesc) {
          return false;
        }
      }

      // Filtro de Era específica
      if (_selectedEraId != null) {
        if (item.type == TimelineItemType.era) {
          if (item.id != _selectedEraId) return false;
        } else if (item.type == TimelineItemType.event) {
          final event = item.originalEntity as HistoricalEvent;
          if (event.eraId != _selectedEraId) return false;
        }
      }

      // Filtro de Período Cronológico
      final start = _startYear ?? minPossibleYear;
      final end = _endYear ?? maxPossibleYear;
      if (item.type == TimelineItemType.era) {
        final era = item.originalEntity as Era;
        // Consideramos a Era dentro se ela cruzar ou estiver dentro do intervalo do filtro
        final overlaps = (era.inicioAno <= end && era.fimAno >= start);
        if (!overlaps) return false;
      } else {
        if (item.year < start || item.year > end) {
          return false;
        }
      }

      return true;
    }).toList();

    // 2. Ordenação cronológica baseada no ano de referência
    queryItems.sort((a, b) {
      if (_isAscending) {
        return a.year.compareTo(b.year);
      } else {
        return b.year.compareTo(a.year);
      }
    });

    _filteredDisplayItems = queryItems;

    // 3. Agrupamento por Era (se habilitado)
    if (_groupByEra) {
      final Map<Era, List<TimelineDisplayItem>> groups = {};
      
      // Ordena as Eras correspondentes conforme o sentido da Timeline
      final List<Era> sortedEras = List.from(eras);
      sortedEras.sort((a, b) {
        if (_isAscending) {
          return a.inicioAno.compareTo(b.inicioAno);
        } else {
          return b.inicioAno.compareTo(a.inicioAno);
        }
      });

      for (final era in sortedEras) {
        // Encontra itens de evento filtrados que pertencem a esta Era
        final eraEvents = _filteredDisplayItems.where((item) {
          return item.type == TimelineItemType.event &&
              (item.originalEntity as HistoricalEvent).eraId == era.id;
        }).toList();

        // Só adiciona a Era ao grupo se o filtro de busca/período também permitir a exibição da Era
        final bool shouldShowEra = _filteredDisplayItems.any((item) =>
            item.type == TimelineItemType.era && item.id == era.id);

        if (shouldShowEra || eraEvents.isNotEmpty) {
          groups[era] = eraEvents;
        }
      }
      _groupedDisplayItems = groups;
    } else {
      _groupedDisplayItems = {};
    }
  }

  // Métodos de atualização de filtros (disparam re-renderizações locais rápidas)

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  void selectEra(String? eraId) {
    if (_selectedEraId != eraId) {
      _selectedEraId = eraId;
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  void setPeriod(int start, int end) {
    if (_startYear != start || _endYear != end) {
      _startYear = start;
      _endYear = end;
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  void toggleOrder() {
    _isAscending = !_isAscending;
    _applyFiltersAndSorting();
    notifyListeners();
  }

  void setGroupByEra(bool group) {
    if (_groupByEra != group) {
      _groupByEra = group;
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedEraId = null;
    _startYear = minPossibleYear;
    _endYear = maxPossibleYear;
    _isAscending = true;
    _groupByEra = false;
    _applyFiltersAndSorting();
    notifyListeners();
  }

  Color _parseHexColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return ChronosColors.accent;
  }
}
