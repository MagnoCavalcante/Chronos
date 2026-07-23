import 'package:flutter/widgets.dart';
import '../entities/map_entities.dart';

/// Interface abstrata que define o contrato de qualquer provedor de mapas no CHRONOS.
///
/// O restante da aplicação NUNCA depende diretamente de um pacote de mapas.
/// Toda comunicação ocorre através desta interface, permitindo trocar entre
/// OpenStreetMap, Google Maps, Mapbox, HERE ou qualquer outro sem refatoração.
abstract class MapProvider {
  /// Nome identificador do provedor.
  String get name;

  /// Indica se o provedor está disponível (pacote instalado, chave válida, etc.).
  bool get isAvailable;

  /// Constrói o widget do mapa configurado conforme [config].
  ///
  /// O widget é inserido na árvore do Flutter pela camada de apresentação.
  /// O [MapProvider] nunca controla navegação ou estado de UI diretamente.
  Widget buildMapWidget({
    required MapViewConfig config,
    List<MapMarker> markers = const [],
    List<MarkerCluster> clusters = const [],
    List<MapLayer> layers = const [],
    ValueChanged<MapMarker>? onMarkerTap,
    ValueChanged<MarkerCluster>? onClusterTap,
    ValueChanged<MapCameraState>? onCameraMove,
    ValueChanged<MapCameraState>? onCameraIdle,
  });

  /// Move a câmera para a coordenada e zoom fornecidos (com ou sem animação).
  Future<void> moveCamera(GeoCoordinate target, {double? zoom, bool animate = true});

  /// Ajusta a câmera para enquadrar o bounding box fornecido.
  Future<void> fitBounds(GeoBounds bounds, {double padding = 50.0});

  /// Retorna o estado atual da câmera do mapa.
  MapCameraState? get currentCameraState;

  /// Libera recursos do provedor (controllers internos, subscriptions).
  void dispose();
}
