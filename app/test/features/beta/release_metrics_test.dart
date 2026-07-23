import 'package:chronos/features/beta/services/release_metrics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReleaseMetricsService', () {
    late ReleaseMetricsService service;

    setUp(() {
      service = ReleaseMetricsService();
    });

    test('compare sem histórico retorna métricas zeradas', () {
      final comparison = service.compare();
      expect(comparison.previous, isNull);
      expect(comparison.current.version, '1.0.0-beta.1');
    });

    test('record adiciona métricas ao histórico', () async {
      await service.record(VersionMetrics(
        version: '1.0.0-beta.1',
        coldStartMs: 800,
        warmStartMs: 300,
        avgSearchMs: 150,
        memoryUsageMb: 120,
        errorCount: 5,
        queryCount: 200,
        recordedAt: DateTime.now(),
      ));
      expect(service.history, hasLength(1));
    });

    test('compare com duas versões calcula delta', () async {
      await service.record(VersionMetrics(
        version: '0.9.0',
        coldStartMs: 1000,
        warmStartMs: 400,
        avgSearchMs: 200,
        memoryUsageMb: 150,
        errorCount: 10,
        queryCount: 100,
        recordedAt: DateTime.now(),
      ));
      await service.record(VersionMetrics(
        version: '1.0.0-beta.1',
        coldStartMs: 800,
        warmStartMs: 300,
        avgSearchMs: 150,
        memoryUsageMb: 120,
        errorCount: 5,
        queryCount: 200,
        recordedAt: DateTime.now(),
      ));

      final comparison = service.compare();
      expect(comparison.previous, isNotNull);
      expect(comparison.coldStartDelta, -20.0); // 800 vs 1000 = -20%
      expect(comparison.memoryDelta, -20.0); // 120 vs 150 = -20%
      expect(comparison.errorDelta, -50.0); // 5 vs 10 = -50%
    });

    test('summary gera texto legível', () async {
      await service.record(VersionMetrics(
        version: '0.9.0',
        coldStartMs: 1000,
        warmStartMs: 400,
        avgSearchMs: 200,
        memoryUsageMb: 150,
        errorCount: 10,
        queryCount: 100,
        recordedAt: DateTime.now(),
      ));
      await service.record(VersionMetrics(
        version: '1.0.0-beta.1',
        coldStartMs: 800,
        warmStartMs: 300,
        avgSearchMs: 150,
        memoryUsageMb: 120,
        errorCount: 5,
        queryCount: 200,
        recordedAt: DateTime.now(),
      ));

      final comparison = service.compare();
      expect(comparison.summary, contains('0.9.0'));
      expect(comparison.summary, contains('1.0.0-beta.1'));
    });
  });
}
