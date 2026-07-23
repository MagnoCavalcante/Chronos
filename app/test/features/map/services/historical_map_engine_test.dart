import 'package:chronos/core/relationships/relationship_engine.dart';
import 'package:chronos/core/timeline/timeline_repository.dart';
import 'package:chronos/features/map/data/cache/map_cache_service.dart';
import 'package:chronos/features/map/data/services/animation_engine.dart';
import 'package:chronos/features/map/data/services/map_lazy_loader.dart';
import 'package:chronos/features/map/data/services/marker_clustering_service.dart';
import 'package:chronos/features/map/domain/entities/map_entities.dart';
import 'package:chronos/features/map/domain/providers/map_provider.dart';
import 'package:chronos/features/map/services/historical_map_engine.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/domain/entities/historical_location.dart';
import 'package:chronos/domain/usecases/get_locations_within_bounds.dart';
import 'package:chronos/domain/repositories/historical_location_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMapProvider implements MapProvider {
  GeoCoordinate? lastMoveTo;

  @override
  String get name => 'Fake';
  @override
  bool get isAvailable => true;
  @override
  MapCameraState? get currentCameraState => null;
  @override
  Widget buildMapWidget({
    required MapViewConfig config,
    List<MapMarker> markers = const [],
    List<MarkerCluster> clusters = const [],
    List<MapLayer> layers = const [],
    ValueChanged<MapMarker>? onMarkerTap,
    ValueChanged<MarkerCluster>? onClusterTap,
    ValueChanged<MapCameraState>? onCameraMove,
    ValueChanged<MapCameraState>? onCameraIdle,
  }) =>
      const SizedBox();
  @override
  Future<void> moveCamera(GeoCoordinate target, {double? zoom, bool animate = true}) async {
    lastMoveTo = target;
  }

  @override
  Future<void> fitBounds(GeoBounds bounds, {double padding = 50.0}) async {}
  @override
  void dispose() {}
}

class _FakeLocationRepo extends HistoricalLocationRepository {
  @override
  Future<Result<List<HistoricalLocation>>> getAll() async => Result.success([]);
  @override
  Future<Result<HistoricalLocation>> getById(String id) async =>
      Result.failure(const EmptyResultFailure('not found'));
  @override
  Future<Result<HistoricalLocation>> getBySlug(String slug) async =>
      Result.failure(const EmptyResultFailure('not found'));
  @override
  Future<Result<List<HistoricalLocation>>> getByParent(String parentId) async => Result.success([]);
  @override
  Future<Result<List<HistoricalLocation>>> getByType(LocationType type) async => Result.success([]);
  @override
  Future<Result<List<HistoricalLocation>>> getWithinBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async =>
      Result.success([]);
  @override
  Future<Result<List<HistoricalLocation>>> getPublished() async => Result.success([]);
}

void main() {
  group('HistoricalMapEngine', () {
    late HistoricalMapEngine engine;
    late _FakeMapProvider mapProvider;

    setUp(() {
      mapProvider = _FakeMapProvider();
      final lazyLoader = MapLazyLoader(
        getLocationsWithinBounds: GetLocationsWithinBounds(_FakeLocationRepo()),
      );
      engine = HistoricalMapEngine(
        mapProvider: mapProvider,
        lazyLoader: lazyLoader,
        clustering: MarkerClusteringService(),
        cache: MapCacheService(),
        animationEngine: AnimationEngine(mapProvider: mapProvider),
        relationshipEngine: RelationshipEngine(),
        timelineRepository: TimelineRepository(),
      );
    });

    tearDown(() {
      engine.dispose();
    });

    test('estado inicial sem marcadores nem camadas', () {
      expect(engine.state.visibleMarkers, isEmpty);
      expect(engine.state.clusters, isEmpty);
      expect(engine.state.activeLayers, isEmpty);
      expect(engine.state.isLoading, isFalse);
    });

    test('addLayer e removeLayer gerenciam camadas', () {
      const layer = MapLayer(id: 'l1', name: 'Fronteiras', type: MapLayerType.borders);
      engine.addLayer(layer);
      expect(engine.state.activeLayers, hasLength(1));

      engine.removeLayer('l1');
      expect(engine.state.activeLayers, isEmpty);
    });

    test('toggleLayer alterna visibilidade', () {
      const layer = MapLayer(id: 'l1', name: 'Rotas', type: MapLayerType.routes);
      engine.addLayer(layer);
      expect(engine.state.activeLayers.first.isVisible, isTrue);

      engine.toggleLayer('l1');
      expect(engine.state.activeLayers.first.isVisible, isFalse);
    });

    test('goTo move câmera do provider', () async {
      const target = GeoCoordinate(latitude: 41.9, longitude: 12.5);
      await engine.goTo(target, zoom: 8);
      expect(mapProvider.lastMoveTo, target);
    });

    test('setPeriod atualiza estado', () async {
      await engine.setPeriod(startYear: -500, endYear: -200);
      expect(engine.state.periodStart, -500);
      expect(engine.state.periodEnd, -200);
      expect(engine.state.isLoading, isFalse);
    });

    test('reset limpa todo o estado', () async {
      engine.addLayer(const MapLayer(id: 'l1', name: 'X', type: MapLayerType.custom));
      await engine.reset();
      expect(engine.state.activeLayers, isEmpty);
      expect(engine.state.visibleMarkers, isEmpty);
    });
  });
}
