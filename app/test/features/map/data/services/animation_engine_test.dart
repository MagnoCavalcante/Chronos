import 'package:chronos/features/map/data/services/animation_engine.dart';
import 'package:chronos/features/map/domain/entities/map_entities.dart';
import 'package:chronos/features/map/domain/providers/map_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMapProvider implements MapProvider {
  GeoCoordinate? lastMoveTo;
  double? lastZoom;

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
    lastZoom = zoom;
  }

  @override
  Future<void> fitBounds(GeoBounds bounds, {double padding = 50.0}) async {}

  @override
  void dispose() {}
}

void main() {
  group('AnimationEngine', () {
    late AnimationEngine engine;
    late _FakeMapProvider provider;

    final animation = HistoricalAnimation(
      id: 'test',
      title: 'Teste',
      description: 'Animação de teste',
      startYear: -300,
      endYear: 100,
      keyframes: [
        const AnimationKeyframe(
          year: -300,
          center: GeoCoordinate(latitude: 40, longitude: 20),
          zoom: 5,
          duration: Duration(milliseconds: 50),
        ),
        const AnimationKeyframe(
          year: -100,
          center: GeoCoordinate(latitude: 42, longitude: 25),
          zoom: 6,
          duration: Duration(milliseconds: 50),
        ),
        const AnimationKeyframe(
          year: 100,
          center: GeoCoordinate(latitude: 38, longitude: 30),
          zoom: 4,
          duration: Duration(milliseconds: 50),
        ),
      ],
    );

    setUp(() {
      provider = _FakeMapProvider();
      engine = AnimationEngine(mapProvider: provider);
    });

    tearDown(() {
      engine.dispose();
    });

    test('estado inicial é idle', () {
      expect(engine.playbackState, AnimationPlaybackState.idle);
      expect(engine.currentAnimation, isNull);
    });

    test('carrega animação corretamente', () {
      engine.load(animation);
      expect(engine.currentAnimation, equals(animation));
      expect(engine.currentKeyframeIndex, 0);
      expect(engine.playbackState, AnimationPlaybackState.idle);
    });

    test('seekTo muda keyframe', () {
      engine.load(animation);
      engine.seekTo(2);
      expect(engine.currentKeyframeIndex, 2);
      expect(engine.currentYear, 100);
      expect(provider.lastMoveTo?.latitude, 38);
    });

    test('seekToYear encontra keyframe mais próximo', () {
      engine.load(animation);
      engine.seekToYear(-150);
      expect(engine.currentKeyframeIndex, 1); // -100 é mais próximo de -150
    });

    test('next e previous navegam entre keyframes', () {
      engine.load(animation);
      engine.next();
      expect(engine.currentKeyframeIndex, 1);
      engine.next();
      expect(engine.currentKeyframeIndex, 2);
      engine.previous();
      expect(engine.currentKeyframeIndex, 1);
    });

    test('progress calcula corretamente', () {
      engine.load(animation);
      expect(engine.progress, 0.0);
      engine.seekTo(1);
      expect(engine.progress, 0.5);
      engine.seekTo(2);
      expect(engine.progress, 1.0);
    });

    test('setSpeed clamp entre 0.25 e 4.0', () {
      engine.setSpeed(0.1);
      expect(engine.speed, 0.25);
      engine.setSpeed(10.0);
      expect(engine.speed, 4.0);
      engine.setSpeed(2.0);
      expect(engine.speed, 2.0);
    });
  });
}
