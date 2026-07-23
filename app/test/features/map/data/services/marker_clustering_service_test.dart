import 'package:chronos/features/map/data/services/marker_clustering_service.dart';
import 'package:chronos/features/map/domain/entities/map_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkerClusteringService', () {
    late MarkerClusteringService service;

    setUp(() {
      service = MarkerClusteringService();
    });

    test('retorna lista vazia para entrada vazia', () {
      final clusters = service.cluster([], zoom: 5);
      expect(clusters, isEmpty);
    });

    test('agrupa marcadores próximos em cluster', () {
      final markers = [
        _marker('1', 30.0, 31.0),
        _marker('2', 30.01, 31.01),
        _marker('3', 30.02, 31.02),
      ];
      final clusters = service.cluster(markers, zoom: 4);
      expect(clusters, isNotEmpty);
      expect(clusters.first.count, 3);
    });

    test('não agrupa marcadores distantes', () {
      final markers = [
        _marker('1', 30.0, 31.0),
        _marker('2', 50.0, 10.0),
        _marker('3', -20.0, -40.0),
      ];
      final clusters = service.cluster(markers, zoom: 5);
      expect(clusters, isEmpty);
    });

    test('marcadores individuais aparecem ao ampliar zoom', () {
      final markers = [
        _marker('1', 30.0, 31.0),
        _marker('2', 30.1, 31.1),
      ];
      // Com zoom baixo devem agrupar
      final lowZoom = service.cluster(markers, zoom: 3);
      expect(lowZoom, isNotEmpty);

      // Com zoom alto devem separar
      final highZoom = service.cluster(markers, zoom: 18);
      expect(highZoom, isEmpty);
    });

    test('unclustered retorna marcadores fora de clusters', () {
      final markers = [
        _marker('1', 30.0, 31.0),
        _marker('2', 30.01, 31.01),
        _marker('3', 60.0, 10.0),
      ];
      final clusters = service.cluster(markers, zoom: 4);
      final unclustered = service.unclustered(markers, clusters);
      expect(unclustered.any((m) => m.id == '3'), isTrue);
    });
  });
}

MapMarker _marker(String id, double lat, double lng) => MapMarker(
      id: id,
      entityType: 'historical_location',
      entityId: id,
      title: 'Marker $id',
      position: GeoCoordinate(latitude: lat, longitude: lng),
    );
