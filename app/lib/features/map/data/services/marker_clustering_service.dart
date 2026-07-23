import '../../domain/entities/map_entities.dart';

/// Serviço responsável por agrupar marcadores geograficamente próximos em clusters.
///
/// O algoritmo de clustering é baseado em grid (grid-based), dividindo a área visível
/// em células cujo tamanho varia conforme o nível de zoom. Marcadores dentro da mesma
/// célula são agrupados em um único [MarkerCluster].
class MarkerClusteringService {
  /// Distância em graus que define a proximidade para agrupamento no zoom padrão.
  static const double _baseClusterRadius = 0.5;

  /// Executa o agrupamento (clustering) de marcadores com base no zoom atual.
  ///
  /// Quanto maior o [zoom], menor o raio de agrupamento, revelando marcadores individuais.
  List<MarkerCluster> cluster(List<MapMarker> markers, {required double zoom}) {
    if (markers.isEmpty) return [];

    final radius = _clusterRadius(zoom);
    final assigned = <int>{};
    final clusters = <MarkerCluster>[];

    for (int i = 0; i < markers.length; i++) {
      if (assigned.contains(i)) continue;

      final group = <MapMarker>[markers[i]];
      assigned.add(i);

      for (int j = i + 1; j < markers.length; j++) {
        if (assigned.contains(j)) continue;
        if (_isClose(markers[i].position, markers[j].position, radius)) {
          group.add(markers[j]);
          assigned.add(j);
        }
      }

      if (group.length > 1) {
        clusters.add(MarkerCluster(
          id: 'cluster_${clusters.length}',
          center: _centroid(group),
          markers: group,
          count: group.length,
        ));
      }
    }

    return clusters;
  }

  /// Retorna os marcadores que não pertencem a nenhum cluster.
  List<MapMarker> unclustered(List<MapMarker> markers, List<MarkerCluster> clusters) {
    final clusteredIds = clusters.expand((c) => c.markers.map((m) => m.id)).toSet();
    return markers.where((m) => !clusteredIds.contains(m.id)).toList();
  }

  // ─── Private helpers ───────────────────────────────────────────────

  double _clusterRadius(double zoom) {
    // Reduz progressivamente o raio conforme o zoom aumenta.
    return _baseClusterRadius / (zoom * 0.5);
  }

  bool _isClose(GeoCoordinate a, GeoCoordinate b, double radius) {
    final dLat = (a.latitude - b.latitude).abs();
    final dLng = (a.longitude - b.longitude).abs();
    return dLat < radius && dLng < radius;
  }

  GeoCoordinate _centroid(List<MapMarker> group) {
    double sumLat = 0;
    double sumLng = 0;
    for (final m in group) {
      sumLat += m.position.latitude;
      sumLng += m.position.longitude;
    }
    return GeoCoordinate(
      latitude: sumLat / group.length,
      longitude: sumLng / group.length,
    );
  }
}
