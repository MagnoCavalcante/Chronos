import 'package:chronos/features/beta/domain/entities/bug_report.dart';
import 'package:chronos/features/beta/services/bug_tracker_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BugTrackerService', () {
    late BugTrackerService service;

    setUp(() {
      service = BugTrackerService();
    });

    test('inicia sem bugs', () {
      expect(service.bugs, isEmpty);
      expect(service.totalCount, 0);
    });

    test('report adiciona bug', () async {
      await service.report(
        description: 'Botão não responde ao toque',
        priority: BugPriority.high,
        category: BugCategory.ui,
      );
      expect(service.totalCount, 1);
      expect(service.bugs.first.priority, BugPriority.high);
      expect(service.bugs.first.status, BugStatus.open);
    });

    test('openBugs filtra corretamente', () async {
      await service.report(
        description: 'Bug aberto',
        priority: BugPriority.medium,
        category: BugCategory.navigation,
      );
      expect(service.openBugs, hasLength(1));
    });

    test('updateStatus muda status para fixed', () async {
      await service.report(
        description: 'Crash ao abrir mapa',
        priority: BugPriority.critical,
        category: BugCategory.crash,
      );
      final bugId = service.bugs.first.id;
      await service.updateStatus(bugId, BugStatus.fixed, versionFixed: '1.0.0-beta.2');
      expect(service.bugs.first.status, BugStatus.fixed);
      expect(service.fixedCount, 1);
    });

    test('criticalBugs filtra por prioridade e status', () async {
      await service.report(
        description: 'Critical aberto',
        priority: BugPriority.critical,
        category: BugCategory.crash,
      );
      await service.report(
        description: 'Low aberto',
        priority: BugPriority.low,
        category: BugCategory.ui,
      );
      expect(service.criticalBugs, hasLength(1));
    });

    test('getByCategory filtra corretamente', () async {
      await service.report(
        description: 'UI bug',
        priority: BugPriority.medium,
        category: BugCategory.ui,
      );
      await service.report(
        description: 'Network bug',
        priority: BugPriority.high,
        category: BugCategory.network,
      );
      expect(service.getByCategory(BugCategory.ui), hasLength(1));
      expect(service.getByCategory(BugCategory.network), hasLength(1));
    });

    test('clear remove todos os bugs', () async {
      await service.report(
        description: 'Bug 1',
        priority: BugPriority.low,
        category: BugCategory.other,
      );
      await service.clear();
      expect(service.bugs, isEmpty);
    });
  });
}
