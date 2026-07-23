import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/map_entities.dart';
import '../../domain/providers/map_provider.dart';

/// Implementação concreta do [MapProvider] baseada em OpenStreetMap (via flutter_map).
///
/// Não cobra por uso. O Chronos consome apenas esta classe via interface [MapProvider].
class OpenStreetMapProvider implements MapProvider {
  MapController? _mapController;
  MapCameraState? _lastCameraState;

  @override
  String get name => 'OpenStreetMap';

  @override
  bool get isAvailable => true;

  @override
  MapCameraState? get currentCameraState => _lastCameraState;

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
  }) {
    _mapController ??= MapController();

    return FlutterMap(
      mapController: _mapController!,
      options: MapOptions(
        initialCenter: LatLng(config.center.latitude, config.center.longitude),
        initialZoom: config.zoom,
        minZoom: config.minZoom,
        maxZoom: config.maxZoom,
        interactionOptions: InteractionOptions(
          flags: config.interactionEnabled ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onPositionChanged: (position, hasGesture) {
          _lastCameraState = _cameraStateFromController();
          onCameraMove?.call(_lastCameraState!);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.chronos.app',
        ),
        ..._buildLayerWidgets(layers),
        _buildMarkerLayer(markers, clusters, onMarkerTap, onClusterTap),
        if (config.showAttribution) const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }

  @override
  Future<void> moveCamera(GeoCoordinate target, {double? zoom, bool animate = true}) async {
    if (_mapController == null) return;
    _mapController!.move(
      LatLng(target.latitude, target.longitude),
      zoom ?? _mapController!.camera.zoom,
    );
  }

  @override
  Future<void> fitBounds(GeoBounds bounds, {double padding = 50.0}) async {
    if (_mapController == null) return;
    _mapController!.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(bounds.south, bounds.west),
          LatLng(bounds.north, bounds.east),
        ),
        padding: EdgeInsets.all(padding),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
  }

  // ─── Private helpers ───────────────────────────────────────────────

  MapCameraState _cameraStateFromController() {
    final cam = _mapController!.camera;
    final bounds = cam.visibleBounds;
    return MapCameraState(
      center: GeoCoordinate(latitude: cam.center.latitude, longitude: cam.center.longitude),
      zoom: cam.zoom,
      visibleBounds: GeoBounds(
        northEast: GeoCoordinate(latitude: bounds.north, longitude: bounds.east),
        southWest: GeoCoordinate(latitude: bounds.south, longitude: bounds.west),
      ),
    );
  }

  List<Widget> _buildLayerWidgets(List<MapLayer> layers) {
    final widgets = <Widget>[];
    for (final layer in layers.where((l) => l.isVisible && l.points.isNotEmpty)) {
      switch (layer.type) {
        case MapLayerType.borders:
        case MapLayerType.territory:
          widgets.add(PolygonLayer(polygons: [
            Polygon(
              points: layer.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
              color: Color(layer.style?['fillColor'] ?? 0x220000FF),
              borderColor: Color(layer.style?['borderColor'] ?? 0xFF0000FF),
              borderStrokeWidth: (layer.style?['borderWidth'] as num?)?.toDouble() ?? 2.0,
            ),
          ]));
          break;
        case MapLayerType.routes:
        case MapLayerType.battleMovement:
        case MapLayerType.tradeRoute:
        case MapLayerType.migration:
        case MapLayerType.custom:
          widgets.add(PolylineLayer(polylines: [
            Polyline(
              points: layer.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
              color: Color(layer.style?['color'] ?? 0xFFFF5722),
              strokeWidth: (layer.style?['width'] as num?)?.toDouble() ?? 3.0,
            ),
          ]));
          break;
      }
    }
    return widgets;
  }

  MarkerLayer _buildMarkerLayer(
    List<MapMarker> markers,
    List<MarkerCluster> clusters,
    ValueChanged<MapMarker>? onMarkerTap,
    ValueChanged<MarkerCluster>? onClusterTap,
  ) {
    final flutterMarkers = <Marker>[];

    for (final marker in markers) {
      flutterMarkers.add(Marker(
        point: LatLng(marker.position.latitude, marker.position.longitude),
        width: marker.style.size,
        height: marker.style.size,
        child: GestureDetector(
          onTap: () => onMarkerTap?.call(marker),
          child: Icon(Icons.location_on, color: Color(marker.style.color), size: marker.style.size),
        ),
      ));
    }

    for (final cluster in clusters) {
      flutterMarkers.add(Marker(
        point: LatLng(cluster.center.latitude, cluster.center.longitude),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => onClusterTap?.call(cluster),
          child: Container(
            decoration: const BoxDecoration(color: Color(0xCC1A237E), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '${cluster.count}',
              style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ));
    }

    return MarkerLayer(markers: flutterMarkers);
  }
}
