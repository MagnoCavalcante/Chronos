import 'package:chronos/features/beta/services/telemetry_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelemetryService', () {
    late TelemetryService service;

    setUp(() {
      service = TelemetryService();
    });

    test('snapshot inicial com zeros', () {
      final snap = service.snapshot;
      expect(snap.totalSessionsCount, 0);
      expect(snap.totalSearches, 0);
      expect(snap.totalCrashes, 0);
      expect(snap.totalErrors, 0);
    });

    test('startSession incrementa sessões', () {
      service.startSession();
      expect(service.snapshot.totalSessionsCount, 1);
    });

    test('trackSearch incrementa pesquisas', () {
      service.trackSearch();
      service.trackSearch();
      expect(service.snapshot.totalSearches, 2);
    });

    test('trackFeature registra uso', () {
      service.trackFeature('timeline');
      service.trackFeature('timeline');
      service.trackFeature('map');
      expect(service.snapshot.featureUsage['timeline'], 2);
      expect(service.snapshot.featureUsage['map'], 1);
    });

    test('trackCrash incrementa crashes', () {
      service.trackCrash();
      expect(service.snapshot.totalCrashes, 1);
    });

    test('trackError incrementa erros', () {
      service.trackError();
      service.trackError();
      expect(service.snapshot.totalErrors, 2);
    });

    test('reset limpa tudo', () async {
      service.startSession();
      service.trackSearch();
      service.trackCrash();
      await service.reset();
      final snap = service.snapshot;
      expect(snap.totalSessionsCount, 0);
      expect(snap.totalSearches, 0);
      expect(snap.totalCrashes, 0);
    });
  });
}
