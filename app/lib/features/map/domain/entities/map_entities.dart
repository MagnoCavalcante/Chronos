/// Coordenada geográfica simples (latitude/longitude).
class GeoCoordinate {
  final double latitude;
  final double longitude;

  const GeoCoordinate({required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoCoordinate && latitude == other.latitude && longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'GeoCoordinate($latitude, $longitude)';
}

/// Limite retangular geográfico (bounding box).
class GeoBounds {
  final GeoCoordinate northEast;
  final GeoCoordinate southWest;

  const GeoBounds({required this.northEast, required this.southWest});

  double get north => northEast.latitude;
  double get east => northEast.longitude;
  double get south => southWest.latitude;
  double get west => southWest.longitude;

  GeoCoordinate get center => GeoCoordinate(
        latitude: (north + south) / 2,
        longitude: (east + west) / 2,
      );

  bool contains(GeoCoordinate point) =>
      point.latitude >= south &&
      point.latitude <= north &&
      point.longitude >= west &&
      point.longitude <= east;
}

/// Marcador no mapa representando uma entidade histórica.
class MapMarker {
  final String id;
  final String entityType;
  final String entityId;
  final String title;
  final String? subtitle;
  final GeoCoordinate position;
  final MapMarkerStyle style;
  final int? year;
  final Map<String, dynamic>? metadata;

  const MapMarker({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.title,
    this.subtitle,
    required this.position,
    this.style = const MapMarkerStyle(),
    this.year,
    this.metadata,
  });
}

/// Estilo de um marcador.
class MapMarkerStyle {
  final String? iconAsset;
  final int color;
  final double size;

  const MapMarkerStyle({
    this.iconAsset,
    this.color = 0xFFE65100,
    this.size = 36,
  });
}

/// Cluster de marcadores agrupados por proximidade geográfica.
class MarkerCluster {
  final String id;
  final GeoCoordinate center;
  final List<MapMarker> markers;
  final int count;

  const MarkerCluster({
    required this.id,
    required this.center,
    required this.markers,
    required this.count,
  });
}

/// Camada de visualização no mapa (fronteiras, rotas, áreas).
class MapLayer {
  final String id;
  final String name;
  final MapLayerType type;
  final bool isVisible;
  final int? startYear;
  final int? endYear;
  final List<GeoCoordinate> points;
  final Map<String, dynamic>? style;

  const MapLayer({
    required this.id,
    required this.name,
    required this.type,
    this.isVisible = true,
    this.startYear,
    this.endYear,
    this.points = const [],
    this.style,
  });

  MapLayer copyWith({bool? isVisible}) => MapLayer(
        id: id,
        name: name,
        type: type,
        isVisible: isVisible ?? this.isVisible,
        startYear: startYear,
        endYear: endYear,
        points: points,
        style: style,
      );
}

/// Tipos de camada suportados.
enum MapLayerType {
  borders,
  routes,
  territory,
  battleMovement,
  tradeRoute,
  migration,
  custom,
}

/// Configurações visuais do mapa.
class MapViewConfig {
  final GeoCoordinate center;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final bool interactionEnabled;
  final bool showAttribution;

  const MapViewConfig({
    this.center = const GeoCoordinate(latitude: 30.0, longitude: 31.0),
    this.zoom = 4.0,
    this.minZoom = 2.0,
    this.maxZoom = 18.0,
    this.interactionEnabled = true,
    this.showAttribution = true,
  });
}

/// Estado da câmera do mapa reportado pelo provider.
class MapCameraState {
  final GeoCoordinate center;
  final double zoom;
  final GeoBounds visibleBounds;

  const MapCameraState({
    required this.center,
    required this.zoom,
    required this.visibleBounds,
  });
}

/// Parâmetros para uma animação histórica (infraestrutura).
class HistoricalAnimation {
  final String id;
  final String title;
  final String description;
  final int startYear;
  final int endYear;
  final List<AnimationKeyframe> keyframes;

  const HistoricalAnimation({
    required this.id,
    required this.title,
    required this.description,
    required this.startYear,
    required this.endYear,
    required this.keyframes,
  });
}

/// Frame-chave de uma animação histórica.
class AnimationKeyframe {
  final int year;
  final GeoCoordinate center;
  final double zoom;
  final List<MapMarker> markers;
  final List<MapLayer> layers;
  final Duration duration;

  const AnimationKeyframe({
    required this.year,
    required this.center,
    required this.zoom,
    this.markers = const [],
    this.layers = const [],
    this.duration = const Duration(seconds: 2),
  });
}
