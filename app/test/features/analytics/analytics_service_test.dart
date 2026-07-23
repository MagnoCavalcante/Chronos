import 'package:chronos/features/analytics/domain/entities/analytics_entities.dart';
import 'package:chronos/features/analytics/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService();
    });

    test('inicia sem eventos', () {
      expect(service.events, isEmpty);
    });

    test('track registra evento', () async {
      await service.track(
        type: AnalyticsEventType.export,
        entityType: 'civilization',
        entityId: 'civ_1',
        format: 'markdown',
      );
      expect(service.events, hasLength(1));
      expect(service.events.first.type, AnalyticsEventType.export);
    });

    test('getSummary calcula total de exportações', () async {
      await service.track(type: AnalyticsEventType.export, entityType: 'event', entityId: 'e1', format: 'markdown');
      await service.track(type: AnalyticsEventType.export, entityType: 'event', entityId: 'e2', format: 'html');
      await service.track(type: AnalyticsEventType.export, entityType: 'event', entityId: 'e3', format: 'markdown');

      final summary = service.getSummary();
      expect(summary.totalExports, 3);
      expect(summary.mostUsedFormat, 'markdown');
    });

    test('getSummary calcula conteúdo mais compartilhado', () async {
      await service.track(type: AnalyticsEventType.share, entityType: 'character', entityId: 'ch1');
      await service.track(type: AnalyticsEventType.share, entityType: 'character', entityId: 'ch1');
      await service.track(type: AnalyticsEventType.share, entityType: 'character', entityId: 'ch2');

      final summary = service.getSummary();
      expect(summary.mostSharedContent, 'ch1');
    });

    test('getSummary calcula tempo médio de leitura', () async {
      await service.track(type: AnalyticsEventType.view, entityType: 'event', entityId: 'e1', durationMs: 5000);
      await service.track(type: AnalyticsEventType.view, entityType: 'event', entityId: 'e2', durationMs: 3000);

      final summary = service.getSummary();
      expect(summary.averageReadingTimeMs, 4000);
    });

    test('clear limpa todos os eventos', () async {
      await service.track(type: AnalyticsEventType.view, entityType: 'event', entityId: 'e1');
      await service.clear();
      expect(service.events, isEmpty);
    });
  });
}
