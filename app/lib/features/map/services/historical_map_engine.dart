import 'package:flutter/widgets.dart';

import '../../../core/relationships/relationship_engine.dart';
import '../../../core/timeline/timeline_repository.dart';
import '../../../core/utils/logger.dart';
import '../data/cache/map_cache_service.dart';
import '../data/services/animation_engine.dart';
import '../data/services/map_lazy_loader.dart';
import '../data/services/marker_clustering_service.dart';
import '../domain/entities/map_entities.dart';
import '../domain/providers/map_provider.dart';

/// Estado observável do [HistoricalMapEngine].
class HistoricalMapState {
  final List<MapMarker> visibleMarkers;
  final List<MarkerCluster> clusters;
  final List<MapLayer> activeLayers;
  final int? periodStart;
  final int? periodEnd;
  final MapCameraState? camera;
  final bool isLoading;
  final String? error;

  const HistoricalMapState({
    this.visibleMarkers = const [],
    this.clusters = const [],
    this.activeLayers = const [],
    this.periodStart,
    this.periodEnd,
    this.camera,
    this.isLoading = false,
    this.error,
  });

  HistoricalMapState copyWith({
    List<MapMarker>? visibleMarkers,
    List<MarkerCluster>? clusters,
    List<MapLayer>? activeLayers,
    int? periodStart,
    int? periodEnd,
    MapCameraState? camera,
    bool? isLoading,
    String? error,
  }) =>
      HistoricalMapState(
        visibleMarkers: visibleMarkers ?? this.visibleMarkers,
        clusters: clusters ?? this.clusters,
        activeLayers: activeLayers ?? this.activeLayers,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
        camera: camera ?? this.camera,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Serviço central e único ponto de integração para o sistema de mapas do CHRONOS.
///
/// Responsável por integrar:
/// - Timeline
/// - Relationship Engine
/// - Chronos AI
/// - Coleções
/// - Sistema de Estudos
/// - Favoritos
/// - Localizações
/// - Marcadores
/// - Camadas
///
/// Nenhum módulo externo acessa diretamente o mapa.
/// Toda comunicação passa pelo [HistoricalMapEngine].
class HistoricalMapEngine extends ChangeNotifier {
  static const String _tag = 'HistoricalMapEngine';

  final MapProvider _mapProvider;
  final MapLazyLoader _lazyLoader;
  final MarkerClusteringService _clustering;
  final MapCacheService _cache;
  final AnimationEngine _animationEngine;
  final RelationshipEngine _relationshipEngine;
  final TimelineRepository _timelineRepository;

  HistoricalMapState _state = const HistoricalMapState();

  HistoricalMapEngine({
    required MapProvider mapProvider,
    required MapLazyLoader lazyLoader,
    required MarkerClusteringService clustering,
    required MapCacheService cache,
    required AnimationEngine animationEngine,
    required RelationshipEngine relationshipEngine,
    required TimelineRepository timelineRepository,
  })  : _mapProvider = mapProvider,
        _lazyLoader = lazyLoader,
        _clustering = clustering,
        _cache = cache,
        _animationEngine = animationEngine,
        _relationshipEngine = relationshipEngine,
        _timelineRepository = timelineRepository;

  /// Estado reativo atual.
  HistoricalMapState get state => _state;

  /// Provider de mapas subjacente (apenas para construção de widget).
  MapProvider get mapProvider => _mapProvider;

  /// Engine de animações históricas.
  AnimationEngine get animationEngine => _animationEngine;

  /// Constrói o widget do mapa integrado com todos os subsistemas.
  Widget buildMap({
    MapViewConfig config = const MapViewConfig(),
    ValueChanged<MapMarker>? onMarkerTap,
    ValueChanged<MarkerCluster>? onClusterTap,
  }) {
    return _mapProvider.buildMapWidget(
      config: config,
      markers: _state.visibleMarkers,
      clusters: _state.clusters,
      layers: _state.activeLayers,
      onMarkerTap: onMarkerTap,
      onClusterTap: onClusterTap,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
    );
  }

  /// Define o período histórico ativo no mapa.
  ///
  /// Carrega marcadores e camadas relevantes para o período, usando cache quando disponível.
  Future<void> setPeriod({required int startYear, required int endYear}) async {
    ChronosLogger.info('Definindo período: [$startYear .. $endYear]', tag: _tag);
    _state = _state.copyWith(periodStart: startYear, periodEnd: endYear, isLoading: true);
    notifyListeners();

    try {
      // Tenta cache primeiro
      final cached = await _cache.getCachedMarkers(
        startYear: startYear,
        endYear: endYear,
        bounds: _state.camera?.visibleBounds,
      );

      if (cached != null && cached.isNotEmpty) {
        _updateMarkers(cached);
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return;
      }

      // Carrega via lazy loader
      final bounds = _state.camera?.visibleBounds ??
          const GeoBounds(
            northEast: GeoCoordinate(latitude: 70, longitude: 60),
            southWest: GeoCoordinate(latitude: -35, longitude: -30),
          );

      final markers = await _lazyLoader.loadVisibleMarkers(
        bounds: bounds,
        startYear: startYear,
        endYear: endYear,
      );

      _updateMarkers(markers);

      // Pré-cache inteligente
      await _cache.warmUp(
        markers: markers,
        startYear: startYear,
        endYear: endYear,
        bounds: bounds,
      );

      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao definir período: $e', tag: _tag, error: e);
      _state = _state.copyWith(isLoading: false, error: e.toString());
      notifyListeners();
    }
  }

  /// Adiciona uma camada de visualização.
  void addLayer(MapLayer layer) {
    final layers = List<MapLayer>.from(_state.activeLayers)..add(layer);
    _state = _state.copyWith(activeLayers: layers);
    notifyListeners();
  }

  /// Remove uma camada pelo ID.
  void removeLayer(String layerId) {
    final layers = _state.activeLayers.where((l) => l.id != layerId).toList();
    _state = _state.copyWith(activeLayers: layers);
    notifyListeners();
  }

  /// Alterna visibilidade de uma camada.
  void toggleLayer(String layerId) {
    final layers = _state.activeLayers.map((l) {
      return l.id == layerId ? l.copyWith(isVisible: !l.isVisible) : l;
    }).toList();
    _state = _state.copyWith(activeLayers: layers);
    notifyListeners();
  }

  /// Move a câmera para uma coordenada.
  Future<void> goTo(GeoCoordinate target, {double? zoom}) async {
    await _mapProvider.moveCamera(target, zoom: zoom);
  }

  /// Enquadra o mapa nos bounds fornecidos.
  Future<void> fitBounds(GeoBounds bounds) async {
    await _mapProvider.fitBounds(bounds);
  }

  /// Foca em uma entidade pelo ID: carrega relacionamentos e posiciona.
  Future<void> focusOnEntity({
    required String entityType,
    required String entityId,
    required GeoCoordinate position,
  }) async {
    ChronosLogger.info('Focando em entidade: $entityType/$entityId', tag: _tag);
    await _mapProvider.moveCamera(position, zoom: 10);

    // Carrega relacionamentos para exibir conexões
    final groups = await _relationshipEngine.discover(
      entityType: entityType,
      entityId: entityId,
      limit: 20,
    );

    ChronosLogger.info(
      'Entidade focada com ${groups.length} grupos de relacionamento',
      tag: _tag,
    );
  }

  /// Carrega animação histórica.
  void loadAnimation(HistoricalAnimation animation) {
    _animationEngine.load(animation);
  }

  /// Busca eventos na timeline e posiciona no mapa.
  Future<void> showTimelinePeriod({int? startYear, int? endYear, String? search}) async {
    final items = await _timelineRepository.getTimeline(
      startYear: startYear,
      endYear: endYear,
      search: search,
    );
    ChronosLogger.info('Timeline retornou ${items.length} itens para mapa', tag: _tag);
  }

  /// Limpa estado e cache.
  Future<void> reset() async {
    _lazyLoader.invalidate();
    _state = const HistoricalMapState();
    notifyListeners();
  }

  @override
  void dispose() {
    _animationEngine.dispose();
    _mapProvider.dispose();
    super.dispose();
  }

  // ─── Private ───────────────────────────────────────────────────────

  void _onCameraMove(MapCameraState camera) {
    _state = _state.copyWith(camera: camera);
  }

  void _onCameraIdle(MapCameraState camera) {
    _state = _state.copyWith(camera: camera);
    _reloadForBounds(camera.visibleBounds);
  }

  Future<void> _reloadForBounds(GeoBounds bounds) async {
    final markers = await _lazyLoader.loadVisibleMarkers(
      bounds: bounds,
      startYear: _state.periodStart,
      endYear: _state.periodEnd,
    );
    _updateMarkers(markers);
    notifyListeners();
  }

  void _updateMarkers(List<MapMarker> allMarkers) {
    final zoom = _state.camera?.zoom ?? 4.0;
    final clusters = _clustering.cluster(allMarkers, zoom: zoom);
    final visible = _clustering.unclustered(allMarkers, clusters);
    _state = _state.copyWith(visibleMarkers: visible, clusters: clusters);
  }
}
