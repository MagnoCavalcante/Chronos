import 'package:chronos/features/map/domain/entities/map_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoCoordinate', () {
    test('igualdade por valor', () {
      const a = GeoCoordinate(latitude: 30.0, longitude: 31.0);
      const b = GeoCoordinate(latitude: 30.0, longitude: 31.0);
      expect(a, equals(b));
    });

    test('desigualdade quando diferentes', () {
      const a = GeoCoordinate(latitude: 30.0, longitude: 31.0);
      const b = GeoCoordinate(latitude: 40.0, longitude: 31.0);
      expect(a, isNot(equals(b)));
    });
  });

  group('GeoBounds', () {
    const bounds = GeoBounds(
      northEast: GeoCoordinate(latitude: 40.0, longitude: 50.0),
      southWest: GeoCoordinate(latitude: 20.0, longitude: 10.0),
    );

    test('center calcula corretamente', () {
      final center = bounds.center;
      expect(center.latitude, 30.0);
      expect(center.longitude, 30.0);
    });

    test('contains retorna true para ponto interno', () {
      const point = GeoCoordinate(latitude: 30.0, longitude: 30.0);
      expect(bounds.contains(point), isTrue);
    });

    test('contains retorna false para ponto externo', () {
      const point = GeoCoordinate(latitude: 50.0, longitude: 30.0);
      expect(bounds.contains(point), isFalse);
    });
  });

  group('MapLayer', () {
    test('copyWith alterna visibilidade', () {
      const layer = MapLayer(id: '1', name: 'Fronteiras', type: MapLayerType.borders);
      final hidden = layer.copyWith(isVisible: false);
      expect(hidden.isVisible, isFalse);
      expect(hidden.id, '1');
    });
  });

  group('HistoricalAnimation', () {
    test('criação com keyframes', () {
      const animation = HistoricalAnimation(
        id: 'roman_expansion',
        title: 'Expansão do Império Romano',
        description: 'De 264 a.C. a 117 d.C.',
        startYear: -264,
        endYear: 117,
        keyframes: [
          AnimationKeyframe(
            year: -264,
            center: GeoCoordinate(latitude: 41.9, longitude: 12.5),
            zoom: 5,
          ),
          AnimationKeyframe(
            year: 117,
            center: GeoCoordinate(latitude: 38.0, longitude: 25.0),
            zoom: 4,
          ),
        ],
      );
      expect(animation.keyframes, hasLength(2));
      expect(animation.startYear, -264);
      expect(animation.endYear, 117);
    });
  });
}
